"""Generate docs/diagrams/reference-architecture.drawio (uncompressed mxGraph XML).

Recommended reference architecture: multi-region hub-spoke (CAF-aligned) with Azure DNS
Private Resolver in each regional hub, hub-to-hub global peering only, Linux NVA routers
steering cross-region traffic via UDRs, spokes using custom DNS [local IE, remote IE], and
two emulated on-premises sites whose BIND servers forward to both inbound endpoints.

Run:     python docs/diagrams/build_reference_architecture.py
Export:  draw.io -x -f png -s 2 -b 10 -o reference-architecture.png reference-architecture.drawio
         draw.io -x -f svg -b 10 -o reference-architecture.svg reference-architecture.drawio
"""
from pathlib import Path
from xml.sax.saxutils import escape

OUT = Path(__file__).with_name("reference-architecture.drawio")
ICON = "image;aspect=fixed;html=1;points=[];align=center;fontSize=10;verticalLabelPosition=bottom;verticalAlign=top;image=img/lib/azure2/"

AZ_BLUE, GREY, RED, ORANGE, GREEN, PURPLE = "#0078D4", "#605E5C", "#D13438", "#CA5010", "#107C10", "#5C2D91"
S_REGION = f"rounded=1;arcSize=1;whiteSpace=wrap;html=1;fillColor=#F3F2F1;strokeColor={GREY};dashed=1;dashPattern=8 4;verticalAlign=top;align=left;spacingLeft=10;spacingTop=2;fontStyle=1;fontSize=14;fontColor=#323130;container=1;collapsible=0;"
S_ONPREM = f"rounded=1;arcSize=1;whiteSpace=wrap;html=1;fillColor=#F7F4FB;strokeColor={PURPLE};dashed=1;dashPattern=8 4;verticalAlign=top;align=left;spacingLeft=10;spacingTop=2;fontStyle=1;fontSize=14;fontColor=#323130;container=1;collapsible=0;"
S_VNET = f"rounded=1;arcSize=2;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor={AZ_BLUE};strokeWidth=1.5;verticalAlign=top;align=left;spacingLeft=52;spacingTop=6;fontStyle=1;fontSize=12;fontColor=#201F1E;container=1;collapsible=0;"
S_SITE = S_VNET.replace(AZ_BLUE, PURPLE)
S_SUBNET = "rounded=1;arcSize=4;whiteSpace=wrap;html=1;fillColor=#F5FAFF;strokeColor=#8A8886;dashed=1;verticalAlign=top;align=left;spacingLeft=8;spacingTop=2;fontSize=10;fontColor=#323130;container=1;collapsible=0;"
S_BOX = "rounded=1;arcSize=6;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#8A8886;align=left;verticalAlign=top;spacingLeft=8;spacingTop=4;fontSize=10;fontColor=#323130;"
S_TEXT = "text;html=1;whiteSpace=wrap;align=left;verticalAlign=top;fontSize=10;fontColor=#323130;"
S_FAIL = f"ellipse;whiteSpace=wrap;html=1;aspect=fixed;fillColor={RED};strokeColor=#FFFFFF;strokeWidth=2;fontColor=#FFFFFF;fontStyle=1;fontSize=9;shadow=1;"
S_STEP = f"ellipse;whiteSpace=wrap;html=1;aspect=fixed;fillColor={AZ_BLUE};strokeColor=#FFFFFF;strokeWidth=2;fontColor=#FFFFFF;fontStyle=1;fontSize=12;"
S_EDGE = "edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;endArrow=block;endFill=1;fontSize=10;labelBackgroundColor=#FFFFFF;"

cells, edges, abspos = [], [], {"1": (0, 0)}


def add(cid, label, style, x, y, w, h, parent="1"):
    px, py = abspos[parent]
    abspos[cid] = (x, y)
    cells.append(f'<mxCell id="{cid}" value="{escape(label, {chr(34): "&quot;"})}" style="{style}" vertex="1" parent="{parent}">'
                 f'<mxGeometry x="{x - px}" y="{y - py}" width="{w}" height="{h}" as="geometry"/></mxCell>')
    return cid


def icon(cid, path, label, x, y, parent, size=40):
    return add(cid, label, ICON + path + ".svg", x, y, size, size, parent)


def edge(cid, src, tgt, label="", color=AZ_BLUE, dashed=False, width=1.5, pts=None, extra="", both=False):
    style = S_EDGE + f"strokeColor={color};fontColor={color};strokeWidth={width};" + ("dashed=1;" if dashed else "") + extra
    if both:
        style += "startArrow=block;startFill=1;"
    geo = '<mxGeometry relative="1" as="geometry">'
    if pts:
        geo += "<Array as=\"points\">" + "".join(f'<mxPoint x="{a}" y="{b}"/>' for a, b in pts) + "</Array>"
    geo += "</mxGeometry>"
    edges.append(f'<mxCell id="{cid}" value="{escape(label)}" style="{style}" edge="1" parent="1" source="{src}" target="{tgt}">{geo}</mxCell>')


