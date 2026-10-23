#!/usr/bin/env python3
"""DNS failover probe for Linux clients.

Runs one thread per (name, method) and writes one CSV row per query:
  ts,vm,os,design,profile,name,method,server,rcode,answer,ms

Methods
  os            socket.getaddrinfo() -> whatever the OS resolver path is (systemd-resolved stub
                by default, or glibc direct when the 'glibc-*' profile is active)
  dig@<server>  dig straight at one server with +time/+tries (raw per-server reachability)
  resolvectl    every 5 s, the systemd-resolved 'Current DNS Server' (answer column)

Only the Python standard library and 'dig' are used. At the end the rows are sent to Log
Analytics (DnsProbe_CL) via the Logs Ingestion API with the VM managed identity (no keys).
"""
import argparse
import csv
import gzip
import json
import os
import socket
import subprocess
import threading
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone

FIELDS = ["ts", "vm", "os", "design", "profile", "name", "method", "server", "rcode", "answer", "ms"]


def now():
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


class Writer:
    def __init__(self, path, base):
        self.lock = threading.Lock()
        self.base = base
        self.fh = open(path, "w", newline="")
        self.w = csv.DictWriter(self.fh, fieldnames=FIELDS)
        self.w.writeheader()

    def row(self, **kw):
        r = dict(self.base)
        r.update(kw)
        with self.lock:
            self.w.writerow(r)
            self.fh.flush()

    def close(self):
        self.fh.close()


def q_os(name, timeout):
    t0 = time.monotonic()
    try:
        infos = socket.getaddrinfo(name, None, socket.AF_INET, socket.SOCK_STREAM)
        ans = sorted({i[4][0] for i in infos})
        return "NOERROR", ";".join(ans), t0
    except socket.gaierror as e:
        code = {
            socket.EAI_NONAME: "NXDOMAIN",
            socket.EAI_AGAIN: "SERVFAIL_OR_TIMEOUT",
        }.get(e.errno, f"EAI{e.errno}")
        return code, "", t0


def q_dig(name, server, timeout, tries, tcp=False):
    cmd = ["dig", f"@{server}", name, "A", f"+time={timeout}", f"+tries={tries}", "+noall", "+answer", "+comments"]
    if tcp:
        cmd.append("+tcp")
    t0 = time.monotonic()
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout * tries + 3).stdout
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "", t0
    rcode = "TIMEOUT"
    for line in out.splitlines():
        if "status:" in line:
            rcode = line.split("status:")[1].split(",")[0].strip()
            break
    if "connection timed out" in out or "no servers could be reached" in out:
        rcode = "TIMEOUT"
    ans = sorted(
        {l.split()[-1] for l in out.splitlines() if l and not l.startswith(";") and len(l.split()) >= 5 and l.split()[3] == "A"}
    )
    return rcode, ";".join(ans), t0


def resolvectl_current():
    try:
        out = subprocess.run(["resolvectl", "status"], capture_output=True, text=True, timeout=5).stdout
    except Exception:
        return ""
    cur = [l.split(":", 1)[1].strip() for l in out.splitlines() if "Current DNS Server" in l]
    return ";".join(cur)


def worker(stop, w, name, method, server, args):
    while not stop.is_set():
        start = time.monotonic()
        ts = now()
        if method == "os":
            rcode, ans, t0 = q_os(name, args.dig_time)
        elif method.startswith("dig"):
            rcode, ans, t0 = q_dig(name, server, args.dig_time, args.dig_tries, tcp=method.endswith("tcp"))
        else:
            rcode, ans, t0 = "INFO", resolvectl_current(), time.monotonic()
        ms = int((time.monotonic() - t0) * 1000)
        w.row(ts=ts, name=name, method=method, server=server, rcode=rcode, answer=ans, ms=ms)
        interval = 5.0 if method == "resolvectl" else args.interval
        stop.wait(max(0.0, interval - (time.monotonic() - start)))


def imds_token(resource):
    url = (
        "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource="
        + urllib.parse.quote(resource, safe="")
    )
    req = urllib.request.Request(url, headers={"Metadata": "true"})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)["access_token"]


