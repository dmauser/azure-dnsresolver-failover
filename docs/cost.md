# Lab cost estimate

Retail list prices (USD, pay-as-you-go), from the [Azure Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices) and the [Azure DNS pricing page](https://azure.microsoft.com/pricing/details/dns/), checked when the lab was built. Your agreement may differ.

| Item | Qty | Unit price | ≈ per hour |
|---|---|---|---|
| DNS Private Resolver inbound endpoint | 2 | $180 / month (prorated hourly) | $0.49 |
| DNS Private Resolver outbound endpoint | 3 | $180 / month (prorated hourly) | $0.74 |
| DNS forwarding ruleset | 4 | $2.50 / month | $0.01 |
| Linux VM `Standard_B2ats_v2` (4 clients + 2 dnsmasq) | 6 | $0.0094 / h | $0.06 |
| Windows VM `Standard_B2as_v2` (clients B, C) | 2 | $0.0844 / h | $0.17 |
| Private endpoints, private zones, Log Analytics, storage, DNS security policy queries | – | small at lab volume | ~$0.05 |
| **Total** | | | **≈ $1.5 / h (≈ $36 / day)** |

Resolver endpoints dominate the cost and are billed whether or not VMs are running, so **tear the lab down** (`scripts/teardown.ps1`) when you are done. Auto-shutdown only stops the VMs.

Ways to cut cost: `-p deployWindows=false` (saves ≈ $0.17/h), and skip Design D (removes the second outbound endpoint, ≈ $0.25/h) by deleting `out2-r1` and `dnsfrs-dnsfo-spoke-r1-d` after deployment.