def line(cid, x1, y1, x2, y2, color, dashed=False, width=2, arrow=True):
    style = f"html=1;strokeWidth={width};strokeColor={color};" + ("dashed=1;" if dashed else "") + \
        ("endArrow=block;endFill=1;" if arrow else "endArrow=none;")
    edges.append(f'<mxCell id="{cid}" value="" style="{style}" edge="1" parent="1"><mxGeometry relative="1" as="geometry">'
                 f'<mxPoint x="{x1}" y="{y1}" as="sourcePoint"/><mxPoint x="{x2}" y="{y2}" as="targetPoint"/></mxGeometry></mxCell>')


# ---------------------------------------------------------------- layout
add("title", "<b>Azure DNS Private Resolver &ndash; multi-region hub-spoke failover (reference architecture)</b>",
    "text;html=1;align=left;verticalAlign=middle;fontSize=20;fontColor=#201F1E;", 20, 10, 1300, 36)
add("subtitle", "Spokes use custom DNS [local inbound endpoint, remote inbound endpoint] &middot; on-premises BIND forwards to both endpoints &middot; hubs peer only to each other &middot; NVA routers + UDRs carry cross-region traffic",
    "text;html=1;align=left;verticalAlign=middle;fontSize=11;fontColor=#605E5C;", 20, 42, 1500, 22)

REG = {
    1: dict(y=80, name="Region 1 &ndash; East US 2", hub="10.10", spoke="10.11", op="10.110", ie="10.10.0.4", rie="10.20.0.4",
            nva="10.10.3.68", rnva="10.20.3.68", remote="10.20/16, 10.21/16, 10.120/16"),
    2: dict(y=530, name="Region 2 &ndash; Central US", hub="10.20", spoke="10.21", op="10.120", ie="10.20.0.4", rie="10.10.0.4",
            nva="10.20.3.68", rnva="10.10.3.68", remote="10.10/16, 10.11/16, 10.110/16"),
}

add("onprem", "On-premises (emulated with VNets)", S_ONPREM, 20, 80, 400, 860)

