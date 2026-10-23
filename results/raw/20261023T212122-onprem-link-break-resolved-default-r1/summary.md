# 20261023T212122-onprem-link-break-resolved-default-r1

- 2026-10-23T21:24:56.432000+00:00 inject_start nan
- 2026-10-23T21:25:16.360000+00:00 inject_done nan
- 2026-10-23T21:27:53.451000+00:00 restore_start nan
- 2026-10-23T21:28:12.833000+00:00 restore_done nan

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 182.6 |  |  |  | TIMEOUT:77 | 2023.0 | 2033 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.110.0.10 | 100.0 | 0.0 | 100.0 | 181.2 |  |  |  | TIMEOUT:58;SERVFAIL:42 | 2021.0 | 2034 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 182.6 |  |  |  | TIMEOUT:77 | 2023.0 | 2030 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 60.5 | 80 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 19.0 | 30 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 39 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 0.0 | 100.0 | 180.7 |  |  |  | NXDOMAIN:42 | 4.5 | 10009 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 9 |
| OP1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 0.0 | 100.0 | 179.6 |  |  |  | NXDOMAIN:42 | 4.0 | 10016 |
| OP2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| OP1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 355.4 |  |  |  | NXDOMAIN:314 | 2.0 | 87 |
| OP2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 355.4 |  |  |  | NXDOMAIN:314 | 2.0 | 118 |
| OP1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 0.0 | 100.0 | 179.6 |  |  |  | NXDOMAIN:15 | 10011.0 | 10022 |
| OP2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 22 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 182.5 |  | 0.2 |  | TIMEOUT:78 | 2023.0 | 2027 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.110.0.10 | 100.0 | 0.0 | 100.0 | 179.7 |  |  |  | TIMEOUT:58;SERVFAIL:42 | 2021.5 | 2026 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 0.0 | 100.0 | 182.6 |  |  |  | TIMEOUT:77 | 2023.0 | 2030 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:314 |  | 61.5 | 82 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:314 |  | 23.0 | 51 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:314 |  | 24.0 | 43 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 0.0 | 100.0 | 179.2 |  |  |  | NXDOMAIN:42 | 4.0 | 10019 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.2 |  | r2:314 |  | 0.0 | 11 |
| OP1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 106 |
| OP2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 125 |
