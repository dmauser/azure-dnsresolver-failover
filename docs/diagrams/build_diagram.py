"""Generate docs/diagrams/dns-resolver-failover-lab.drawio (uncompressed mxGraph XML).

Run:  python docs/diagrams/build_diagram.py
Then export:  draw.io -x -f png -s 2 -b 10 -o dns-resolver-failover-lab.png dns-resolver-failover-lab.drawio
"""
from pathlib import Path
from xml.sax.saxutils import escape

OUT = Path(__file__).with_name("dns-resolver-failover-lab.drawio")
ICON = "image;aspect=fixed;html=1;points=[];align=center;fontSize=10;verticalLabelPosition=bottom;verticalAlign=top;image=img/lib/azure2/"

AZ_BLUE, GREY, RED, ORANGE, GREEN = "#0078D4", "#605E5C", "#D13438", "#CA5010", "#107C10"
S_REGION = f"rounded=1;arcSize=1;whiteSpace=wrap;html=1;fillColor=#F3F2F1;strokeColor={GREY};dashed=1;dashPattern=8 4;verticalAlign=top;align=left;spacingLeft=10;spacingTop=2;fontStyle=1;fontSize=14;fontColor=#323130;container=1;collapsible=0;"
S_VNET = f"rounded=1;arcSize=2;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor={AZ_BLUE};strokeWidth=1.5;verticalAlign=top;align=left;spacingLeft=52;spacingTop=6;fontStyle=1;fontSize=12;fontColor=#201F1E;container=1;collapsible=0;"
S_SUBNET = "rounded=1;arcSize=4;whiteSpace=wrap;html=1;fillColor=#F5FAFF;strokeColor=#8A8886;dashed=1;verticalAlign=top;align=left;spacingLeft=8;spacingTop=2;fontSize=10;fontColor=#323130;container=1;collapsible=0;"
S_BOX = "rounded=1;arcSize=6;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#8A8886;align=left;verticalAlign=top;spacingLeft=8;spacingTop=4;fontSize=10;fontColor=#323130;"
S_TEXT = "text;html=1;whiteSpace=wrap;align=left;verticalAlign=top;fontSize=10;fontColor=#323130;"
S_FAIL = f"ellipse;whiteSpace=wrap;html=1;aspect=fixed;fillColor={RED};strokeColor=#FFFFFF;strokeWidth=2;fontColor=#FFFFFF;fontStyle=1;fontSize=10;shadow=1;"
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


def fail(cid, label, x, y):
    return add(cid, label, S_FAIL, x, y, 34, 34)


def edge(cid, src, tgt, label="", color=AZ_BLUE, dashed=False, width=1.5, pts=None, extra="", both=False):
    style = S_EDGE + f"strokeColor={color};fontColor={color};strokeWidth={width};" + ("dashed=1;" if dashed else "") + extra
    if both:
        style += "startArrow=block;startFill=1;"
    geo = '<mxGeometry relative="1" as="geometry">'
    if pts:
        geo += "<Array as=\"points\">" + "".join(f'<mxPoint x="{a}" y="{b}"/>' for a, b in pts) + "</Array>"
    geo += "</mxGeometry>"
    edges.append(f'<mxCell id="{cid}" value="{escape(label)}" style="{style}" edge="1" parent="1" source="{src}" target="{tgt}">{geo}</mxCell>')


# ---------------------------------------------------------------- title
add("title", "<b style='font-size:20px'>Azure DNS Private Resolver — regional failover lab</b><br>"
    "<span style='font-size:12px;color:#605E5C'>Azure-to-Azure name resolution · four client designs (A–D) · six failure injections (F1–F6) · "
    "every probe result ingested into Log Analytics</span>",
    "text;html=1;whiteSpace=wrap;align=left;verticalAlign=middle;", 20, 10, 1760, 50)

# ---------------------------------------------------------------- region r1
add("reg1", "Region r1 · East US 2  (rg-dnsfo-r1)", S_REGION, 20, 70, 1180, 810)