for r, d in REG.items():
    y = d["y"]
    # ---- on-prem site
    site = add(f"site{r}", f"vnet-dnsfo-onprem{r}<br><span style=\"font-weight:normal\">Site {r} &middot; {d['op']}.0.0/16</span>", S_SITE, 40, y + 40, 360, 370, "onprem")
    icon(f"site{r}i", "networking/Virtual_Networks", "", 50, y + 46, site, 34)
    sd = add(f"site{r}dns", f"snet-dns &middot; {d['op']}.0.0/24", S_SUBNET, 55, y + 95, 330, 105, site)
    icon(f"site{r}bind", "compute/Virtual_Machine", f"BIND {d['op']}.0.10", 75, y + 120, sd)
    add(f"site{r}fwd", f"<b>Forwarders (in order)</b><br>{d['ie']} (local)<br>{d['rie']} (remote)<br>max-cache-ttl 5 s",
        S_TEXT, 200, y + 112, 180, 80, sd)
    sc = add(f"site{r}cli", f"snet-client &middot; {d['op']}.1.0/24", S_SUBNET, 55, y + 210, 330, 95, site)
    icon(f"site{r}vm", "compute/Virtual_Machine", f"client {d['op']}.1.20", 75, y + 232, sc)
    add(f"site{r}cdns", "DNS server: local BIND", S_TEXT, 200, y + 245, 170, 30, sc)
    sg = add(f"site{r}gw", f"GatewaySubnet &middot; {d['op']}.255.0/27", S_SUBNET, 55, y + 315, 330, 80, site)
    icon(f"site{r}vng", "networking/Virtual_Network_Gateways", "VPN gateway (option)", 75, y + 335, sg, 32)
    add(f"site{r}udr", f"UDR: Azure ranges &rarr; hub NVA {d['nva']}", S_TEXT, 200, y + 340, 180, 40, sg)

    # ---- region
    reg = add(f"reg{r}", d["name"], S_REGION, 500, y, 1020, 420)
    hub = add(f"hub{r}", f"vnet-dnsfo-hub-r{r}<br><span style=\"font-weight:normal\">Hub &middot; {d['hub']}.0.0/22</span>", S_VNET, 520, y + 40, 640, 370, reg)
    icon(f"hub{r}i", "networking/Virtual_Networks", "", 530, y + 46, hub, 34)

    si = add(f"in{r}", f"snet-dns-inbound &middot; {d['hub']}.0.0/28", S_SUBNET, 535, y + 95, 195, 105, hub)
    icon(f"ie{r}", "networking/DNS_Private_Resolver", f"Inbound endpoint<br><b>{d['ie']}</b>", 610, y + 118, si)
    so = add(f"out{r}", f"snet-dns-outbound &middot; {d['hub']}.0.16/28", S_SUBNET, 745, y + 95, 195, 105, hub)
    icon(f"oe{r}", "networking/DNS_Private_Resolver", "Outbound endpoint<br>+ forwarding ruleset", 820, y + 118, so)
    sw = add(f"wl{r}", f"snet-workload &middot; {d['hub']}.1.0/24", S_SUBNET, 955, y + 95, 190, 105, hub)
    icon(f"dm{r}", "compute/Virtual_Machine", f"dnsmasq {d['hub']}.1.10<br>(onprem.contoso.internal)", 1030, y + 118, sw)

    sp = add(f"pe{r}", f"snet-pe &middot; {d['hub']}.2.0/24", S_SUBNET, 535, y + 210, 195, 105, hub)
    icon(f"pei{r}", "networking/Private_Endpoint", "Private endpoint<br>(blob)", 610, y + 233, sp)
    sgw = add(f"gws{r}", f"GatewaySubnet &middot; {d['hub']}.3.0/27", S_SUBNET, 745, y + 210, 195, 105, hub)
    icon(f"vng{r}", "networking/Virtual_Network_Gateways", "VPN gateway<br>(option)", 820, y + 233, sgw)
    sn = add(f"nvas{r}", f"snet-nva &middot; {d['hub']}.3.64/27", S_SUBNET, 955, y + 210, 190, 105, hub)
    icon(f"nva{r}", "compute/Virtual_Machine", f"<b>Linux NVA router</b><br>{d['nva']} &middot; IP forwarding", 1030, y + 233, sn)

    add(f"rth{r}", f"<b>rt-dnsfo-hub-r{r}</b> (resolver, workload, GatewaySubnet): {d['remote']} &rarr; {d['nva']} (local NVA)<br>"
        f"<b>rt-dnsfo-hub-r{r}-nva</b> (snet-nva): {d['remote']} &rarr; {d['rnva']} (remote NVA)",
        S_BOX + "spacingLeft=48;", 535, y + 325, 610, 72, hub)
    icon(f"rthi{r}", "networking/Route_Tables", "", 543, y + 340, hub, 32)

    # ---- spoke
    spk = add(f"spk{r}", f"vnet-dnsfo-spoke-r{r}<br><span style=\"font-weight:normal\">Spoke &middot; {d['spoke']}.0.0/16</span>", S_VNET, 1210, y + 40, 295, 370, reg)
    icon(f"spk{r}i", "networking/Virtual_Networks", "", 1220, y + 46, spk, 34)
    sc2 = add(f"cli{r}", f"snet-clients &middot; {d['spoke']}.1.0/24", S_SUBNET, 1225, y + 95, 265, 120, spk)
    icon(f"lnx{r}", "compute/Virtual_Machine", "Linux client", 1255, y + 122, sc2)
    icon(f"win{r}", "compute/Virtual_Machine", "Windows client", 1395, y + 122, sc2)
    add(f"dns{r}", f"<b>VNet custom DNS</b><br>1. {d['ie']} (local inbound)<br>2. {d['rie']} (remote inbound)",
        S_BOX + "fillColor=#EFF6FC;strokeColor=#0078D4;", 1225, y + 228, 265, 70, spk)
    add(f"rts{r}", f"<b>rt-dnsfo-spoke-r{r}</b><br>{d['remote']}<br>&rarr; {d['nva']} (local hub NVA)", S_BOX + "spacingLeft=48;", 1225, y + 310, 265, 85, spk)
    icon(f"rtsi{r}", "networking/Route_Tables", "", 1233, y + 330, spk, 32)

    # ---- connections
    edge(f"e_hs{r}", f"hub{r}", f"spk{r}", "Peering", AZ_BLUE, width=2.5, both=True)
    edge(f"e_oh{r}", f"site{r}", f"hub{r}", "Peering (default)<br>or S2S VPN", PURPLE, width=2.5, both=True)
    edge(f"e_q{r}", f"cli{r}", f"in{r}", "", GREEN, width=2, pts=[(1357, y + 85), (632, y + 85)])
    edge(f"e_b{r}", f"site{r}dns", f"in{r}", "", GREEN, width=2, dashed=False, pts=[(220, y + 85), (632, y + 85)], extra="exitX=0.5;exitY=0;entryX=0.5;entryY=0;")

