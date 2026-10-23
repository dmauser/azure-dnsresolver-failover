# 20261023T014445-F1a-glibc-tuned-r1

- 2026-10-23T01:48:19.458000+00:00 inject_start design=b
- 2026-10-23T01:48:23.612000+00:00 inject_done design=b
- 2026-10-23T01:51:16.577000+00:00 restore_start design=b
- 2026-10-23T01:51:20.599000+00:00 restore_done design=b

| design | os | profile | name | method | server | base_ok% | fail_ok% | rec_ok% | max_gap_s | to_r2_s | failback_s | fail_regions | fail_rcodes | fail_p50_ms | fail_max_ms |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 97.5 |  |  |  | TIMEOUT:85 | 2020.0 | 2026.0 |
| A | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 1.0 |  |  |  |  | 51.0 | 534.0 |
| A | linux | glibc-tuned | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 55.0 | 100.0 | 44.2 |  |  |  | TIMEOUT:63;SERVFAIL:4 | 29.0 | 2023.0 |
| B | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 2.3 | 100.0 | 152.1 |  |  |  | TIMEOUT:85 | 2021.0 | 2027.0 |
| B | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 67.0 |
| C | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  |  |  | TIMEOUT:85 | 2020.0 | 2025.0 |
| C | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.8 |  |  |  |  | 52.0 | 359.0 |
| C | linux | glibc-tuned | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 56.0 | 100.0 | 30.8 |  |  |  | TIMEOUT:63;SERVFAIL:3 | 29.5 | 2025.0 |
| D | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  |  |  | TIMEOUT:85 | 2020.0 | 2024.0 |
| D | linux | glibc-tuned | app1.azure.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 52.0 | 73.0 |
| D | linux | glibc-tuned | app1.azure.contoso.internal | dig | 168.63.129.16 | 100.0 | 98.8 | 100.0 | 2.6 |  |  |  | TIMEOUT:4 | 25.0 | 2024.0 |
| A | linux | glibc-tuned | app1.azure.contoso.internal | os |  | 100.0 | 68.3 | 100.0 | 17.8 |  |  |  | SERVFAIL_OR_TIMEOUT:51 | 1002.0 | 2003.0 |
| B | linux | glibc-tuned | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1034.0 | 1052.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 4.0 | 83.0 |
| C | linux | glibc-tuned | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 443.0 | 1056.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 60.0 | 85.0 |
| D | linux | glibc-tuned | app1.azure.contoso.internal | os |  | 100.0 | 99.4 | 100.0 | 2.5 |  |  |  | SERVFAIL_OR_TIMEOUT:2 | 32.0 | 2001.0 |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 75.0 |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 74.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 177.5 |  |  |  | TIMEOUT:24 | 7026.0 | 7103.0 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 99.7 | 7.5 |  |  |  |  | 35.0 | 56.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 177.2 |  |  |  | TIMEOUT:24 | 7024.0 | 7076.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 34.0 | 54.0 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 | 100.0 | 86.0 | 100.0 | 31.3 |  |  |  | SERVFAIL:11;TIMEOUT:5 | 14.0 | 7049.0 |
| A | linux | glibc-tuned | app2.azure.contoso.internal | os |  | 100.0 | 96.6 | 100.0 | 11.0 |  |  |  | SERVFAIL_OR_TIMEOUT:10 | 1.0 | 2002.0 |
| B | linux | glibc-tuned | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1034.0 | 1060.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 84.0 |
| C | linux | glibc-tuned | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 2.0 | 1040.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 64.0 |
| D | linux | glibc-tuned | app2.azure.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 51.0 |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 0.0 |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 6.0 |
| A | linux | glibc-tuned | host.onprem.contoso.internal | os |  | 100.0 | 66.2 | 100.0 | 12.5 |  |  |  | SERVFAIL_OR_TIMEOUT:54 | 1009.5 | 2002.0 |
| B | linux | glibc-tuned | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1037.0 | 1544.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 83.0 |
| C | linux | glibc-tuned | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1034.0 | 1048.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 67.0 | 91.0 |
| D | linux | glibc-tuned | host.onprem.contoso.internal | os |  | 100.0 | 99.4 | 100.0 | 3.0 |  |  |  | SERVFAIL_OR_TIMEOUT:2 | 42.0 | 2001.0 |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 6.0 | 83.0 |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 67.0 | 82.0 |
| A | linux | glibc-tuned | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 65.6 | 100.0 | 19.0 |  |  |  | SERVFAIL_OR_TIMEOUT:53;EAI-5:2 | 122.5 | 2003.0 |
| B | linux | glibc-tuned | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1035.0 | 1061.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 5.0 | 94.0 |
| C | linux | glibc-tuned | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 99.5 | 100.0 | 2.0 |  |  |  | EAI-5:1 | 1030.0 | 1069.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 60.5 | 100.0 |
| D | linux | glibc-tuned | stdnsfor15h7ejp.blob.core.windows.net | os |  | 100.0 | 99.7 | 100.0 | 2.6 |  |  |  | SERVFAIL_OR_TIMEOUT:1 | 36.0 | 2001.0 |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 73.0 |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 73.0 |
| A | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  | 0.2 |  | TIMEOUT:85 | 2020.0 | 2023.0 |
| A | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:345 |  | 52.0 | 77.0 |
| A | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 53.1 | 100.0 | 16.7 |  | 0.9 | r1:78 | TIMEOUT:65;SERVFAIL:4 | 33.0 | 2024.0 |
| B | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.4 |  | 0.3 |  | TIMEOUT:85 | 2021.0 | 2025.0 |
| B | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:346 |  | 51.0 | 73.0 |
| C | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 1.2 | 100.0 | 103.5 |  | 0.8 | r1:1 | TIMEOUT:85 | 2021.0 | 2025.0 |
| C | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.5 | 0.5 |  | r2:346 |  | 52.0 | 70.0 |
| C | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 46.6 | 100.0 | 22.7 |  | 0.4 | r1:62 | TIMEOUT:69;SERVFAIL:2 | 2011.0 | 2025.0 |
| D | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 178.3 |  | 0.3 |  | TIMEOUT:85 | 2021.0 | 2025.0 |
| D | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 1.0 | 0.5 |  | r2:345 |  | 52.0 | 560.0 |
| D | linux | glibc-tuned | whoami.lab.contoso.internal | dig | 168.63.129.16 | 100.0 | 99.1 | 100.0 | 4.6 | 12.0 | 155.6 | r2:299;r1:32 | TIMEOUT:3 | 26.5 | 2025.0 |
| A | linux | glibc-tuned | whoami.lab.contoso.internal | os |  | 100.0 | 77.5 | 100.0 | 11.0 |  | 0.4 | r1:138 | SERVFAIL_OR_TIMEOUT:40 | 278.0 | 2002.0 |
| B | linux | glibc-tuned | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 | 1.5 | 0.4 | r2:166;r1:3 |  | 1034.0 | 1044.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.6 | 48.1 | 0.3 | r1:231;r2:109 |  | 3.0 | 78.0 |
| C | linux | glibc-tuned | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 1.5 | 3.0 | 0.5 | r1:126;r2:107 |  | 10.0 | 1050.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  | 100.0 | 100.0 | 100.0 | 0.8 | 14.5 | 0.3 | r2:200;r1:140 |  | 61.0 | 267.0 |
| D | linux | glibc-tuned | whoami.lab.contoso.internal | os |  | 100.0 | 99.7 | 100.0 | 2.5 | 11.0 | 158.1 | r2:303;r1:34 | SERVFAIL_OR_TIMEOUT:1 | 9.0 | 2002.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 79.8 | 6.7 | r1:302;r2:38 |  | 0.0 | 86.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 | 17.9 | 0.6 | r2:229;r1:111 |  | 0.0 | 74.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 0.0 | 100.0 | 177.4 |  | 0.4 |  | TIMEOUT:24 | 7035.0 | 7117.0 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 1.1 | 0.4 |  | r2:339 |  | 36.0 | 581.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 | 100.0 | 4.0 | 100.0 | 119.9 |  | 0.2 | r1:1 | TIMEOUT:24 | 7023.0 | 7046.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 | 100.0 | 100.0 | 100.0 | 0.6 | 0.1 |  | r2:340 |  | 35.0 | 113.0 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 | 100.0 | 82.9 | 100.0 | 24.6 |  | 0.5 | r1:87 | SERVFAIL:12;TIMEOUT:6 | 10.0 | 7044.0 |
| A | linux | glibc-tuned | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 126.0 |
| B | linux | glibc-tuned | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 1.5 |  |  |  |  | 1034.0 | 1161.0 |
| B | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 105.0 |
| C | linux | glibc-tuned | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 104.0 |
| C | windows | windows-default | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 3.0 | 72.0 |
| D | linux | glibc-tuned | www.microsoft.com | os |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 2.0 | 115.0 |
| B | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.6 |  |  |  |  | 0.0 | 68.0 |
| C | windows | windows-default | www.microsoft.com | os-api |  | 100.0 | 100.0 | 100.0 | 0.5 |  |  |  |  | 0.0 | 10.0 |
