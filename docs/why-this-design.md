# Why this design: comparing four ways to point Azure VMs at DNS Private Resolver

← Back to the [recommended reference architecture](../README.md)

> **Scope.** This page compares four ways to point Azure VMs at DNS Private Resolver. The recommended architecture on the main page is **Design B** — spoke VNet DNS servers set to the inbound endpoints of **both** regions. This page covers the **Azure VM → resolver** path. On-premises → Azure failover is covered by the [Microsoft Learn tutorial](https://learn.microsoft.com/azure/dns/tutorial-dns-private-resolver-failover) and by the on-premises extension of this lab ([README](../README.md#on-premises-extension)).
>
> **Evidence rule.** Every statement is either **measured** in this lab (run IDs in [results/summary.md](../results/summary.md)) or **cited** to Microsoft Learn. Anything else is labelled *hypothesis* or *inference*.
>
> **Historical results.** The A–D comparison below was measured on an **earlier lab topology** in which four spokes in r1 were peered directly to **both** hubs. The current lab implements only Design B on a CAF-style hub-spoke with NVA routers between the regional hubs; the comparison designs are no longer deployable from this repo. The numbers are kept as the evidence behind the recommendation.

## TL;DR

| If you need… | Use | Why (measured) |
|---|---|---|
| Fastest, simplest failover for VMs | **Design B** – spoke VNet DNS = `[IE r1, IE r2]` | 100 % OS-level success in every failure mode; Linux switched to r2 in ≈ 5 s |
| Keep 168.63.129.16 on the VNet and fail over centrally | **Design D** – ruleset rule with targets `[IE r1, IE r2]` | ≥ 98 % in every mode; switch ≈ 7–28 s; **sticky failback ≈ 2.5 min**; shares fate with r1's outbound endpoint |
| — | Avoid **Design C** `[168.63.129.16, IE r2]` | Works when IE r1 times out, but a ruleset misconfiguration returns NXDOMAIN and clients **never** try IE r2 (5–38 % success) |
| — | Avoid **Design A** (single target) for HA | No failover path: 29–95 % success while IE r1 is down |

Long TTLs hide short outages (app2, TTL 3600: ≥ 96.6 % even on Design A) but they don't fix anything — answers expire eventually.

![Comparison lab topology (designs A–D)](diagrams/dns-resolver-failover-lab.png)

*Historical comparison topology (designs A–D). Editable source: [diagrams/dns-resolver-failover-lab.drawio](diagrams/dns-resolver-failover-lab.drawio).*

## 1. Topology (historical)

| Component | Region 1 (eastus2) | Region 2 (centralus) |
|---|---|---|
| Hub VNet | `10.10.0.0/22` | `10.20.0.0/22` |
| Resolver inbound endpoint (IE) | `10.10.0.4` | `10.20.0.4` |
| Resolver outbound endpoints | `out1` (designs A/C), `out2` (design D) | `out1` |
| Simulated on-prem DNS (dnsmasq) | `10.10.1.10` | `10.20.1.10` |
| Spokes A–D (`10.11.0-3.0/24`) | all in r1, each peered to **both** hubs | — |

Private DNS zones (`azure.contoso.internal`, `privatelink.blob.core.windows.net`, `lab.contoso.internal`) are linked to both hubs. `whoami.lab.contoso.internal` is a different zone per region (`10.255.1.1` in r1, `10.255.2.2` in r2), so every answer shows which region's resolver served it.

### Client designs

| Design | Spoke VNet DNS | Spoke ruleset | Clients |
|---|---|---|---|
| **A** | Azure-provided `168.63.129.16` | `*.contoso.internal` → `[IE r1]` | Linux |
| **B** | Custom `[IE r1, IE r2]` | none | Linux, Windows |
| **C** | Custom `[168.63.129.16, IE r2]` | `*.contoso.internal` → `[IE r1]` | Linux, Windows |
| **D** | Azure-provided `168.63.129.16` | `*.contoso.internal` → `[IE r1, IE r2]` (via `out2`) | Linux |

Probes query four names every second (`app1` TTL 10 s, `app2` TTL 3600 s, a private-endpoint name, and an on-prem name via dnsmasq) through the OS resolver, plus direct `dig`/`Resolve-DnsName -Server` queries to each server so client-side and server-side behaviour can be told apart. Linux runs two profiles: stock `systemd-resolved` (`resolved-default`) and `glibc-tuned` (`options timeout:1 attempts:2 rotate`).

## 2. What Microsoft Learn says

| Topic | Source | Statement |
|---|---|---|
| Regional scope | [Reliability in DNS Private Resolver](https://learn.microsoft.com/azure/reliability/reliability-dns-private-resolver) | A resolver is a regional resource; for regional resilience deploy one per region. |
| Multi-region pattern | [Hybrid DNS – multiregional design](https://learn.microsoft.com/azure/architecture/hybrid/hybrid-dns-infra#multiregional-design) | Recommends a resolver per region. |
| Failover tutorial | [Tutorial: resolver failover](https://learn.microsoft.com/azure/dns/tutorial-dns-private-resolver-failover) | Covers **on-premises** conditional forwarders pointing at two IEs. Doesn't cover Azure VMs. |
| Multiple targets | [Endpoints and rulesets](https://learn.microsoft.com/azure/dns/private-resolver-endpoints-rulesets#dns-forwarding-rulesets) | Several targets per rule are allowed; an **exponential backoff** algorithm decides whether a target is responsive. 168.63.129.16 can't be a target. A ruleset can only be linked to VNets in its own region. |
| Limits | [Overview – restrictions](https://learn.microsoft.com/azure/dns/dns-private-resolver-overview#restrictions) | Up to 6 target DNS servers per rule; up to 2 rulesets per outbound endpoint. |
| VM DNS client | [Name resolution for VMs – DNS client configuration](https://learn.microsoft.com/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances#dns-client-configuration) | Guest OS timeout/retry behaviour determines how quickly a client moves to the next server; DNS changes need a DHCP lease renewal or reboot. |

## 3. Failure injections

None of these is a real regional outage — see [§6 Fidelity limits](#6-fidelity-limits). Each run is 2 min baseline, 5 min failure and 3 min recovery unless stated otherwise. These are the injections used for the historical comparison; F1b and F6 are not available in the current lab, and F2/F3 now target the hub ↔ hub peering and the r1 NVA router (see the [README](../README.md#failure-injections)).

| ID | Injection | Emulates |
|---|---|---|
| F1a | NSG deny TCP+UDP/53 inbound on the r1 **inbound-endpoint subnet** | IE r1 unreachable from everywhere |
| F1b | NSG deny 53 outbound from one spoke to IE r1 | Path loss from one spoke (not enforced in this lab, see results) |
| F1c | F1a + NSG deny 53 outbound on r1 **outbound-endpoint subnets** | Loss of the whole r1 resolver |
| F2 | UDR `IE r1/32 → None` on a spoke | Routing black hole |
| F3 | Delete spoke ↔ hub r1 peering | Peering loss |
| F4 | Delete the r1 inbound endpoint, then recreate it | Real endpoint removal |
| F5u | F1a for UDP only | UDP-only loss (TCP fallback?) |
| F6 | Unlink the spoke ruleset from spoke C | Ruleset misconfiguration → 168.63.129.16 returns NXDOMAIN |

**Finding (measured, undocumented):** NSG rules and UDRs **are enforced** on the delegated resolver subnets. F1a/F1c produce timeouts at IE r1 within seconds, and removing the rule restores service. This makes NSGs a practical way to rehearse failover.

## 4. Results

OS-level success rate for `app1` (TTL 10 s) **during the failure window**. Linux = `resolved-default` unless marked.

| Failure | A | B Linux | B Windows | C Linux | C Windows | D |
|---|---|---|---|---|---|---|
| F1a (IE r1 blocked) | 94.9 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| F1a, glibc-tuned | 68.3 % | 100 % | — | 100 % | — | 99.4 % |
| F1c (r1 resolver blocked) | 95.2 % | 100 % | 100 % | 100 % | 100 % | 98.0 % |
| F2 (UDR, spoke B) | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| F3 (peering, spoke B) | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| F4 (IE r1 deleted) | **28.6 %** | 100 % | 100 % | 100 % | 100 % | 100 % |
| F6 (spoke C unlinked) | 100 % | 100 % | 100 % | **37.7 %** | **5.2 %** | 100 % |
| F5u (IE r1 UDP only) | 100 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| F1b (spoke B outbound deny) | — | *not enforced* | *not enforced* | — | — | — |

> **F1b was not a valid injection.** An outbound `Deny` on spoke B's client-subnet NSG (destination IE r1/32, port 53, priority 100) appeared under *Effective security rules* on the client NIC. Fresh UDP and TCP queries from that VM to IE r1 still succeeded, and direct `dig @IE-r1` stayed at 100 %. We did not find an explanation for this on Microsoft Learn. To rehearse a path loss from one spoke, use **F2** (UDR to `None`) or **F3** (peering removal).

Failover and failback timing (time from injection to first answer from r2, and from restore to first answer from r1 again):

| Design | Switch to r2 | Failback to r1 | Notes |
|---|---|---|---|
| A | never | — | Errors are NXDOMAIN (after IE r1 times out) or SERVFAIL/timeout |
| B Linux | ≈ 4.6 s | immediate | systemd-resolved moves to the next server and stays there until it fails |
| B Windows | ≈ 17–56 s per query path | immediate | Windows DNS client re-orders servers after a timeout |
| C Linux / Windows | ≈ 31 s / ≈ 17 s | immediate | Works only because 168.63.129.16 **times out** rather than returning NXDOMAIN |
| D | ≈ 7 s (`dig @168.63.129.16`), ≈ 11–28 s (OS) | **≈ 144–173 s (sticky)** | Consistent with the documented exponential backoff on targets |
| F5u (UDP-only loss) | B 8.8 s / 27.4 s (Linux/Win); C 38.4 s / 27.6 s; D 25.4 s | D ≈ 169 s | Clients didn't retry over TCP; A kept answering from cache |

Full per-run tables (all names, methods, rcodes, p50/max latency) and timeline charts are in [`results/raw/<run>/summary.md`](../results/summary.md).

> **Re-test on the hub-spoke topology.** The numbers above come from the original flat-peering lab. Design B was re-tested after the move to the CAF hub-spoke topology with NVA routers (runs `20261023T2046…` to `20261023T2121…`):
> - F1a: Linux max gap ≈ 5.5 s (on r2 after ≈ 8.5 s). Windows max gap < 1 s, but it stayed on r2 for ≈ 110 s. On-prem BIND 0.5–1.8 s. Still 100 % success through the OS resolver.
> - F2 (hub peering removed) and F3 (NVA down): no client impact (gaps 0.5–1.4 s). Failback ≤ 0.5 s.
> - On-prem link break: the site lost Azure private names for the full ≈ 180 s, because each site now attaches to one hub only. In the flat lab it recovered in ≈ 0.4 s because it could reach both hubs.

### Key observations

1. **Design A has no regional failover.** While IE r1 is down, 168.63.129.16 forwards to a dead target and returns SERVFAIL, timeout or — after F4 deletes the endpoint — NXDOMAIN (35 NXDOMAINs in 5 min). The 95 % figures for F1a/F1c come from the 10-second cache plus systemd-resolved serving stale answers. With `glibc-tuned`, which has no cache, A drops to 68 %.
2. **Design B is the most robust**, because the guest OS owns the failover. The cost is latency: with glibc-tuned, every query that tries IE r1 first pays a ≈ 1 s timeout (p50 ≈ 1 s) unless `rotate` happens to pick IE r2.
3. **Design C depends on the error type.** When IE r1 is unreachable, `dig @168.63.129.16` succeeds only 51 % of the time (TIMEOUT) and Windows sees SERVFAIL/TIMEOUT. Both make the OS try IE r2, so the OS level stays at 100 %. When the ruleset is missing (F6), 168.63.129.16 answers **NXDOMAIN** authoritatively. That is a valid answer, so no client tries IE r2: 37.7 % (Linux) and 5.2 % (Windows).
4. **Design D fails over inside Azure**, with no client change, but:
   - Failback is **sticky**: traffic stays on IE r2 for ≈ 2.5–3 min after IE r1 recovers. This is harmless when both regions serve the same zones, but it matters if answers differ per region.
   - It **shares fate with r1's outbound endpoint**. F1c (outbound blocked too) still reached 98 %, which suggests forwarding from the outbound endpoint wasn't fully cut by the outbound NSG (*inference*). A real r1 regional outage would take out the outbound endpoint and its ruleset, and a ruleset can only be linked to same-region VNets (cited above). For true regional independence, D needs a second ruleset in r2 linked to r2 spokes — it can't protect r1 spokes from loss of the r1 resolver itself.
5. **Path-local failures (F2, F3)** only affect clients that talk to IE r1 directly (B). B's OS resolver routes around them; A, C and D never use that path.
6. **UDP-only loss isn't rescued by TCP (F5u).** With only UDP/53 blocked to IE r1, direct queries to IE r1 succeeded 0–1 %. Neither `dig` nor the Windows DNS client fell back to TCP after a UDP timeout; TCP fallback is normally triggered by a truncated (TC) answer, not by silence. The OS level stayed at 100 % only because each design moved to IE r2, as in F1a.
7. **Not every NSG placement works as a drill (F1b).** A deny on the *client* subnet's outbound rules was ignored for traffic to the inbound endpoint (see note under the results table), while denies on the *resolver* subnets (F1a, F1c, F5u) worked. Verify that your injection actually breaks resolution, for example with `dig @<IE-r1>`, before you trust a drill result.

## 5. Hypotheses and verdicts

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| H1 | Design A has no regional failover. | **Confirmed** | F4 28.6 %, glibc F1a 68.3 %, never answered from r2 |
| H2 | Design B fails over at the client within the OS resolver timeout. | **Confirmed** | 100 % in all modes; Linux ≈ 4.6 s, Windows up to ≈ 56 s |
| H3 | When IE r1 fails, 168.63.129.16 returns timeout/SERVFAIL, not NXDOMAIN. | **Confirmed for F1a/F1c; refuted for F4 and F6** | F1a: dig@168 TIMEOUT, Win SERVFAIL; F4: NXDOMAIN ×35 on A; F6: NXDOMAIN ×218 on C |
| H4 | Design C survives IE r1 failure. | **Partly** | 100 % for F1a/F1c/F4; 5–38 % for ruleset misconfiguration (F6) |
| H5 | Design D's multi-target rule fails over to IE r2. | **Confirmed** | 98–100 %; switch ≈ 7–28 s |
| H6 | Failback is automatic; D's is delayed. | **Confirmed** | B/C immediate; D ≈ 144–173 s |
| H7 | NSG/UDR on delegated resolver subnets is a valid emulation. | **Confirmed (undocumented)** | F1a/F1c/F5u/F2 take effect within seconds and reverse cleanly; a *client-subnet* outbound NSG deny (F1b) was **not** enforced |
| H8 | Design B depends on spoke ↔ hub r2 reachability. | **Supported** | F3 removes the r1 path and B still reaches 100 % via r2; *hub r2 peering was not removed in this lab* |
| H9 | Design D shares fate with r1's outbound endpoint and ruleset. | **By design (cited); partly measured** | Ruleset scoping is same-region per Learn; F1c didn't fully cut D (98 %) |
| H10 | A long TTL masks short outages. | **Confirmed** | app2 (TTL 3600): A ≥ 96.6 % in every run |

## 6. Fidelity limits

- **No real regional outage.** NSG/UDR/peering/endpoint deletion emulate the loss of *paths* or *endpoints*, not the loss of the regional control plane, the r1 outbound endpoint, or 168.63.129.16 itself.
- **168.63.129.16 can't be failed.** Behaviour when the platform resolver is unavailable isn't measured.
- **Single region pair and VM size**, a few runs per mode; percentages are indicative, not SLA-grade.
- **Client OS defaults** (Ubuntu 24.04, Windows Server 2022) as of October 2026. Results for other versions or tuning will differ.
- **Caching.** systemd-resolved and the Windows DNS client cache answers, which inflates success rates for short outages; direct `dig` columns in per-run tables show the uncached view.

## 7. Recommendations

1. **Prefer Design B** for Azure VMs that need regional DNS resilience: set the VNet DNS servers to the inbound endpoints in **both** regions, the local one first. Keep resolver forwarding rulesets on the hubs for on-prem/other zones.
2. If you must keep 168.63.129.16 on spokes (for example, platform features that depend on it), **use Design D** with multi-target rules, deploy a resolver plus ruleset in each region, and expect ≈ 2.5 min sticky failback.
3. **Don't rely on Design C** for HA. Any condition that makes 168.63.129.16 return NXDOMAIN — a missing ruleset link, wrong domain, unlinked private zone — defeats the fallback.
4. **Tune clients deliberately.** Shorter timeouts reduce failover time but add latency when the first server is down. Linux `systemd-resolved` already stays on a working server; plain glibc with `rotate` spreads that penalty across queries.
5. **Rehearse.** An NSG deny on UDP+TCP 53 on the inbound-endpoint subnet (F1a) is a cheap, reversible failover drill (measured in this lab; not a documented test method).
6. **Monitor from the client side.** Resolver metrics don't show what VMs experience; probe both IEs and 168.63.129.16 from representative spokes.

## 8. Reproduce

The comparison designs A, C and D are historical and are no longer part of the Bicep. The raw data for every comparison run is kept under [`results/raw/`](../results/summary.md). To reproduce the recommended design (B) on the current hub-spoke topology, follow the [README quick start](../README.md#quick-start) ([cost.md](cost.md) has the hourly cost). Tear the lab down with `scripts/teardown.ps1` when you're done.

---

*Analysis only — verify against vendor documentation before applying.*
