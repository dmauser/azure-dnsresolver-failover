# 20261023T020835-F2-resolved-default-r1

- 2026-10-23T02:12:10.648000+00:00 inject_start design=b
- 2026-10-23T02:12:15.772000+00:00 inject_done design=b
- 2026-10-23T02:15:06.698000+00:00 restore_start design=b
- 2026-10-23T02:15:10.501000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 41.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 54.0 | 100.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 26.0 | 50.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.4 |  |  |  | TIMEOUT:84 | 2020.0 | 2025.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 92.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 45.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 69.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 25.0 | 62.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 23.0 | 52.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 75.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 26.0 | 53.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 18.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 41.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 84.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 13.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 6.0 | 22.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 24.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 79.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 13.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 179.5 |  |  |  | TIMEOUT:24 | 7031.0 | 7088.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 35.0 | 53.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 20.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 35.0 | 58.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 7.0 | 31.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 4.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 32.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 65.0 | 83.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 2.0 | 16.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 4.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 10.0 | 33.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 100.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 69.0 | 87.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 37.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 44.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 10.0 | 37.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 68.0 | 87.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 33.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 23.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5042.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 85.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 41.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 8.0 | 27.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 16.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 74.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 24.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 25.0 | 44.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:342 |  | 51.0 | 79.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.1 | r1:342 |  | 27.0 | 47.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  | 0.8 |  | TIMEOUT:84 | 2021.0 | 2025.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:342 |  | 51.5 | 66.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 23.0 | 45.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:342 |  | 54.0 | 80.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 28.0 | 70.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 26.0 | 53.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:342 |  | 52.0 | 76.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 28.0 | 50.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 0.0 | 32.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 5.8 |  | r2:332;r1:1 |  | 0.0 | 5035.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 0.4 | 0.0 | r2:336 |  | 65.0 | 89.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 0.0 | 15.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.5 | r1:336 |  | 3.0 | 27.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:342 |  | 0.0 | 22.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 4.7 | 4.0 | r2:327;r1:9 |  | 0.0 | 73.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:336 |  | 0.0 | 11.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.4 |  | 0.8 |  | TIMEOUT:24 | 7028.0 | 7133.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:336 |  | 36.0 | 56.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.3 | r1:335 |  | 4.0 | 29.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:335 |  | 34.0 | 53.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 99.7 | 100.0 | 7.5 |  | 0.4 | r1:322 | TIMEOUT:1 | 7.0 | 7028.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 5.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5034.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 183.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 36.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 68.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 84.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10.0 |
