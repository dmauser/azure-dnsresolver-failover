# 20261023T012141-none-resolved-default-r1

| design | os | profile | name | method | server |
|---|---|---|---|---|---|
| A | linux | resolved-default | - | resolvectl |  |
| B | linux | resolved-default | - | resolvectl |  |
| C | linux | resolved-default | - | resolvectl |  |
| D | linux | resolved-default | - | resolvectl |  |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 |
| A | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 |
| B | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 |
| C | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.10.0.4 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 10.20.0.4 |
| D | linux | resolved-default | app1.azure.contoso.internal | dig | 168.63.129.16 |
| A | linux | resolved-default | app1.azure.contoso.internal | os |  |
| B | linux | resolved-default | app1.azure.contoso.internal | os |  |
| B | windows | windows-default | app1.azure.contoso.internal | os |  |
| C | linux | resolved-default | app1.azure.contoso.internal | os |  |
| C | windows | windows-default | app1.azure.contoso.internal | os |  |
| D | linux | resolved-default | app1.azure.contoso.internal | os |  |
| B | windows | windows-default | app1.azure.contoso.internal | os-api |  |
| C | windows | windows-default | app1.azure.contoso.internal | os-api |  |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 |
| B | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.10.0.4 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 10.20.0.4 |
| C | windows | windows-default | app1.azure.contoso.internal | srv | 168.63.129.16 |
| A | linux | resolved-default | app2.azure.contoso.internal | os |  |
| B | linux | resolved-default | app2.azure.contoso.internal | os |  |
| B | windows | windows-default | app2.azure.contoso.internal | os |  |
| C | linux | resolved-default | app2.azure.contoso.internal | os |  |
| C | windows | windows-default | app2.azure.contoso.internal | os |  |
| D | linux | resolved-default | app2.azure.contoso.internal | os |  |
| B | windows | windows-default | app2.azure.contoso.internal | os-api |  |
| C | windows | windows-default | app2.azure.contoso.internal | os-api |  |
| A | linux | resolved-default | host.onprem.contoso.internal | os |  |
| B | linux | resolved-default | host.onprem.contoso.internal | os |  |
| B | windows | windows-default | host.onprem.contoso.internal | os |  |
| C | linux | resolved-default | host.onprem.contoso.internal | os |  |
| C | windows | windows-default | host.onprem.contoso.internal | os |  |
| D | linux | resolved-default | host.onprem.contoso.internal | os |  |
| B | windows | windows-default | host.onprem.contoso.internal | os-api |  |
| C | windows | windows-default | host.onprem.contoso.internal | os-api |  |
| A | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| B | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| C | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| D | linux | resolved-default | stdnsfor15h7ejp.blob.core.windows.net | os |  |
| B | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  |
| C | windows | windows-default | stdnsfor15h7ejp.blob.core.windows.net | os-api |  |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 |
| A | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 |
| B | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 |
| C | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.10.0.4 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 10.20.0.4 |
| D | linux | resolved-default | whoami.lab.contoso.internal | dig | 168.63.129.16 |
| A | linux | resolved-default | whoami.lab.contoso.internal | os |  |
| B | linux | resolved-default | whoami.lab.contoso.internal | os |  |
| B | windows | windows-default | whoami.lab.contoso.internal | os |  |
| C | linux | resolved-default | whoami.lab.contoso.internal | os |  |
| C | windows | windows-default | whoami.lab.contoso.internal | os |  |
| D | linux | resolved-default | whoami.lab.contoso.internal | os |  |
| B | windows | windows-default | whoami.lab.contoso.internal | os-api |  |
| C | windows | windows-default | whoami.lab.contoso.internal | os-api |  |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 |
| B | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.10.0.4 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 10.20.0.4 |
| C | windows | windows-default | whoami.lab.contoso.internal | srv | 168.63.129.16 |
| A | linux | resolved-default | www.microsoft.com | os |  |
| B | linux | resolved-default | www.microsoft.com | os |  |
| B | windows | windows-default | www.microsoft.com | os |  |
| C | linux | resolved-default | www.microsoft.com | os |  |
| C | windows | windows-default | www.microsoft.com | os |  |
| D | linux | resolved-default | www.microsoft.com | os |  |
| B | windows | windows-default | www.microsoft.com | os-api |  |
| C | windows | windows-default | www.microsoft.com | os-api |  |
