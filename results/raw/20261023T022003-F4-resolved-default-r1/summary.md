# 20261023T022003-F4-resolved-default-r1

- 2026-10-23T02:23:36.535000+00:00 inject_start design=b
- 2026-10-23T02:23:38.556000+00:00 inject_done design=b
- 2026-10-23T02:28:34.721000+00:00 restore_start design=b
- 2026-10-23T02:29:57.689000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 6.5 | 99.8 | 368.2 |  |  |  | TIMEOUT:144 | 2020.0 | 2024.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 79.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 7.6 | 100.0 | 365.5 |  |  |  | TIMEOUT:143;SERVFAIL:2 | 2020.0 | 2025.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 7.1 | 99.8 | 368.3 |  |  |  | TIMEOUT:144 | 2020.0 | 2031.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 85.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 6.5 | 100.0 | 372.5 |  |  |  | TIMEOUT:144 | 2021.0 | 2026.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 71.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 8.9 | 100.0 | 360.4 |  |  |  | TIMEOUT:144 | 2021.0 | 2027.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 6.5 | 100.0 | 372.4 |  |  |  | TIMEOUT:144 | 2021.0 | 2025.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 77.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 99.0 | 99.8 | 10.6 |  |  |  | TIMEOUT:6 | 56.0 | 2024.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 28.6 | 100.0 | 363.1 |  |  |  | NXDOMAIN:35 | 6669.0 | 10022.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 56.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 65.0 | 87.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5041.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 64.0 | 85.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 4.5 |  |  |  |  | 0.0 | 2049.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 73.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 85.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 20.8 | 100.0 | 366.6 |  |  |  | TIMEOUT:42 | 7024.0 | 7114.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 35.0 | 53.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 20.8 | 100.0 | 367.3 |  |  |  | TIMEOUT:42 | 7024.0 | 7124.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 34.0 | 51.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 18.5 | 100.0 | 367.3 |  |  |  | SERVFAIL:31;TIMEOUT:22 | 5612.0 | 7132.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 67.3 | 100.0 | 338.2 |  |  |  | NXDOMAIN:32 | 0.0 | 10015.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 33.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 65.0 | 84.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 33.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.5 | 84.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 4.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 23.4 | 100.0 | 364.9 |  |  |  | NXDOMAIN:36 | 6298.0 | 10021.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 5039.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 67.0 | 110.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 5045.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 68.0 | 104.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 4.5 |  |  |  |  | 42.0 | 2060.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 67.0 | 88.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 35.0 | 82.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 35.3 | 100.0 | 361.3 |  |  |  | NXDOMAIN:33 | 6302.0 | 10029.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 47.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 65.0 | 108.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5039.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 99.7 | 100.0 | 1.0 |  |  |  | NODATA:2 | 65.0 | 91.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 2.6 |  |  |  |  | 0.0 | 2055.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 82.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 84.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 7.1 | 99.8 | 368.2 |  | 2.1 | r1:11 | TIMEOUT:144 | 2020.0 | 2024.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:592 |  | 50.0 | 73.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 7.0 | 100.0 | 364.8 |  | 0.1 | r1:11 | TIMEOUT:141;SERVFAIL:5 | 2020.0 | 2024.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 7.1 | 100.0 | 370.3 |  | 0.1 | r1:11 | TIMEOUT:144 | 2021.0 | 2035.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:592 |  | 52.0 | 72.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 7.1 | 100.0 | 370.5 |  | 0.3 | r1:11 | TIMEOUT:144 | 2021.0 | 2026.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:592 |  | 52.0 | 89.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 7.7 | 100.0 | 364.4 |  | 0.3 | r1:12 | TIMEOUT:144 | 2021.0 | 2027.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 7.1 | 100.0 | 370.3 |  | 0.2 | r1:11 | TIMEOUT:144 | 2021.0 | 2027.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:592 |  | 52.0 | 77.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 99.1 | 100.0 | 6.5 | 10.5 |  | r2:559;r1:13 | TIMEOUT:5 | 53.0 | 2027.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 31.4 | 100.0 | 357.5 |  | 0.4 | r1:16 | NXDOMAIN:35 | 6068.0 | 10017.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 13.0 |  | r2:568;r1:15 |  | 0.0 | 5033.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 6.1 | 0.1 | r2:570;r1:11 |  | 65.0 | 84.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 11.5 |  | r2:571;r1:12 |  | 0.0 | 5033.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 5.8 | 0.0 | r2:568;r1:14 |  | 65.0 | 81.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.5 | 16.0 |  | r2:562;r1:27 |  | 0.0 | 2049.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 6.1 | 0.2 | r2:570;r1:11 |  | 0.0 | 91.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 5.8 | 0.3 | r2:571;r1:11 |  | 0.0 | 79.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 19.2 | 100.0 | 373.4 |  | 0.3 | r1:10 | TIMEOUT:42 | 7025.0 | 7167.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:581 |  | 35.0 | 54.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 20.8 | 100.0 | 369.1 |  | 0.2 | r1:11 | TIMEOUT:42 | 7022.0 | 7077.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:581 |  | 35.0 | 52.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 17.9 | 100.0 | 364.4 |  | 0.4 | r1:12 | SERVFAIL:28;TIMEOUT:27 | 5554.0 | 7100.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 9.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5037.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 193.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 168.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 99.8 | 100.0 | 11.6 |  |  |  | TIMEOUT:1 | 3.0 | 11118.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 15.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 60.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 99.8 | 100.0 | 8.1 |  |  |  | NXDOMAIN_OR_FAIL:1 | 0.0 | 7582.0 |