# ---- hub <-> hub peering and cross-region NVA path
edge("e_hh", "hub1", "hub2", "Global VNet peering<br>(hub &harr; hub only)", AZ_BLUE, width=3, both=True,
     extra="exitX=0.3;exitY=1;entryX=0.3;entryY=0;")
edge("e_nva", "nva1", "nva2", "Cross-region path<br>NVA r1 &harr; NVA r2", ORANGE, dashed=True, width=2.5, both=True,
     pts=[(1185, 330), (1185, 780)], extra="exitX=1;exitY=0.5;entryX=1;entryY=0.5;")

# ---- failure markers
add("f1", "F1", S_FAIL, 698, 178, 26, 26)
add("f2", "F2", S_FAIL, 680, 456, 26, 26)
add("f3", "F3", S_FAIL, 1110, 293, 26, 26)

# ---- right column: zones + legend
zx = 1545
zb = add("zones", "<b>Private DNS zones</b> (rg-dnsfo-shared, linked to both hubs)", S_BOX + "spacingLeft=52;fontSize=11;", zx, 80, 235, 300)
icon("zi", "networking/DNS_Zones", "", zx + 8, 90, "zones", 36)
add("zl", "&bull; azure.contoso.internal<br>&nbsp;&nbsp;app1 &rarr; 10.50.0.1 (TTL 10 s)<br>&nbsp;&nbsp;app2 &rarr; 10.50.0.2 (TTL 3600 s)<br><br>"
    "&bull; privatelink.blob.core.windows.net<br><br>&bull; lab.contoso.internal (per region)<br>&nbsp;&nbsp;whoami &rarr; 10.255.1.1 / 10.255.2.2<br>&nbsp;&nbsp;(reveals which resolver answered)<br><br>"
    "&bull; Ruleset: onprem.contoso.internal &rarr; dnsmasq",
    S_TEXT, zx + 10, 140, 220, 230, "zones")

add("legend", "<b>Legend</b>", S_BOX + "fontSize=11;", zx, 400, 235, 300)
ly = 432
for i, (c, dash, txt) in enumerate([(AZ_BLUE, False, "VNet peering"), (PURPLE, False, "Hybrid link (peering / VPN)"),
                                     (GREEN, False, "DNS query (primary path)"), (ORANGE, True, "Cross-region traffic via NVAs")]):
    line(f"lg{i}", zx + 12, ly + i * 30 + 8, zx + 62, ly + i * 30 + 8, c, dashed=dash, width=2.5, arrow=False)
    add(f"lgt{i}", txt, S_TEXT, zx + 70, ly + i * 30, 160, 20)
add("lgf", "F1", S_FAIL, zx + 24, ly + 122, 22, 22)
add("lgft", "F1 inbound endpoint down (NSG deny 53)<br>F2 hub-hub peering removed<br>F3 NVA r1 down", S_TEXT, zx + 70, ly + 118, 165, 60)
add("lgn", "Production: replace the Linux NVAs with Azure Firewall or redundant NVAs behind an internal Load Balancer.",
    S_TEXT + "fontColor=#A4262C;", zx + 10, ly + 190, 220, 70)

# ---- bottom strip: normal / failover / failback
sy = 975
for i, (ttl, body) in enumerate([
    ("Normal", "Clients query the <b>local</b> inbound endpoint (first DNS server). BIND forwards to the local endpoint first. Answers come from the local region (whoami 10.255.1.1 in r1)."),
    ("Failover", "Local inbound endpoint unreachable &rarr; clients and BIND retry the <b>remote</b> endpoint across hub peering via the NVAs. Linux &asymp; 5 s, Windows 17&ndash;56 s, BIND &lt; 1 s worst gap; 100% success."),
    ("Failback", "When the local endpoint returns, the next queries use the first DNS server again &ndash; no manual action, no sticky state, no zone or ruleset changes."),
]):
    x = 20 + i * 590
    add(f"st{i}", str(i + 1), S_STEP, x, sy + 10, 32, 32)
    add(f"stt{i}", f"<b>{ttl}</b><br>{body}", S_TEXT + "fontSize=11;", x + 42, sy, 530, 90)

xml = ('<mxfile host="drawio" type="device"><diagram id="refarch" name="Reference architecture">'
       '<mxGraphModel dx="1800" dy="1100" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" '
       'page="1" pageScale="1" pageWidth="1800" pageHeight="1100" background="#FFFFFF" math="0" shadow="0"><root>'
       '<mxCell id="0"/><mxCell id="1" parent="0"/>' + "".join(cells) + "".join(edges) + "</root></mxGraphModel></diagram></mxfile>")
OUT.write_text(xml, encoding="utf-8")
print(f"wrote {OUT} ({len(cells)} vertices, {len(edges)} edges)")
