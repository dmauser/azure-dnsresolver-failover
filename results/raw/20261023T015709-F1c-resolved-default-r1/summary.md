# 20261023T015709-F1c-resolved-default-r1

- 2026-10-23T02:00:43.338000+00:00 inject_start design=b
- 2026-10-23T02:00:52.096000+00:00 inject_done design=b
- 2026-10-23T02:03:40.113000+00:00 restore_start design=b
- 2026-10-23T02:03:47.135000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  |  |  | TIMEOUT:83 | 2020.0 | 2027.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 99.7 | 100.0 | 2.5 |  |  |  | TIMEOUT:1 | 51.0 | 2023.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 37.6 | 100.0 | 47.0 |  |  |  | TIMEOUT:73 | 2019.0 | 2023.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.4 |  |  |  | TIMEOUT:83 | 2021.0 | 2031.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 51.0 | 69.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.4 |  |  |  | TIMEOUT:83 | 2021.0 | 2025.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 71.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 41.3 | 99.7 | 32.9 |  |  |  | TIMEOUT:71 | 2020.0 | 2025.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  |  |  | TIMEOUT:83 | 2021.0 | 2026.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 88.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 50.7 | 100.0 | 18.7 |  |  |  | TIMEOUT:65;SERVFAIL:1 | 139.0 | 2028.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 95.2 | 100.0 | 31.8 |  |  |  | NXDOMAIN:9 | 0.0 | 8240.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 43.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 74.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.3 |  |  |  |  | 0.0 | 43.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 62.0 | 76.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 98.0 | 100.0 | 14.3 |  |  |  | NXDOMAIN:4 | 0.0 | 10013.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 71.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 71.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 177.3 |  |  |  | TIMEOUT:24 | 7027.5 | 7061.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 2.1 |  |  |  |  | 36.0 | 49.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 177.2 |  |  |  | TIMEOUT:24 | 7024.5 | 7050.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 34.0 | 54.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 87.2 | 100.0 | 19.6 |  |  |  | TIMEOUT:8;SERVFAIL:6 | 10.0 | 7050.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 38.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 80.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 36.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 67.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 68.1 | 100.0 | 67.3 |  |  |  | NXDOMAIN:15 | 3130.0 | 10010.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 61.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.2 |  |  |  |  | 6.0 | 1779.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 36.0 | 67.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 98.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 80.0 | 100.0 | 44.1 |  |  |  | NXDOMAIN:8 | 4068.5 | 10026.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 2.5 |  |  |  |  | 6.0 | 2068.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 39.0 | 81.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 97.2 | 100.0 | 37.0 |  |  |  | NXDOMAIN:5 | 0.0 | 8241.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 42.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 76.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 43.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 62.5 | 82.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 98.1 | 100.0 | 21.7 |  |  |  | NXDOMAIN:4 | 0.0 | 10013.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 77.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 72.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  | 0.2 |  | TIMEOUT:83 | 2020.0 | 2024.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:336 |  | 51.0 | 64.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 43.5 | 100.0 | 16.7 |  | 0.4 | r1:54 | TIMEOUT:70 | 2019.0 | 2024.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.4 |  | 0.3 |  | TIMEOUT:83 | 2021.0 | 2034.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:336 |  | 52.0 | 83.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 113.7 |  | 0.2 | r1:1 | TIMEOUT:83 | 2021.0 | 2024.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.8 | 0.5 |  | r2:336 |  | 53.0 | 68.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 49.6 | 100.0 | 32.8 |  | 0.1 | r1:66 | TIMEOUT:66;SERVFAIL:1 | 1695.0 | 2029.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.4 |  | 0.3 |  | TIMEOUT:83 | 2021.0 | 2030.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 1.8 | 0.5 |  | r2:336 |  | 52.0 | 75.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 44.4 | 100.0 | 20.7 | 46.7 | 0.7 | r1:52;r2:3 | TIMEOUT:67;SERVFAIL:2 | 2011.5 | 2027.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 96.8 | 100.0 | 43.4 |  | 0.4 | r1:183 | NXDOMAIN:6 | 0.0 | 8268.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:336 |  | 0.0 | 40.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 88.6 | 0.1 | r1:203;r2:127 |  | 4.0 | 76.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 3.0 |  | r2:331;r1:5 |  | 0.0 | 42.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 1.3 | 2.2 | r2:210;r1:120 |  | 63.0 | 80.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 98.7 | 100.0 | 11.4 | 65.5 | 0.4 | r1:222;r2:14 | NXDOMAIN:3 | 0.0 | 8330.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 109.5 | 0.1 | r1:222;r2:108 |  | 0.0 | 70.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 13.7 | 0.9 | r2:249;r1:81 |  | 0.0 | 72.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 4.0 | 100.0 | 91.9 |  | 0.3 | r1:1 | TIMEOUT:24 | 7030.0 | 7093.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.4 |  | r2:330 |  | 35.0 | 51.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 4.0 | 100.0 | 135.0 |  | 0.0 | r1:1 | TIMEOUT:24 | 7023.0 | 7101.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 1.5 | 0.0 |  | r2:330 |  | 34.0 | 55.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 80.0 | 99.7 | 38.1 |  | 0.6 | r1:72 | SERVFAIL:13;TIMEOUT:5 | 14.5 | 7128.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 60.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 191.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 40.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 66.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 70.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 59.0 |