# spokes
spokes = [
    ("a", "A", "Azure-provided DNS + ruleset → IE1", "10.11.0.0/24", "168.63.129.16 (default)", "dnsfrs-dnsfo-spoke-r1 → [IE1]", ["lnx"]),
    ("b", "B", "Custom DNS [IE1, IE2] (client-side failover)", "10.11.1.0/24", "10.10.0.4, 10.20.0.4", "none", ["lnx", "win"]),
    ("c", "C", "Custom DNS [168.63.129.16, IE2] + ruleset → IE1", "10.11.2.0/24", "168.63.129.16, 10.20.0.4", "dnsfrs-dnsfo-spoke-r1 → [IE1]", ["lnx", "win"]),
    ("d", "D", "Azure-provided DNS + multi-target ruleset", "10.11.3.0/24", "168.63.129.16 (default)", "dnsfrs-dnsfo-spoke-r1-d → [IE1, IE2]", ["lnx"]),
]
SX, SW, SH = 40, 400, 180
for i, (k, D, title, cidr, dns, rs, vms) in enumerate(spokes):
    y = 105 + i * 192
    sid = add(f"spoke_{k}", f"Spoke {D} · Design {D}", S_VNET, SX, y, SW, SH, "reg1")
    icon(f"spoke_{k}_ic", "networking/Virtual_Networks", "", SX + 10, y + 8, sid, 34)
    add(f"spoke_{k}_t", f"<i>{title}</i><br>vnet-dnsfo-spoke-{k} · {cidr}<br><b>VNet DNS:</b> {dns}<br><b>Ruleset link:</b> {rs}",
        S_TEXT, SX + 52, y + 26, 340, 64, sid)
    for j, os_ in enumerate(vms):
        icon(f"vm_{os_}_{k}", "compute/Virtual_Machine", f"vm-dnsfo-{os_}-{k}<br>{'Linux · probe' if os_ == 'lnx' else 'Windows · probe'}",
             SX + 22 + j * 105, y + 100, sid, 38)
    if k == "b":
        icon("nsg_b", "networking/Network_Security_Groups", "nsg-spoke-b", SX + 240, y + 100, sid, 36)
        icon("rt_b", "networking/Route_Tables", "rt-spoke-b", SX + 320, y + 100, sid, 36)

# rulesets column
RX, RW = 470, 230
add("rs_lbl", "<b>Forwarding rulesets</b> (regional, outbound endpoint → target)", S_TEXT, RX, 100, RW, 30, "reg1")
rulesets = [
    ("rs_spoke", "dnsfrs-dnsfo-spoke-r1", "azure. · lab. · privatelink.blob.<br>onprem.contoso.internal<br>→ <b>IE1 only</b> (10.10.0.4)<br>via out-r1 · linked: spoke A, spoke C", 140),
    ("rs_d", "dnsfrs-dnsfo-spoke-r1-d", "same four domains<br>→ <b>[IE1, IE2]</b> (first target preferred)<br>via out2-r1 · linked: spoke D", 120),
    ("rs_hub1", "dnsfrs-dnsfo-hub-r1", "onprem.contoso.internal → dnsmasq 10.10.1.10<br>via out-r1 · linked: hub r1", 95),
]
y = 135
for rid, name, body, h in rulesets:
    add(rid, f"<b>{name}</b><br>{body}", S_BOX + f"strokeColor={AZ_BLUE};", RX, y, RW, h, "reg1")
    y += h + 18
add("lab1", "<b>lab.contoso.internal</b> (r1 copy)<br>whoami → 10.255.1.1<br>linked: hub r1 only<br><i>answer reveals which region resolved</i>",
    S_BOX + f"strokeColor={GREEN};", RX, y + 10, RW, 78, "reg1")
icon("lab1_ic", "networking/DNS_Zones", "", RX + RW - 38, y + 16, "lab1", 28)

# hub r1
HX, HW = 720, 460
add("hub1", "vnet-dnsfo-hub-r1 · 10.10.0.0/22", S_VNET, HX, 105, HW, 765, "reg1")
icon("hub1_ic", "networking/Virtual_Networks", "", HX + 10, 112, "hub1", 34)
icon("dnspr1", "networking/DNS_Private_Resolver", "<b>dnspr-dnsfo-r1</b>", HX + 380, 115, "hub1", 44)


def subnet(sid, label, y, h, parent, x=HX + 15, w=HW - 30):
    return add(sid, label, S_SUBNET, x, y, w, h, parent)


