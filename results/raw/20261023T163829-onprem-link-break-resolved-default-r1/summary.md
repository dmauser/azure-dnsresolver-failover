# 20261023T163829-onprem-link-break-resolved-default-r1

- 2026-10-23T16:42:00.873000+00:00 inject_start design=b
- 2026-10-23T16:42:22.600000+00:00 inject_done design=b
- 2026-10-23T16:45:01.293000+00:00 restore_start design=b
- 2026-10-23T16:45:24.266000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 192.6 |  |  |  | TIMEOUT:78 | 2021.0 | 2035 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 20.0 | 59 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 94 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.7 |  |  |  |  | 51.0 | 82 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 22.0 | 38 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 24.0 | 42 |
| OP1 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 48 |
| OP2 | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 6 |
| OP1 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 43 |
| OP2 | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 11 |
| OP1 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 357.8 |  |  |  | NXDOMAIN:317 | 2.0 | 80 |
| OP2 | linux | resolved-default | host.onprem.contoso.internal | os |  | 0.0 | 0.0 | 0.0 | 357.8 |  |  |  | NXDOMAIN:317 | 2.0 | 121 |
| OP1 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 64 |
| OP2 | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 18 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 190.5 |  | 0.3 |  | TIMEOUT:78 | 2021.0 | 2032 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.110.0.10 | 100.0 | 100.0 | 100.0 | 0.6 | 0.4 |  | r2:317 |  | 22.0 | 86 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:317 |  | 52.0 | 115 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.3 | r1:317 |  | 53.0 | 73 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.120.0.10 | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:317 |  | 23.0 | 41 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:317 |  | 25.0 | 42 |
| OP1 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:317 |  | 0.0 | 45 |
| OP2 | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 | 0.4 |  | r2:317 |  | 0.0 | 11 |
| OP1 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 35 |
| OP2 | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 17 |
