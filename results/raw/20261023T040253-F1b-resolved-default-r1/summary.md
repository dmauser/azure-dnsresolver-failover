# 20261023T040253-F1b-resolved-default-r1

- 2026-10-23T04:06:27.635000+00:00 inject_start design=b
- 2026-10-23T04:06:32.014000+00:00 inject_done design=b
- 2026-10-23T04:09:23.978000+00:00 restore_start design=b
- 2026-10-23T04:09:27.626000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 23.0 | 45.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 55.0 | 73.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 25.0 | 48.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 21.0 | 44.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 73.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 23.0 | 45.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 54.0 | 66.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 25.0 | 59.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 23.0 | 44.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 53.0 | 72.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 25.0 | 60.0 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 22.0 |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 24.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 17.0 |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 30.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 17.0 |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 20.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 6.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 24.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 25.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 36.0 | 52.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 25.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 35.0 | 67.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.8 |  |  |  |  | 6.0 | 23.0 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 3.0 | 18.0 |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 24.0 |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 3.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 2.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 3.0 |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 42.0 |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 7.0 | 21.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 5.0 | 22.0 |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 11.0 | 54.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 9.5 | 31.0 |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 10.0 | 44.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 5.0 | 35.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 10.0 | 49.0 |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 25.0 |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 21.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 26.0 |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 19.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 7.0 | 45.0 |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 25.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 7.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 19.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 25.0 | 45.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 99.7 | 100.0 | 2.5 | 0.1 |  | r2:340 | TIMEOUT:1 | 54.0 | 2022.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 29.0 | 58.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 26.0 | 43.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:344 |  | 53.0 | 83.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.5 | r1:344 |  | 22.0 | 36.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:344 |  | 55.0 | 72.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 28.0 | 72.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 26.0 | 52.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.1 |  | r2:344 |  | 53.0 | 81.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 28.0 | 51.0 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.5 | r1:344 |  | 0.0 | 14.0 |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 0.0 | 6.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.5 | r1:338 |  | 3.0 | 17.0 |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.4 | r1:344 |  | 0.0 | 11.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 118.4 | 0.2 | r1:337;r2:1 |  | 6.0 | 71.0 |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.5 | r1:344 |  | 0.0 | 14.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  | 0.2 | r1:339 |  | 0.0 | 21.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.2 | r1:338 |  | 0.0 | 34.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 99.7 | 100.0 | 7.5 |  | 0.3 | r1:325 | TIMEOUT:1 | 4.0 | 7046.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.1 |  | r2:343 |  | 35.0 | 52.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 100.0 | 100.0 | 0.6 |  | 0.2 | r1:338 |  | 4.0 | 20.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.1 |  | r2:338 |  | 36.0 | 50.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 100.0 | 100.0 | 0.7 |  | 0.2 | r1:338 |  | 6.0 | 34.0 |
| A | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 100.0 |
| B | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 98.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 67.0 |
| C | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 8.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 74.0 |
| D | linux | resolved-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 8.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 24.0 |
