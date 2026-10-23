// Emulated on-premises site: a VNet that stands in for a datacenter, a BIND DNS
// forwarder (the "corporate DNS server") and a Linux probe client.
//
// BIND conditionally forwards the Azure-hosted zones to the DNS Private Resolver
// inbound endpoints [local region IE, remote region IE] — the Microsoft Learn
// "resolver failover" pattern. Everything else is forwarded to Azure DNS
// (168.63.129.16), which emulates the site's internet resolution.
targetScope = 'resourceGroup'

param location string
param prefix string
@description('Short site id, e.g. op1 / op2.')
param siteId string
@description('Site address space, e.g. 10.110.0.0/16 (must be a /16).')
param addressPrefix string
@description('Ordered list of DNS Private Resolver inbound endpoint IPs [local, remote].')
param inboundEndpointIps array
param adminUsername string
@secure()
param sshPublicKey string
param vmSize string
param enableAutoShutdown bool
param autoShutdownTime string
param tags object
@description('BIND max-cache-ttl / max-ncache-ttl (s). Kept short so probes observe resolver failover instead of BIND cache.')
param bindMaxCacheTtl int = 5
@description('Private IP of the regional hub NVA router. Empty = no UDR (site reaches only directly-connected networks).')
param nvaIp string = ''
@description('Remote prefixes (other region hub/spoke/site) steered to the hub NVA.')
param remoteRoutes array = []

var octets = split(split(addressPrefix, '/')[0], '.')
var base = '${octets[0]}.${octets[1]}'
var dnsSubnetPrefix = '${base}.0.0/24'
var clientSubnetPrefix = '${base}.1.0/24'
var gatewaySubnetPrefix = '${base}.255.0/27'
var dnsIp = '${base}.0.10'
var clientIp = '${base}.1.20'
var appIp = '${base}.1.50'

var vnetName = 'vnet-${prefix}-${siteId}'
var bindVmName = 'vm-${prefix}-bind-${siteId}'
var clientVmName = 'vm-${prefix}-lnx-${siteId}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${prefix}-${siteId}'
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Cross-region prefixes go to the regional hub NVA (service chaining over the site<->hub peering).
resource rt 'Microsoft.Network/routeTables@2024-05-01' = if (!empty(nvaIp)) {
  name: 'rt-${prefix}-${siteId}'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      for (r, i) in remoteRoutes: {
        name: 'to-remote-${i}'
        properties: {
          addressPrefix: r
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: nvaIp
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    // Every on-prem machine uses the local BIND server, like a real datacenter.
    dhcpOptions: {
      dnsServers: [
        dnsIp
      ]
    }
    subnets: [
      {
        name: 'snet-dns'
        properties: {
          addressPrefix: dnsSubnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          routeTable: empty(nvaIp) ? null : {
            id: rt.id
          }
        }
      }
      {
        name: 'snet-client'
        properties: {
          addressPrefix: clientSubnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          routeTable: empty(nvaIp) ? null : {
            id: rt.id
          }
        }
      }
      {
        // Unused in peering mode (free); hosts the site VPN gateway in VPN mode.
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

var forwarderList = '${join(inboundEndpointIps, '; ')};'

var bindCloudInit = '''#cloud-config
package_update: true
packages:
  - bind9
  - bind9-dnsutils
  - tcpdump
write_files:
  - path: /opt/bindcfg/named.conf.options
    content: |
      options {
        directory "/var/cache/bind";
        listen-on { any; };
        listen-on-v6 { none; };
        allow-query { any; };
        recursion yes;
        dnssec-validation no;
        // Everything not matched below goes to Azure DNS (emulates internet resolution).
        forwarders { 168.63.129.16; };
        forward only;
        max-cache-ttl __MAXTTL__;
        max-ncache-ttl __MAXTTL__;
        querylog yes;
      };
  - path: /opt/bindcfg/named.conf.local
    content: |
      // Azure-hosted zones -> DNS Private Resolver inbound endpoints [local, remote].
      zone "lab.contoso.internal" { type forward; forward only; forwarders { __FWD__ }; };
      zone "azure.contoso.internal" { type forward; forward only; forwarders { __FWD__ }; };
      zone "__PLBLOB__" { type forward; forward only; forwarders { __FWD__ }; };
      // Local authoritative zone for this site.
      zone "__SITE__.onprem.contoso.internal" { type master; file "/etc/bind/db.__SITE__.onprem"; };
  - path: /opt/bindcfg/db.__SITE__.onprem
    content: |
      $TTL 60
      @   IN SOA ns1.__SITE__.onprem.contoso.internal. hostmaster.contoso.internal. ( 1 60 60 600 60 )
      @   IN NS  ns1.__SITE__.onprem.contoso.internal.
      ns1 IN A   __DNSIP__
      app IN A   __APPIP__
runcmd:
  - cp /opt/bindcfg/named.conf.options /etc/bind/named.conf.options
  - cp /opt/bindcfg/named.conf.local /etc/bind/named.conf.local
  - cp /opt/bindcfg/db.__SITE__.onprem /etc/bind/db.__SITE__.onprem
  - named-checkconf
  - systemctl enable named
  - systemctl restart named
'''

var bindCustomData = replace(
  replace(
    replace(
      replace(replace(bindCloudInit, '__FWD__', forwarderList), '__MAXTTL__', string(bindMaxCacheTtl)),
      '__SITE__',
      siteId
    ),
    '__DNSIP__',
    dnsIp
  ),
  '__APPIP__',
  appIp
)
var bindCustomDataFinal = replace(bindCustomData, '__PLBLOB__', 'privatelink.blob.${environment().suffixes.storage}')

// The client boots with the BIND server as its resolver, which may still be
// installing. Wait for DNS before installing the probe tooling.
var clientCloudInit = '''#cloud-config
runcmd:
  - mkdir -p /opt/dnsprobe /var/log/dnsprobe
  - for i in $(seq 1 90); do getent hosts azure.archive.ubuntu.com && break; sleep 10; done
  - DEBIAN_FRONTEND=noninteractive apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get install -y bind9-dnsutils tcpdump python3 jq curl
'''

module bindVm 'vm.bicep' = {
  name: 'vm-bind-${siteId}'
  params: {
    location: location
    name: bindVmName
    subnetId: '${vnet.id}/subnets/snet-dns'
    osType: 'linux'
    vmSize: vmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: dnsIp
    customData: bindCustomDataFinal
    // BIND itself must not point at itself while it is being installed.
    nicDnsServers: [
      '168.63.129.16'
    ]
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTime
    tags: union(tags, {
      role: 'onprem-dns'
      design: toUpper(siteId)
    })
  }
}

module clientVm 'vm.bicep' = {
  name: 'vm-lnx-${siteId}'
  params: {
    location: location
    name: clientVmName
    subnetId: '${vnet.id}/subnets/snet-client'
    osType: 'linux'
    vmSize: vmSize
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    privateIp: clientIp
    customData: clientCloudInit
    enableAutoShutdown: enableAutoShutdown
    autoShutdownTime: autoShutdownTime
    tags: union(tags, {
      role: 'client'
      design: toUpper(siteId)
    })
  }
  dependsOn: [
    bindVm
  ]
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output dnsIp string = dnsIp
output bindVmName string = bindVmName
output clientVmName string = clientVmName
output clientPrincipalId string = clientVm.outputs.principalId
output appFqdn string = 'app.${siteId}.onprem.contoso.internal'
output appIp string = appIp
