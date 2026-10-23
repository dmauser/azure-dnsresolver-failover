# 20261023T204658-F2-resolved-default-r1

- 2026-10-23T20:50:31.727000+00:00 inject_start nan
- 2026-10-23T20:51:20.977000+00:00 inject_done nan
- 2026-10-23T20:53:29.895000+00:00 restore_start nan
- 2026-10-23T20:53:58.963000+00:00 restore_done nan

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.7 |  |  |  |  | 25.0 | 39 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 1.7 |  |  |  |  | 21.5 | 39 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 194.8 |  |  |  | TIMEOUT:64 | 2023.0 | 2034 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 194.6 |  |  |  | TIMEOUT:64 | 2021.0 | 2029 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 20.0 | 49 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 21.0 | 42 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 24.0 | 43 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 194.5 |  |  |  | TIMEOUT:64 | 2021.0 | 2031 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 194.6 |  |  |  | TIMEOUT:64 | 2022.0 | 2026 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 24.0 | 51 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.3 |  |  |  |  | 0.0 | 26 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 13 |
| R1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9 |
| R1 | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 24 |
| R2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| R2 | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 19 |
| R1 | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 20 |
| R2 | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8 |
| R1 | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 20 |
| R1 | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 197.5 |  |  |  | TIMEOUT:18 | 7030.0 | 7130 |
| R2 | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 197.4 |  |  |  | TIMEOUT:18 | 7027.0 | 7083 |
| R2 | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 4.0 | 29 |
| OP1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 12 |
| OP2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| R1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3 |
| R1 | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 23 |
| R2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2 |
| R2 | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 19 |
| R1 | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2 |
| R2 | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 0 |
| OP1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 356.2 |  |  |  | NXDOMAIN:258 | 2.0 | 96 |
| OP2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 356.2 |  |  |  | NXDOMAIN:258 | 2.0 | 116 |
| R1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 8.0 | 45 |
| R1 | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 21 |
| R2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 7.0 | 57 |
| R2 | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 6.0 | 1045 |
| R1 | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 49 |
| R2 | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 6.0 | 1044 |
| OP1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 26 |
| OP2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 1.7 |  |  |  |  | 0.0 | 1209 |
| R1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| R1 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 29 |
| R2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| R2 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 37 |
| R1 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| R2 | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 99.6 | 100.0 | 2.5 |  | 0.2 | r1:254 | TIMEOUT:1 | 26.0 | 2029 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.1 | r1:258 |  | 22.0 | 46 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 194.7 |  |  |  | TIMEOUT:64 | 2023.0 | 2029 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 194.6 |  | 0.1 |  | TIMEOUT:64 | 2021.0 | 2030 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:258 |  | 22.0 | 51 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:258 |  | 25.0 | 41 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.8 |  | 0.1 | r1:258 |  | 26.0 | 45 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 194.6 |  |  |  | TIMEOUT:64 | 2020.0 | 2025 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 194.7 |  | 0.3 |  | TIMEOUT:64 | 2022.0 | 2027 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:258 |  | 24.0 | 45 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:258 |  | 0.0 | 12 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:258 |  | 0.0 | 7 |
| R1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:258 |  | 0.0 | 9 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.1 | r1:253 |  | 3.0 | 19 |
| R2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:258 |  | 0.0 | 9 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.0 |  | r2:254 |  | 3.0 | 43 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.0 | r1:253 |  | 0.0 | 9 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:253 |  | 0.0 | 24 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.3 | r1:253 |  | 4.0 | 20 |
| R1 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 197.5 |  |  |  | TIMEOUT:18 | 7030.0 | 7130 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 197.5 |  | 0.1 |  | TIMEOUT:18 | 7026.5 | 7083 |
| R2 | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:254 |  | 4.0 | 25 |
| OP1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 113 |
| OP2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 31 |
| R1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19 |
| R1 | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 106 |
| R2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 30 |
| R2 | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 44 |
| R1 | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10 |
| R2 | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19 |