def ingest(path, endpoint, dcr, run_id, chunk=1000):
    """Send the CSV to Log Analytics (DnsProbe_CL) via the Logs Ingestion API, then a 'meta' row
    whose answer is the data-row count so the collector knows when this VM is complete."""
    tok = imds_token("https://monitor.azure.com/")
    url = f"{endpoint}/dataCollectionRules/{dcr}/streams/Custom-DnsProbe?api-version=2023-01-01"
    with open(path, newline="") as fh:
        rows = [
            {
                "TimeGenerated": r["ts"], "RunId": run_id, "Vm": r["vm"], "Os": r["os"], "Design": r["design"],
                "Profile": r["profile"], "Name": r["name"], "Method": r["method"], "Server": r["server"],
                "Rcode": r["rcode"], "Answer": r["answer"], "Ms": int(r["ms"] or 0),
            }
            for r in csv.DictReader(fh)
        ]
    if rows:
        meta = dict(rows[-1], TimeGenerated=now(), Name="-", Method="meta", Server="", Rcode="DONE", Answer=str(len(rows)), Ms=0)
    else:
        return 0
    batches = [rows[i:i + chunk] for i in range(0, len(rows), chunk)] + [[meta]]
    for b in batches:
        body = gzip.compress(json.dumps(b).encode())
        for attempt in range(5):
            try:
                req = urllib.request.Request(url, data=body, method="POST", headers={
                    "Authorization": "Bearer " + tok, "Content-Type": "application/json", "Content-Encoding": "gzip"})
                with urllib.request.urlopen(req, timeout=60) as r:
                    if r.status in (200, 204):
                        break
            except Exception as e:  # transient network/DNS/throttling: back off and retry
                print(f"ingest retry {attempt}: {e}")
                time.sleep(5 * (attempt + 1))
        else:
            raise RuntimeError("ingestion failed")
    return len(rows)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--run-id", required=True)
    p.add_argument("--design", required=True)
    p.add_argument("--profile", default="resolved-default")
    p.add_argument("--start-at", type=float, default=0, help="unix epoch to start (wait until then)")
    p.add_argument("--end-at", type=float, default=0, help="unix epoch to stop")
    p.add_argument("--duration", type=int, default=420, help="used when --end-at is not set")
    p.add_argument("--interval", type=float, default=0.5)
    p.add_argument("--names", required=True, help="comma separated FQDNs for the os method")
    p.add_argument("--dig-names", default="", help="comma separated FQDNs also probed with dig per server")
    p.add_argument("--servers", default="", help="comma separated DNS servers for dig@ probes")
    p.add_argument("--dig-time", type=int, default=2)
    p.add_argument("--dig-tries", type=int, default=1)
    p.add_argument("--tcp", action="store_true", help="also probe dig names over TCP")
    p.add_argument("--out", default="/var/log/dnsprobe")
    p.add_argument("--ingest-endpoint", default="")
    p.add_argument("--dcr", default="")
    args = p.parse_args()

    os.makedirs(args.out, exist_ok=True)
    vm = socket.gethostname()
    path = os.path.join(args.out, f"{args.run_id}_{vm}_{args.profile}.csv")
    w = Writer(path, {"vm": vm, "os": "linux", "design": args.design.upper(), "profile": args.profile})

    if args.start_at:
        time.sleep(max(0.0, args.start_at - time.time()))
    end_at = args.end_at or time.time() + args.duration

    stop = threading.Event()
    threads = []
    jobs = [(n, "os", "") for n in args.names.split(",") if n]
    servers = [s for s in args.servers.split(",") if s]
    for n in [n for n in args.dig_names.split(",") if n]:
        for s in servers:
            jobs.append((n, "dig", s))
            if args.tcp:
                jobs.append((n, "dig-tcp", s))
    jobs.append(("-", "resolvectl", ""))
    for name, method, server in jobs:
        t = threading.Thread(target=worker, args=(stop, w, name, method, server, args), daemon=True)
        t.start()
        threads.append(t)

    stop.wait(max(0.0, end_at - time.time()))
    stop.set()
    for t in threads:
        t.join(timeout=15)
    w.close()

    if args.ingest_endpoint and args.dcr:
        n = ingest(path, args.ingest_endpoint, args.dcr, args.run_id)
        print(f"ingested {n} rows from {path}")
    else:
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
