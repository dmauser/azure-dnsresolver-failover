#!/usr/bin/env python3
"""Summarise DNS failover runs.

Usage:  python scripts/analyze.py results/raw/<run-id> [results/raw/<run-id> ...]
        python scripts/analyze.py --all            # every run under results/raw

Per run it writes  <run>/summary.csv, <run>/summary.md and <run>/timeline.png
and (with several runs) results/summary.md aggregating all of them.

Definitions (all from probe timestamps vs. the UTC injection event log):
  ok          rcode NOERROR with a non-empty answer
  fail_ok%    success rate between inject_done and restore_start
  max_gap_s   longest stretch with no successful answer, from inject_start to end of run
              (includes the latency of the query that finally succeeded)
  region      which inbound endpoint answered whoami: r1=10.255.1.1, r2=10.255.2.2
  failback_s  restore_done -> first whoami answer from r1 that is not followed by r2 again
"""
import argparse
import glob
import json
import os
import sys

import pandas as pd

REGION = {"10.255.1.1": "r1", "10.255.2.2": "r2"}


def load(run_dir):
    ev = pd.read_csv(os.path.join(run_dir, "events.csv"), parse_dates=["ts"]) if os.path.exists(
        os.path.join(run_dir, "events.csv")
    ) else pd.DataFrame(columns=["ts", "event"])
    meta = json.load(open(os.path.join(run_dir, "run.json"))) if os.path.exists(os.path.join(run_dir, "run.json")) else {}
    frames = []
    # Per-VM probe CSVs may be gzip-compressed (*.csv.gz) to keep the repo small.
    for f in glob.glob(os.path.join(run_dir, "*.csv")) + glob.glob(os.path.join(run_dir, "*.csv.gz")):
        if os.path.basename(f) in ("events.csv", "summary.csv"):
            continue
        d = pd.read_csv(f, dtype=str, keep_default_na=False)
        if d.empty:
            continue
        frames.append(d)
    if not frames:
        raise SystemExit(f"no probe CSVs in {run_dir}")
    df = pd.concat(frames, ignore_index=True)
    df = df[df["method"] != "resolvectl"]  # resolver-state snapshots, not DNS probes
    df["ts"] = pd.to_datetime(df["ts"], utc=True, format="ISO8601")
    df["ms"] = pd.to_numeric(df["ms"], errors="coerce")
    df["ok"] = (df["rcode"] == "NOERROR") & (df["answer"] != "")
    df["region"] = df["answer"].map(lambda a: REGION.get(a.split(";")[0], "") if a else "")
    df["end"] = df["ts"] + pd.to_timedelta(df["ms"].fillna(0), unit="ms")
    if not ev.empty:
        ev["ts"] = pd.to_datetime(ev["ts"], utc=True, format="ISO8601")
    return df, ev, meta


def t(ev, name):
    r = ev[ev["event"] == name]
    return r["ts"].iloc[0] if len(r) else None


def max_gap(g, start, stop):
    """Longest interval with no successful answer completing, within [start, stop]."""
    oks = g[(g["ok"]) & (g["end"] >= start) & (g["ts"] <= stop)]["end"].sort_values()
    points = [start] + list(oks) + [stop]
    gaps = [(b - a).total_seconds() for a, b in zip(points, points[1:])]
    return round(max(gaps), 1) if gaps else None


def summarise(df, ev, meta):
    inj_s, inj_d = t(ev, "inject_start"), t(ev, "inject_done")
    res_s, res_d = t(ev, "restore_start"), t(ev, "restore_done")
    end = df["ts"].max()
    rows = []
    keys = ["vm", "os", "design", "profile", "name", "method", "server"]
    for k, g in df.groupby(keys):
        g = g.sort_values("ts")
        r = dict(zip(keys, k))
        r["run_id"] = meta.get("run_id", "")
        r["failure"] = meta.get("failure", "")
        if inj_d is None:
            r["n"] = len(g)
            r["ok%"] = round(100 * g["ok"].mean(), 1)
            r["p50_ms"] = g["ms"].median()
            rows.append(r)
            continue
        base = g[g["ts"] < inj_s]
        fail = g[(g["ts"] >= inj_d) & (g["ts"] < res_s)]
        rec = g[g["ts"] >= res_d]
        r["base_ok%"] = round(100 * base["ok"].mean(), 1) if len(base) else None
        r["fail_ok%"] = round(100 * fail["ok"].mean(), 1) if len(fail) else None
        r["rec_ok%"] = round(100 * rec["ok"].mean(), 1) if len(rec) else None
        r["fail_p50_ms"] = fail["ms"].median() if len(fail) else None
        r["fail_max_ms"] = fail["ms"].max() if len(fail) else None
        r["max_gap_s"] = max_gap(g, inj_s, end)
        fails = fail[~fail["ok"]]
        r["fail_rcodes"] = ";".join(f"{c}:{n}" for c, n in fails["rcode"].value_counts().items())
        if r["name"].startswith("whoami"):
            r["base_region"] = base[base["ok"]]["region"].mode().iloc[0] if base["ok"].any() else ""
            fr = fail[fail["ok"]]["region"].value_counts()
            r["fail_regions"] = ";".join(f"{a}:{b}" for a, b in fr.items())
            first_r2 = fail[(fail["ok"]) & (fail["region"] == "r2")]
            r["to_r2_s"] = round((first_r2["end"].iloc[0] - inj_d).total_seconds(), 1) if len(first_r2) else None
            recok = rec[rec["ok"]]
            if len(recok):
                last_r2 = recok[recok["region"] == "r2"]["ts"].max() if (recok["region"] == "r2").any() else None
                after = recok[recok["region"] == "r1"]
                if last_r2 is not None:
                    after = after[after["ts"] > last_r2]
                r["failback_s"] = round((after["ts"].iloc[0] - res_d).total_seconds(), 1) if len(after) else None
        rows.append(r)
    return pd.DataFrame(rows)


