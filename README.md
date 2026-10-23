# Azure DNS Private Resolver – regional failover lab

A reproducible lab that measures what Azure VMs actually experience when the **primary-region DNS Private Resolver** becomes unreachable, and how four DNS designs fail over and fail back.

| Design | Spoke VNet DNS setting | Forwarding | What it tests |
|---|---|---|---|
| **A** | Azure-provided (168.63.129.16) | Spoke ruleset → local inbound endpoint only | Distributed pattern, no failover path |
| **B** | Custom: `[IE r1, IE r2]` | none (client talks to both IEs) | Client-side failover (OS resolver order/timeouts) |
| **C** | Custom: `[168.63.129.16, IE r2]` | Spoke ruleset → local IE | Mixed; does the client fall to IE r2? |
| **D** | Azure-provided (168.63.129.16) | Spoke ruleset with **two targets** `[IE r1, IE r2]` | Resolver-side failover via multi-target rules |

Every design runs a Linux client (Ubuntu 24.04); designs B and C also run Windows Server 2022. `whoami.lab.contoso.internal` returns `10.255.1.1` from region 1 and `10.255.2.2` from region 2, so each answer shows which inbound endpoint served it.

- Architecture, findings and guidance: [docs/reference-architecture.md](docs/reference-architecture.md)
- Results: [results/summary.md](results/summary.md)
- Cost: [docs/cost.md](docs/cost.md) (≈ $1.5/hour, dominated by resolver endpoints – **tear down when done**)

## Run it

Prerequisites: PowerShell 7, Azure CLI ≥ 2.60 (Bicep included), Python 3.10+ with `pandas` and `matplotlib`, Contributor + User Access Administrator on the subscription.

1. `az login`
2. Preview and deploy (what-if runs first; you are asked to confirm):
   `./scripts/deploy.ps1 -SubscriptionId <sub-id> -Owner <you>`
   Outputs land in `.secrets/lab.env` (git-ignored). Takes ≈ 30 minutes.
3. Wait ~5 minutes for role assignments to propagate, then run a baseline:
   `./scripts/run-test.ps1 -Failure none -BaselineSec 60 -FailureSec 0 -RecoverySec 0`
4. Run failover/failback experiments (each ≈ 10 min):
   `./scripts/run-test.ps1 -Failure F1a -Repeat 3`
   `./scripts/run-test.ps1 -Failure F1a -LinuxProfile glibc-tuned`
   `./scripts/run-test.ps1 -Failure F4 -FailureSec 300 -RecoverySec 300`
5. Analyse: `python scripts/analyze.py --all` → `results/raw/<run>/summary.md`, `timeline.png`, `results/summary.md`
6. Tear down: `./scripts/teardown.ps1 -SubscriptionId <sub-id>`

## Failure injections (`scripts/inject.ps1`)

| ID | What it does | Primarily affects |
|---|---|---|
| F1a | NSG deny UDP+TCP 53 inbound on the r1 inbound-endpoint subnet | All designs (if enforced on the delegated subnet) |
| F1b | NSG deny 53 outbound to IE r1 on one spoke (`-Design`) | Direct client→IE (B) |
| F1c | F1a + deny 53 outbound on r1 outbound-endpoint subnets ("region-wide resolver loss") | All, incl. D's failover path |
| F2 | UDR `IE r1/32 → None` on one spoke | Direct client→IE (B) |
| F3 | Remove spoke ↔ hub r1 peering | Direct client→IE (B) |
| F4 | Delete the r1 inbound endpoint, then recreate it with the same IP | All designs (real removal) |
| F5u / F5t | F1a for UDP only / TCP only | UDP vs TCP behaviour |
| F6 | Unlink the spoke ruleset from spoke C | What 168.63.129.16 returns when its path is gone |

Each run writes a UTC event log (`events.csv`) and per-VM probe CSVs; the analyzer derives baseline/failure/recovery phases from the event log.

## Repository layout

```
infra/          Bicep (subscription scope) – main.bicep + modules/
scripts/        deploy, teardown, inject, run-test, collect, analyze, probe/ (Linux + Windows probes)
results/raw/    per-run CSVs, summaries and charts
docs/           reference architecture, blog post, doc feedback, cost
```

Lab-only shortcuts (not for production): subnets set `defaultOutboundAccess: true` so VMs can install packages without a NAT gateway, and the results storage account is publicly reachable but accepts Entra ID only (no shared keys). VMs have no public IPs; access is via `az vm run-command`.
