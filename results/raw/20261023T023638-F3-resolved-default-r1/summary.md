# 20261023T023638-F3-resolved-default-r1

- 2026-10-23T02:40:12.587000+00:00 inject_start design=b
- 2026-10-23T02:40:31.316000+00:00 inject_done design=b
- 2026-10-23T02:43:09.206000+00:00 restore_start design=b
- 2026-10-23T02:43:27.856000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 21.0 | 52.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 70.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.7 |  |  |  |  | 25.0 | 49.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 99.7 | 184.5 |  |  |  | TIMEOUT:78 | 2022.0 | 2025.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.9 |  |  |  |  | 53.5 | 67.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 22.0 | 39.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 53.0 | 65.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.7 |  |  |  |  | 25.0 | 76.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 22.0 | 40.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 99.7 | 100.0 | 2.5 |  |  |  | TIMEOUT:1 | 52.0 | 2025.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 99.2 | 99.7 | 100.0 | 2.5 |  |  |  | TIMEOUT:1 | 25.0 | 2011.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 20.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 43.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 111.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 6.0 | 31.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.7 |  |  |  |  | 0.0 | 45.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 70.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 17.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 190.5 |  |  |  | TIMEOUT:22 | 7028.0 | 7156.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.9 |  |  |  |  | 36.0 | 54.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 27.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 7.5 |  |  |  |  | 35.0 | 52.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 24.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 66.0 | 84.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 61.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 10.0 | 30.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 37.0 | 61.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 69.0 | 124.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 45.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 35.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.5 |  |  |  |  | 11.0 | 2058.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 69.0 | 110.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 35.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 27.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 51.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 67.0 | 100.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 25.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 8.0 | 29.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 41.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 76.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 32.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.2 | r1:316 |  | 26.0 | 50.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.9 | 0.3 |  | r2:316 |  | 53.0 | 65.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.2 | r1:316 |  | 27.0 | 53.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 182.4 |  | 0.7 |  | TIMEOUT:78 | 2021.0 | 2026.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:316 |  | 53.0 | 82.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:316 |  | 22.0 | 41.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.3 |  | r2:316 |  | 54.5 | 85.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:316 |  | 28.0 | 48.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.7 |  | 0.2 | r1:316 |  | 25.0 | 42.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:316 |  | 54.0 | 70.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 98.4 | 99.7 | 100.0 | 2.6 | 0.8 |  | r1:225;r2:84 | TIMEOUT:1 | 25.0 | 2019.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:316 |  | 0.0 | 28.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 0.2 |  | r2:316 |  | 0.0 | 48.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 0.6 | 0.1 | r2:310 |  | 67.0 | 81.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:316 |  | 0.0 | 18.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:310 |  | 5.5 | 27.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.5 | 24.7 |  | r1:206;r2:104 |  | 0.0 | 2044.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 0.3 | 0.4 | r2:310 |  | 0.0 | 74.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:311 |  | 0.0 | 20.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 183.5 |  | 0.1 |  | TIMEOUT:22 | 7028.0 | 7156.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:310 |  | 36.0 | 63.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.5 | r1:311 |  | 4.0 | 19.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.7 | 0.1 |  | r2:313 |  | 36.0 | 54.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:311 |  | 4.0 | 27.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 48.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 11.6 |  |  |  |  | 67.0 | 185.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 67.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 15.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 9.9 |  |  |  |  | 0.0 | 74.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 64.0 |
