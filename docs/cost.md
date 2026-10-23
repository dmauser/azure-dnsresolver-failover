# Lab cost estimate

Retail list prices (USD, pay-as-you-go), from the [Azure Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices) and the [Azure DNS pricing page](https://azure.microsoft.com/pricing/details/dns/), checked when the lab was built. Your agreement may differ.

## Default deployment (Design B only)

| Item | Qty | Unit price | ≈ per hour |
|---|---|---|---|
| DNS Private Resolver inbound endpoint | 2 | $180 / month (prorated hourly) | $0.49 |
| DNS Private Resolver outbound endpoint | 2 | $180 / month (prorated hourly) | $0.49 |
| DNS forwarding ruleset | 2 | $2.50 / month | <$0.01 |
| Linux VM `Standard_B2ats_v2` (client B + 2 dnsmasq) | 3 | $0.0094 / h | $0.03 |
| Windows VM `Standard_B2as_v2` (client B) | 1 | $0.0844 / h | $0.08 |
| Private endpoints, private zones, Log Analytics (DNS logs + probe rows, ~20 MB/run), storage, DNS security policy queries | – | small at lab volume | ~$0.05 |
| **Total** | | | **≈ $1.1 / h (≈ $27 / day)** |

## Optional add-ons

| Add-on | How | ≈ extra per hour |
|---|---|---|
| Comparison designs A, C, D (3 Linux + 1 Windows client, 1 extra outbound endpoint, spoke rulesets) | `deploy.ps1 -IncludeComparisonDesigns` | +$0.40 (total ≈ $1.5/h) |
| Emulated on-premises, **VNet peering** (default): 2 BIND + 2 client Linux VMs, 4 peerings | `deploy-onprem.ps1` | +$0.04, plus peering data charges (per GB, negligible for DNS) |
| Emulated on-premises, **VPN Gateway**: same VMs plus 4 × `VpnGw1AZ` gateways and their public IPs | `deploy-onprem.ps1 -Connectivity Vpn` | +$0.85 to +$0.90, plus ≈ 45 min deployment time |

Resolver endpoints and VPN gateways dominate the cost and are billed whether or not VMs are running, so **tear the lab down** (`scripts/teardown.ps1`, which also removes the on-premises resource groups) when you're done. Auto-shutdown only stops the VMs.

Ways to cut cost:
- Keep the default B-only deployment. Add `-IncludeComparisonDesigns` only if you want to reproduce the [design comparison](design-comparison.md).
- Use `-p deployWindows=false` to save ≈ $0.08/h.
- Use VNet peering for the on-premises emulation. Use VPN only if you specifically need to test over IPsec.