subnet("sn_in1", "<b>snet-dns-inbound</b> · 10.10.0.0/28", 180, 120, "hub1")
icon("ie1", "networking/DNS_Private_Resolver", "<b>Inbound endpoint in-r1</b><br>IE1 = 10.10.0.4", HX + 70, 210, "sn_in1", 40)
icon("nsg_in1", "networking/Network_Security_Groups", "nsg-dns-inbound", HX + 320, 210, "sn_in1", 36)
subnet("sn_out1", "<b>snet-dns-outbound</b> · 10.10.0.16/28", 315, 105, "hub1")
icon("out1", "networking/DNS_Private_Resolver", "<b>Outbound endpoint out-r1</b>", HX + 70, 340, "sn_out1", 36)
icon("nsg_out1", "networking/Network_Security_Groups", "nsg-dns-outbound", HX + 320, 340, "sn_out1", 36)
subnet("sn_out21", "<b>snet-dns-outbound2</b> · 10.10.0.32/28", 435, 95, "hub1")
icon("out21", "networking/DNS_Private_Resolver", "<b>Outbound endpoint out2-r1</b> (Design D ruleset)", HX + 70, 458, "sn_out21", 34)
subnet("sn_wl1", "<b>snet-workload</b> · 10.10.1.0/24", 545, 100, "hub1")
icon("dnsmasq1", "compute/Virtual_Machine", "<b>dnsmasq 10.10.1.10</b><br>simulated on-prem DNS (onprem.contoso.internal)", HX + 70, 568, "sn_wl1", 36)
subnet("sn_pe1", "<b>snet-pe</b> · 10.10.2.0/24", 660, 100, "hub1")
icon("pe1", "networking/Private_Endpoint", "private endpoint (blob)", HX + 70, 685, "sn_pe1", 34)
icon("st1", "storage/Storage_Accounts", "storage account r1", HX + 320, 685, "sn_pe1", 34)
add("hub1_note", "Outbound endpoints egress from their subnet; inbound endpoints receive queries on a static private IP.",
    S_TEXT + "fontColor=#605E5C;fontStyle=2;", HX + 15, 775, HW - 30, 30, "hub1")

# ---------------------------------------------------------------- region r2
add("reg2", "Region r2 · Central US  (rg-dnsfo-r2)", S_REGION, 1240, 70, 540, 810)
H2X, H2W = 1260, 300
add("hub2", "vnet-dnsfo-hub-r2 · 10.20.0.0/22", S_VNET, H2X, 105, H2W, 765, "reg2")
icon("hub2_ic", "networking/Virtual_Networks", "", H2X + 10, 112, "hub2", 34)
icon("dnspr2", "networking/DNS_Private_Resolver", "<b>dnspr-dnsfo-r2</b>", H2X + 230, 115, "hub2", 44)
subnet("sn_in2", "<b>snet-dns-inbound</b> · 10.20.0.0/28", 180, 120, "hub2", H2X + 15, H2W - 30)
icon("ie2", "networking/DNS_Private_Resolver", "<b>Inbound endpoint in-r2</b><br>IE2 = 10.20.0.4", H2X + 110, 210, "sn_in2", 40)
subnet("sn_out2", "<b>snet-dns-outbound</b> · 10.20.0.16/28", 315, 105, "hub2", H2X + 15, H2W - 30)
icon("out2", "networking/DNS_Private_Resolver", "<b>Outbound endpoint out-r2</b>", H2X + 110, 340, "sn_out2", 36)
subnet("sn_wl2", "<b>snet-workload</b> · 10.20.1.0/24", 545, 100, "hub2", H2X + 15, H2W - 30)
icon("dnsmasq2", "compute/Virtual_Machine", "<b>dnsmasq 10.20.1.10</b>", H2X + 110, 568, "sn_wl2", 36)
subnet("sn_pe2", "<b>snet-pe</b> · 10.20.2.0/24", 660, 100, "hub2", H2X + 15, H2W - 30)
icon("pe2", "networking/Private_Endpoint", "private endpoint (blob)", H2X + 60, 685, "sn_pe2", 34)
icon("st2", "storage/Storage_Accounts", "storage account r2", H2X + 190, 685, "sn_pe2", 34)