def timeline(df, ev, out, meta):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    sel = df[(df["name"].str.startswith("whoami")) & (df["method"] == "os")].copy()
    if sel.empty:
        return
    clients = sorted(sel.groupby(["design", "os", "vm"]).groups.keys())
    fig, ax = plt.subplots(figsize=(12, 0.6 * len(clients) + 1.5))
    colors = {"r1": "tab:blue", "r2": "tab:orange", "": "tab:red"}
    t0 = sel["ts"].min()
    for i, (d, o, vm) in enumerate(clients):
        g = sel[(sel["design"] == d) & (sel["os"] == o) & (sel["vm"] == vm)]
        x = (g["ts"] - t0).dt.total_seconds()
        c = [colors["" if not ok else reg] for ok, reg in zip(g["ok"], g["region"])]
        ax.scatter(x, [i] * len(g), c=c, s=6, marker="|")
    for name, style in (("inject_done", "--"), ("restore_done", ":")):
        tt = t(ev, name) if not ev.empty else None
        if tt is not None:
            ax.axvline((tt - t0).total_seconds(), color="k", ls=style, lw=1, label=name)
    ax.set_yticks(range(len(clients)))
    ax.set_yticklabels([f"{d} {o}" for d, o, _ in clients])
    ax.set_xlabel("seconds since probe start")
    ax.set_title(f"{meta.get('failure', '')} {meta.get('linux_profile', '')}: whoami via OS resolver  "
                 "(blue=r1 IE, orange=r2 IE, red=failed)")
    ax.legend(loc="upper right", fontsize=8)
    fig.tight_layout()
    fig.savefig(out, dpi=110)
    plt.close(fig)


COLS = ["design", "os", "profile", "name", "method", "server", "base_ok%", "fail_ok%", "rec_ok%", "max_gap_s",
        "to_r2_s", "failback_s", "fail_regions", "fail_rcodes", "fail_p50_ms", "fail_max_ms"]


def to_md(s):
    cols = [c for c in COLS if c in s.columns]
    s = s[cols].fillna("")
    lines = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    for _, r in s.iterrows():
        lines.append("| " + " | ".join(str(r[c]) for c in cols) + " |")
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("runs", nargs="*")
    p.add_argument("--all", action="store_true")
    a = p.parse_args()
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results", "raw")
    runs = sorted(glob.glob(os.path.join(root, "*"))) if a.all else a.runs
    allsum = []
    for run in runs:
        if not os.path.isdir(run):
            continue
        try:
            df, ev, meta = load(run)
        except SystemExit as e:
            print(e, file=sys.stderr)
            continue
        s = summarise(df, ev, meta).sort_values(["name", "method", "design", "os", "server"])
        s.to_csv(os.path.join(run, "summary.csv"), index=False)
        with open(os.path.join(run, "summary.md"), "w") as fh:
            fh.write(f"# {meta.get('run_id', os.path.basename(run))}\n\n")
            if not ev.empty:
                for _, e in ev.iterrows():
                    fh.write(f"- {e['ts'].isoformat()} {e['event']} {e.get('detail', '')}\n")
                fh.write("\n")
            fh.write(to_md(s) + "\n")
        timeline(df, ev, os.path.join(run, "timeline.png"), meta)
        allsum.append(s)
        print(f"{run}: {len(df)} rows -> summary.md, timeline.png")
    if len(allsum) > 1:
        agg = pd.concat(allsum)
        key = agg[(agg["method"] == "os")]
        with open(os.path.join(root, "..", "summary.md"), "w") as fh:
            fh.write("# All runs (OS resolver path)\n\n")
            for rid, g in key.groupby("run_id"):
                fh.write(f"## {rid}\n\n{to_md(g)}\n\n")


if __name__ == "__main__":
    main()
