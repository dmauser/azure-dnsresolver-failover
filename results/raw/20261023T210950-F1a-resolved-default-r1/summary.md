# 20261023T210950-F1a-resolved-default-r1

- 2026-10-23T21:13:24.564000+00:00 inject_start nan
- 2026-10-23T21:13:29.052000+00:00 inject_done nan
- 2026-10-23T21:16:21.028000+00:00 restore_start nan
- 2026-10-23T21:16:24.757000+00:00 restore_done nan

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 125.9 |  |  |  | TIMEOUT:84 | 2023.0 | 2035 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 1.8 |  |  |  |  | 21.0 | 1265 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 55.0 | 83 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  |  |  | TIMEOUT:85 | 2020.0 | 2029 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 19.0 | 35 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 21.0 | 42 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 170.3 |  |  |  | TIMEOUT:85 | 2021.0 | 2026 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 54.0 | 70 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  |  |  | TIMEOUT:85 | 2021.0 | 2028 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 54 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.3 |  |  |  |  | 0.0 | 795 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 6 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 5033 |
| R1 | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.5 | 81 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10 |
| R2 | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 2.0 | 30 |
| R1 | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 71 |
| R2 | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8 |
| R1 | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.9 |  |  |  | TIMEOUT:24 | 7038.0 | 7298 |
| R1 | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 42.0 | 89 |
| R2 | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.4 |  |  |  | TIMEOUT:24 | 7028.5 | 7101 |
| R2 | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 30 |
| OP1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 64 |
| OP2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 17 |
| R1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 31 |
| R1 | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 84 |
| R2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3 |
| R2 | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 2.5 |  |  |  |  | 2.0 | 2018 |
| R1 | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 0 |
| R2 | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 1 |
| OP1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 355.4 |  |  |  | NXDOMAIN:343 | 2.0 | 99 |
| OP2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 355.4 |  |  |  | NXDOMAIN:343 | 1.0 | 113 |
| R1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 38.0 | 66 |
| R1 | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 7.0 | 84 |
| R2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 7.0 | 31 |
| R2 | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 20 |
| R1 | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 50 |
| R2 | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 6.0 | 21 |
| OP1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 1.7 |  |  |  |  | 0.0 | 1246 |
| OP2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 28 |
| R1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 47 |
| R1 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 87 |
| R2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19 |
| R2 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 17 |
| R1 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 82 |
| R2 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 7 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 67.3 |  | 0.8 | r1:2 | TIMEOUT:84 | 2023.0 | 2035 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 1.7 | 2.2 |  | r2:341;r1:1 |  | 21.0 | 1272 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.7 | 0.5 |  | r2:343 |  | 55.0 | 88 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  | 0.1 |  | TIMEOUT:85 | 2020.0 | 2029 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 21.0 | 37 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 22.0 | 53 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 5.6 | 100.0 | 71.2 |  | 0.1 | r1:5 | TIMEOUT:84 | 2021.0 | 2026 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 54.0 | 69 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 87.4 |  | 0.6 | r1:2 | TIMEOUT:84 | 2021.0 | 2024 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 24.0 | 41 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.2 | 2.2 |  | r2:341;r1:2 |  | 0.0 | 750 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 0.0 | 8 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 5.5 | 8.5 |  | r2:328;r1:6 |  | 0.0 | 5040 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 108.1 | 38.8 | r1:325;r2:13 |  | 3.0 | 82 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:343 |  | 0.0 | 31 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:337 |  | 3.0 | 24 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 112.9 | 0.3 | r1:322;r2:16 |  | 0.0 | 72 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.3 |  | r2:337 |  | 0.0 | 14 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.6 |  | 0.5 |  | TIMEOUT:24 | 7031.5 | 7121 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.2 |  | r2:337 |  | 42.0 | 60 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  | 0.2 |  | TIMEOUT:24 | 7028.5 | 7101 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:338 |  | 4.0 | 28 |
| OP1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 118 |
| OP2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 122 |
| R1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 5.5 |  |  |  |  | 0.0 | 59 |
| R1 | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 106 |
| R2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 29 |
| R2 | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 123 |
| R1 | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 7 |
| R2 | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 26 |