R2X, R2W = 1575, 190
add("rs_hub2", "<b>dnsfrs-dnsfo-hub-r2</b><br>onprem.contoso.internal<br>→ dnsmasq 10.20.1.10<br>via out-r2 · linked: hub r2",
    S_BOX + f"strokeColor={AZ_BLUE};", R2X, 315, R2W, 90, "reg2")
add("lab2", "<b>lab.contoso.internal</b> (r2 copy)<br>whoami → 10.255.2.2<br>linked: hub r2 only",
    S_BOX + f"strokeColor={GREEN};", R2X, 435, R2W, 70, "reg2")

# ---------------------------------------------------------------- shared
add("shared", "Shared / global  (rg-dnsfo-shared)", S_REGION + "fillColor=#FFFFFF;", 20, 905, 1180, 225)
icon("pz_azure", "networking/DNS_Zones", "<b>azure.contoso.internal</b><br>app1 TTL 10 s · app2 TTL 3600 s<br>linked: hub r1 + hub r2", 90, 950, "shared", 44)
icon("pz_pl", "networking/DNS_Zones", "<b>privatelink.blob.core.windows.net</b><br>PE A-records r1 + r2<br>linked: hub r1 + hub r2", 330, 950, "shared", 44)
icon("dnssec", "networking/DNS_Security_Policy", "<b>DNS security policy</b><br>query logging (hubs)", 570, 950, "shared", 44)
icon("dcr", "other/Data_Collection_Rules", "<b>dcr-dnsfo-probe</b><br>Logs Ingestion API", 790, 950, "shared", 44)
icon("law", "analytics/Log_Analytics_Workspaces", "<b>law-dnsfo</b><br>DnsProbe_CL · DNSQueryLogs", 1010, 950, "shared", 44)
add("shared_note", "Private DNS zones are global resources; only the resolver inbound endpoint that receives the query must be healthy.",
    S_TEXT + "fontColor=#605E5C;fontStyle=2;", 40, 1075, 1140, 40, "shared")

# ---------------------------------------------------------------- legend
add("legend", "Legend", S_REGION + "fillColor=#FFFFFF;", 1240, 905, 540, 225)
legend = [
    ("F1a", "NSG deny all inbound on IE1 subnet (F5u/F5t = UDP-only/TCP-only)"),
    ("F1b", "NSG deny on spoke B egress to 10.10.0.4/32"),
    ("F1c", "F1a + NSG deny on outbound-endpoint subnet"),
    ("F2", "UDR blackhole 10.10.0.4/32 on spoke B"),
    ("F3", "delete spoke ↔ hub r1 peering"),
    ("F4", "delete + recreate inbound endpoint in-r1"),
    ("F6", "unlink ruleset from spoke C"),
]
for i, (f, txt) in enumerate(legend):
    yy = 935 + i * 26
    add(f"lg_{f}", f, S_FAIL + "fontSize=8;", 1255, yy, 22, 22, "legend")
    add(f"lg_{f}_t", txt, S_TEXT + "verticalAlign=middle;", 1283, yy, 300, 22, "legend")
for i, (c, d, txt) in enumerate([(AZ_BLUE, False, "DNS query path"), (ORANGE, True, "failover / secondary target"),
                                  (GREY, False, "VNet peering"), (GREEN, True, "zone / ruleset link")]):
    yy = 940 + i * 40
    add(f"lgl_{i}", "", f"endArrow=block;html=1;strokeWidth=2;strokeColor={c};" + ("dashed=1;" if d else ""), 1600, yy, 0, 0, "legend")
    cells[-1] = (f'<mxCell id="lgl_{i}" value="" style="endArrow=block;endFill=1;html=1;strokeWidth=2;strokeColor={c};{"dashed=1;" if d else ""}" edge="1" parent="1">'
                 f'<mxGeometry relative="1" as="geometry"><mxPoint x="1600" y="{yy + 10}" as="sourcePoint"/><mxPoint x="1650" y="{yy + 10}" as="targetPoint"/></mxGeometry></mxCell>')
    add(f"lgl_{i}_t", txt, S_TEXT + "verticalAlign=middle;", 1655, yy, 120, 22, "legend")

