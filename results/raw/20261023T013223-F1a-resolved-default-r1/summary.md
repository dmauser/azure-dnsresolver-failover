# 20261023T013223-F1a-resolved-default-r1

- 2026-10-23T01:35:57.819000+00:00 inject_start design=b
- 2026-10-23T01:36:01.403000+00:00 inject_done design=b
- 2026-10-23T01:38:55.373000+00:00 restore_start design=b
- 2026-10-23T01:39:01.298000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 180.3 |  |  |  | TIMEOUT:86 | 2020.0 | 2027.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 99.2 | 100.0 | 99.7 | 2.6 |  |  |  |  | 53.0 | 68.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 62.1 | 100.0 | 18.7 |  |  |  | TIMEOUT:61 | 27.0 | 2027.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 71.3 |  |  |  | TIMEOUT:85 | 2021.0 | 2028.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 53.0 | 73.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 150.0 |  |  |  | TIMEOUT:85 | 2021.0 | 2026.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 53.0 | 71.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 50.7 | 100.0 | 28.8 |  |  |  | TIMEOUT:68 | 1777.5 | 2026.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 180.4 |  |  |  | TIMEOUT:86 | 2021.0 | 2027.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 99.7 | 100.0 | 2.5 |  |  |  | TIMEOUT:1 | 55.0 | 2023.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 98.5 | 100.0 | 2.5 |  |  |  | TIMEOUT:5 | 53.0 | 2021.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 94.9 | 100.0 | 36.3 |  |  |  | NXDOMAIN:8 | 0.0 | 10015.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5035.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 54.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 41.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 61.0 | 100.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 50.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 72.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 183.3 |  |  |  | TIMEOUT:24 | 7025.0 | 7082.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 36.0 | 55.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 183.3 |  |  |  | TIMEOUT:24 | 7025.0 | 7054.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 35.5 | 55.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 87.2 | 100.0 | 14.1 |  |  |  | SERVFAIL:11;TIMEOUT:8 | 7.0 | 7056.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 23.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 34.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 90.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 0.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 87.1 | 100.0 | 34.0 |  |  |  | NXDOMAIN:9 | 11.0 | 10015.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 49.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 23.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 5042.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.0 |  |  |  |  | 67.0 | 584.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.5 |  |  |  |  | 41.0 | 2067.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 25.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 1.2 |  |  |  |  | 67.0 | 709.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 98.6 | 100.0 | 20.6 |  |  |  | NXDOMAIN:3 | 0.0 | 10016.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 54.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 21.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 4.2 |  |  |  |  | 0.0 | 3677.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 61.0 | 86.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 2.2 |  |  |  |  | 0.0 | 1668.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 86.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 180.3 |  | 0.1 |  | TIMEOUT:86 | 2020.0 | 2027.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:348 |  | 52.0 | 67.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 64.3 | 99.7 | 14.7 |  | 0.0 | r1:108 | TIMEOUT:60 | 26.0 | 2027.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 4.5 | 100.0 | 123.8 |  | 0.1 | r1:4 | TIMEOUT:85 | 2021.0 | 2028.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.2 |  | r2:348 |  | 51.5 | 115.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 5.6 | 100.0 | 53.1 |  | 0.1 | r1:5 | TIMEOUT:85 | 2021.0 | 2028.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 99.2 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:348 |  | 51.5 | 75.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 50.7 | 100.0 | 18.7 |  | 0.3 | r1:71 | TIMEOUT:69 | 42.0 | 2026.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 105.6 |  | 0.6 | r1:2 | TIMEOUT:85 | 2021.0 | 2025.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 99.2 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:348 |  | 55.0 | 80.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 98.5 | 100.0 | 2.5 | 6.7 | 160.4 | r2:296;r1:32 | TIMEOUT:5 | 54.0 | 2024.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 98.0 | 100.0 | 31.2 |  | 0.3 | r1:195 | NXDOMAIN:4 | 0.0 | 10013.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 4.6 |  | r2:339;r1:9 |  | 0.0 | 44.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 55.9 | 0.2 | r1:340;r2:2 |  | 3.0 | 61.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 30.7 |  | r2:288;r1:51 |  | 0.0 | 5037.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 17.4 | 0.2 | r2:186;r1:156 |  | 60.0 | 83.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 28.1 | 143.8 | r2:292;r1:56 |  | 0.0 | 51.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 5.8 | r1:341 |  | 0.0 | 22.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 35.1 | 2.1 | r2:208;r1:135 |  | 0.0 | 71.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 4.0 | 100.0 | 106.0 |  | 3.1 | r1:1 | TIMEOUT:24 | 7026.0 | 7110.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:342 |  | 36.0 | 57.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 183.4 |  | 2.5 |  | TIMEOUT:24 | 7024.0 | 7075.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:342 |  | 35.0 | 54.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 84.6 | 100.0 | 18.8 |  | 0.2 | r1:99 | SERVFAIL:12;TIMEOUT:6 | 8.0 | 7048.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 5.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 52.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 71.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 50.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 69.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 7.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 9.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 10.0 |
