# 20261023T162711-F1a-resolved-default-r1

- 2026-10-23T16:30:44.549000+00:00 inject_start design=b
- 2026-10-23T16:30:50.090000+00:00 inject_done design=b
- 2026-10-23T16:33:42.090000+00:00 restore_start design=b
- 2026-10-23T16:33:45.560000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 168.3 |  |  |  | TIMEOUT:85 | 2021.0 | 2029 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 21.0 | 70 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 55.0 | 75 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 176.3 |  |  |  | TIMEOUT:85 | 2021.0 | 2028 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 20.0 | 34 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 44 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 40 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 16 |
| OP1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 60 |
| OP2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19 |
| OP1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 356.4 |  |  |  | NXDOMAIN:344 | 2.0 | 94 |
| OP2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 356.4 |  |  |  | NXDOMAIN:344 | 2.0 | 122 |
| OP1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 67 |
| OP2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 49 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 135.9 |  | 0.8 | r1:1 | TIMEOUT:85 | 2021.0 | 2025 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:344 |  | 22.0 | 89 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:344 |  | 54.0 | 75 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 99.7 | 174.4 |  | 0.4 | r1:1 | TIMEOUT:85 | 2021.0 | 2028 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:344 |  | 22.0 | 51 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:344 |  | 23.0 | 53 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 0.4 |  | r2:344 |  | 0.0 | 78 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:344 |  | 0.0 | 6 |
| OP1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 99 |
| OP2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 38 |