# ---------------------------------------------------------------- edges
# peering
edge("e_peer1", "spoke_b", "hub1", "spokes A–D ↔ hub r1 peering", GREY, width=2, both=True, pts=[(455, 470), (455, 884), (710, 884), (710, 470)], extra="endArrow=none;startArrow=none;")
edge("e_peer12", "hub1", "hub2", "global peering", GREY, width=3, both=True, extra="exitX=1;exitY=0.1;entryX=0;entryY=0.1;")
edge("e_peer2", "spoke_d", "hub2", "spokes A–D ↔ hub r2 peering", GREY, width=2, dashed=False, both=True,
     pts=[(240, 890), (1230, 890), (1230, 820)], extra="exitX=0.5;exitY=1;entryX=0;entryY=0.93;")
# design B client queries
edge("e_b_ie1", "vm_lnx_b", "ie1", "primary", AZ_BLUE, width=2, extra="exitX=1;exitY=0.3;", pts=[(447, 407), (447, 291), (690, 291), (690, 230)])
edge("e_b_ie2", "vm_win_b", "ie2", "secondary", ORANGE, dashed=True, width=2, extra="exitX=1;exitY=0.7;", pts=[(451, 422), (451, 294), (1230, 294), (1230, 230)])
# ruleset targets
edge("e_rs_ie1", "rs_spoke", "ie1", "target", AZ_BLUE, width=2, extra="exitX=1;exitY=0.4;")
edge("e_rsd_ie1", "rs_d", "ie1", "1st target", AZ_BLUE, width=2, extra="exitX=1;exitY=0.3;", pts=[(708, 343), (708, 245)])
edge("e_rsd_ie2", "rs_d", "ie2", "2nd", ORANGE, dashed=True, width=2, extra="exitX=1;exitY=0.7;", pts=[(1215, 372), (1215, 245)])
edge("e_rs_dnsmasq", "rs_hub1", "dnsmasq1", "", AZ_BLUE, width=1.5, extra="exitX=1;exitY=0.5;entryX=0;entryY=0.5;")
edge("e_rs2_dnsmasq", "rs_hub2", "dnsmasq2", "", AZ_BLUE, width=1.5, extra="exitX=0.5;exitY=1;", pts=[(1670, 586)])
# ruleset links (to spokes)
edge("e_lnk_a", "rs_spoke", "spoke_a", "link", GREEN, dashed=True, width=1.5, extra="exitX=0;exitY=0.25;entryX=1;entryY=0.5;")
edge("e_lnk_c", "rs_spoke", "spoke_c", "link", GREEN, dashed=True, width=1.5, extra="exitX=0;exitY=0.75;entryX=1;entryY=0.5;", pts=[(458, 240), (458, 579)])
edge("e_lnk_d", "rs_d", "spoke_d", "link", GREEN, dashed=True, width=1.5, extra="exitX=0;exitY=0.7;entryX=1;entryY=0.5;", pts=[(462, 372), (462, 771)])
# zone links
edge("e_zone1", "pz_azure", "hub1", "", GREEN, dashed=True, width=1.5, extra="entryX=0.3;entryY=1;", pts=[(112, 896), (858, 896)])
edge("e_zone2", "pz_pl", "hub2", "", GREEN, dashed=True, width=1.5, extra="entryX=0.5;entryY=1;", pts=[(352, 902), (1410, 902)])
edge("e_law", "dcr", "law", "", AZ_BLUE, width=1.5)

# failure markers
fail("f1a", "F1a<br>F5", 1130, 205)
fail("f1b", "F1b", 312, 460)
fail("f2", "F2", 392, 460)
fail("f1c", "F1c", 1130, 335)
fail("f3", "F3", 438, 830)
fail("f4", "F4", 768, 205)
fail("f6", "F6", 470, 500)

xml = ('<mxfile host="drawio" type="device"><diagram id="lab" name="DNS Private Resolver failover lab">'
       '<mxGraphModel dx="1800" dy="1150" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" '
       'page="1" pageScale="1" pageWidth="1800" pageHeight="1150" background="#FFFFFF" math="0" shadow="0"><root>'
       '<mxCell id="0"/><mxCell id="1" parent="0"/>' + "".join(cells) + "".join(edges) + "</root></mxGraphModel></diagram></mxfile>")
OUT.write_text(xml, encoding="utf-8")
print(f"wrote {OUT} ({len(cells)} vertices, {len(edges)} edges)")
