# 20261023T024803-F6-resolved-default-r1

- 2026-10-23T02:51:37.319000+00:00 inject_start design=b
- 2026-10-23T02:51:39.130000+00:00 inject_done design=b
- 2026-10-23T02:54:34.454000+00:00 restore_start design=b
- 2026-10-23T02:54:36.353000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 21.0 | 37.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 53.0 | 70.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 25.0 | 53.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 44.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 78.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 51.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 77.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 4.0 | 97.5 | 173.5 |  |  |  | NXDOMAIN:336 | 21.0 | 107.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 41.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 51.0 | 90.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 98.4 | 100.0 | 99.4 | 2.5 |  |  |  |  | 25.0 | 77.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 28.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 37.7 | 100.0 | 109.1 |  |  |  | NXDOMAIN:218 | 4.0 | 94.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 5.2 | 96.5 | 161.4 |  |  |  | NXDOMAIN:326 | 3.0 | 70.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 50.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 15.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 7.8 | 96.3 | 170.6 |  |  |  | NXDOMAIN_OR_FAIL:317 | 0.0 | 22.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 18.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 36.0 | 50.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 23.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 35.0 | 55.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 4.7 | 97.7 | 170.6 |  |  |  | NXDOMAIN:328 | 3.0 | 94.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 26.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 29.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 5.8 | 97.7 | 142.0 |  |  |  | NXDOMAIN:324 | 3.0 | 71.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 10.0 | 28.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 7.0 | 22.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 6.0 | 36.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 36.4 | 100.0 | 114.1 |  |  |  | NXDOMAIN:217 | 10.0 | 5035.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 5.8 | 97.7 | 163.0 |  |  |  | NXDOMAIN:324 | 2.0 | 70.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.6 |  |  |  |  | 13.0 | 59.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 5.0 | 36.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 3.5 | 95.1 | 180.2 |  |  |  | NXDOMAIN_OR_FAIL:332 | 0.0 | 49.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 15.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 21.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 26.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 37.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 20.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 1.2 |  |  |  |  | 0.0 | 654.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 14.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 12.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 25.0 | 46.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:350 |  | 52.0 | 66.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.2 | r1:350 |  | 27.0 | 52.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 26.0 | 42.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:350 |  | 53.0 | 66.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 22.0 | 46.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:350 |  | 53.0 | 85.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 4.6 | 97.5 | 169.1 |  | 3.2 | r1:16 | NXDOMAIN:334 | 25.0 | 109.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 25.0 | 56.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:350 |  | 52.0 | 70.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 98.4 | 100.0 | 100.0 | 0.6 | 0.5 | 174.8 | r1:219;r2:131 |  | 26.0 | 168.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 0.0 | 21.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:350 |  | 0.0 | 15.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.3 | r1:344 |  | 3.0 | 22.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 43.4 | 100.0 | 100.6 | 120.5 |  | r2:111;r1:37 | NXDOMAIN:193 | 3.0 | 5042.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 4.9 | 96.8 | 165.9 | 6.4 | 4.8 | r1:12;r2:5 | NXDOMAIN:327 | 3.0 | 82.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.6 | 3.4 | 172.8 | r1:239;r2:111 |  | 0.0 | 45.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:344 |  | 0.0 | 15.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 6.7 | 97.4 | 170.6 |  | 4.8 | r1:23 | NXDOMAIN_OR_FAIL:321 | 0.0 | 48.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 99.7 | 100.0 | 7.5 |  | 0.0 | r1:331 | TIMEOUT:1 | 4.0 | 7017.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:344 |  | 36.0 | 68.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.1 | r1:345 |  | 4.0 | 18.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.2 |  | r2:344 |  | 35.0 | 71.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 3.5 | 96.8 | 174.1 |  | 4.3 | r1:12 | NXDOMAIN:332 | 3.0 | 91.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 4.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 25.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 28.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 62.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 80.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8.0 |
