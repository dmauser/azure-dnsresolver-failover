"""Generate docs/diagrams/reference-architecture-b-onprem.drawio (uncompressed mxGraph XML).

Recommended reference architecture (Design B) with an emulated on-premises:
two on-prem locations, each with a BIND DNS server forwarding to BOTH resolver
inbound endpoints, plus an Azure spoke whose VNet custom DNS is [IE1, IE2].

Run:     python docs/diagrams/build_diagram_b_onprem.py
Export:  draw.io -x -f png -s 2 -b 10 -o reference-architecture-b-onprem.png reference-architecture-b-onprem.drawio
         draw.io -x -f svg -b 10 -o reference-architecture-b-onprem.svg reference-architecture-b-onprem.drawio
"""
from pathlib import Path
from xml.sax.saxutils import escape

OUT = Path(__file__).with_name("reference-architecture-b-onprem.drawio")
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


# ---------------------------------------------------------------- title
add("title", "<b style='font-size:20px'>Recommended reference architecture — Design B: DNS Private Resolver regional failover with on-premises</b><br>"
    "<span style='font-size:12px;color:#605E5C'>Every DNS client (on-premises DNS servers and Azure VNets) lists BOTH resolver inbound endpoints. "
    "Failover and failback are performed by the client — no Azure-side reconfiguration.</span>",
    "text;html=1;whiteSpace=wrap;align=left;verticalAlign=middle;", 20, 10, 1760, 55)

# ---------------------------------------------------------------- on-premises
add("onprem", "On-premises  (emulated: 2 VNets · rg-dnsfo-onprem1 / 2)", S_ONPREM, 20, 80, 500, 860)

sites = [
    ("op1", "1", "10.110.0.0/16", "10.110.0.10", "10.10.0.4; 10.20.0.4;", 120),
    ("op2", "2", "10.120.0.0/16", "10.120.0.10", "10.20.0.4; 10.10.0.4;", 520),
]
for k, n, cidr, bind, fwd, y in sites:
    sid = add(f"site_{k}", f"Location {n} · vnet-dnsfo-{k} · {cidr}", S_SITE, 40, y, 460, 390, "onprem")
    icon(f"site_{k}_ic", "networking/Virtual_Networks", "", 50, y + 8, sid, 34)
    add(f"cfg_{k}", "<b>named.conf (excerpt)</b><br>"
        "<font face='Consolas'>zone \"azure.contoso.internal\"<br>zone \"privatelink.blob.core.windows.net\"<br>zone \"lab.contoso.internal\"<br>"
        f"&nbsp;&nbsp;type forward; forward only;<br>&nbsp;&nbsp;forwarders {{ {fwd} }};</font><br><br>"
        f"Authoritative: <b>{k}.onprem.contoso.internal</b><br>max-cache-ttl 5 s · querylog on",
        S_BOX + f"strokeColor={PURPLE};", 55, y + 55, 235, 200, sid)
    add(f"note_{k}", "<i>BIND tries forwarders by measured RTT (not list order) and marks unresponsive ones down — "
        "both endpoints carry load; failover is automatic.</i>", S_TEXT + "fontColor=#605E5C;", 55, y + 270, 235, 70, sid)
    add(f"site_{k}_sn", "<b>snet-servers</b>", S_SUBNET, 305, y + 55, 180, 315, sid)
    icon(f"bind_{k}", "compute/Virtual_Machine", f"<b>vm-dnsfo-bind-{k}</b><br>BIND 9 DNS server<br>{bind}", 373, y + 94, f"site_{k}_sn", 44)
    icon(f"cli_{k}", "compute/Virtual_Machine", f"<b>vm-dnsfo-lnx-{k}</b><br>client · probe<br>resolv.conf → {bind}", 375, y + 250, f"site_{k}_sn", 40)
    edge(f"e_cli_{k}", f"cli_{k}", f"bind_{k}", "", PURPLE, width=1.5,
         extra="exitX=0;exitY=0.5;entryX=0;entryY=0.5;", pts=[(325, y + 270), (325, y + 116)])

# ---------------------------------------------------------------- hybrid connectivity (transit corridor)
add("conn", "<b>Hybrid connectivity</b>", S_BOX + "fillColor=#F3F2F1;strokeColor=#8A8886;strokeWidth=1.5;dashed=1;align=center;spacingLeft=0;fontSize=12;", 570, 120, 170, 790)
add("conn_t", "<b>Lab default:</b> VNet peering<br>each location ↔ hub r1 <u>and</u> hub r2<br><br>"
    "<b>Lab option:</b> VPN Gateway S2S + BGP<br>(-Connectivity Vpn)<br><br>"
    "<b>Production:</b> ExpressRoute and/or S2S VPN to BOTH regions",
    S_TEXT + "align=center;", 575, 720, 160, 130)
icon("conn_ic", "networking/Virtual_Network_Gateways", "", 638, 855, "1", 34)
# ---------------------------------------------------------------- region r1
add("reg1", "Azure region r1 · East US 2  (rg-dnsfo-r1)", S_REGION, 780, 80, 690, 420)
add("hub1", "vnet-dnsfo-hub-r1 · 10.10.0.0/22", S_VNET, 800, 115, 380, 370, "reg1")
icon("hub1_ic", "networking/Virtual_Networks", "", 810, 122, "hub1", 34)
icon("dnspr1", "networking/DNS_Private_Resolver", "<b>dnspr-dnsfo-r1</b>", 1110, 122, "hub1", 40)
add("sn_in1", "<b>snet-dns-inbound</b> · 10.10.0.0/28", S_SUBNET, 815, 185, 350, 125, "hub1")
icon("ie1", "networking/DNS_Private_Resolver", "<b>Inbound endpoint — IE1</b><br>10.10.0.4 (static)", 870, 215, "sn_in1", 42)
icon("nsg_in1", "networking/Network_Security_Groups", "nsg-dns-inbound", 1060, 252, "sn_in1", 30)
add("sn_out1", "<b>snet-dns-outbound</b> · 10.10.0.16/28", S_SUBNET, 815, 320, 350, 150, "hub1")
icon("out1", "networking/DNS_Private_Resolver", "<b>Outbound endpoint</b>", 870, 345, "sn_out1", 34)
add("rs1", "<b>Ruleset (production)</b><br>onprem.contoso.internal → on-prem DNS servers (both locations)<br><i>not wired in the lab</i>",
    S_BOX + f"strokeColor={GREY};dashed=1;", 960, 340, 195, 75, "sn_out1")

add("spokeb", "vnet-dnsfo-spoke-b · 10.11.1.0/24", S_VNET, 1200, 115, 255, 370, "reg1")
icon("spokeb_ic", "networking/Virtual_Networks", "", 1210, 122, "spokeb", 34)
add("spokeb_t", "<b>VNet DNS servers (custom)</b><br>1. 10.10.0.4 — IE1 (primary)<br>2. 10.20.0.4 — IE2 (secondary)",
    S_BOX + f"strokeColor={AZ_BLUE};", 1215, 175, 225, 62, "spokeb")
icon("vm_lnx_b", "compute/Virtual_Machine", "<b>vm-dnsfo-lnx-b</b><br>Linux probe", 1240, 290, "spokeb", 40)
icon("vm_win_b", "compute/Virtual_Machine", "<b>vm-dnsfo-win-b</b><br>Windows probe", 1360, 290, "spokeb", 40)
add("spokeb_n", "<i>Peered to hub r1 AND hub r2. No forwarding ruleset link needed.</i>",
    S_TEXT + "fontColor=#605E5C;", 1215, 405, 225, 40, "spokeb")

# ---------------------------------------------------------------- region r2
add("reg2", "Azure region r2 · Central US  (rg-dnsfo-r2)", S_REGION, 780, 520, 690, 420)
add("hub2", "vnet-dnsfo-hub-r2 · 10.20.0.0/22", S_VNET, 800, 555, 380, 370, "reg2")
icon("hub2_ic", "networking/Virtual_Networks", "", 810, 562, "hub2", 34)
icon("dnspr2", "networking/DNS_Private_Resolver", "<b>dnspr-dnsfo-r2</b>", 1110, 562, "hub2", 40)
add("sn_in2", "<b>snet-dns-inbound</b> · 10.20.0.0/28", S_SUBNET, 815, 625, 350, 125, "hub2")
icon("ie2", "networking/DNS_Private_Resolver", "<b>Inbound endpoint — IE2</b><br>10.20.0.4 (static)", 870, 655, "sn_in2", 42)
icon("nsg_in2", "networking/Network_Security_Groups", "nsg-dns-inbound", 1060, 700, "sn_in2", 30)
add("sn_out2", "<b>snet-dns-outbound</b> · 10.20.0.16/28", S_SUBNET, 815, 760, 350, 150, "hub2")
icon("out2", "networking/DNS_Private_Resolver", "<b>Outbound endpoint</b>", 870, 785, "sn_out2", 34)
add("rs2", "<b>Ruleset (production)</b><br>onprem.contoso.internal → on-prem DNS servers (both locations)<br><i>not wired in the lab</i>",
    S_BOX + f"strokeColor={GREY};dashed=1;", 960, 780, 195, 75, "sn_out2")
add("r2_note", "<b>Standby region</b><br>Same resolver build as r1, deployed active-active. "
    "IE2 answers from the same global private DNS zones, so answers are identical.<br><br>"
    "Workload spokes in r2 mirror spoke B with the order reversed: <b>[IE2, IE1]</b>.",
    S_BOX + f"strokeColor={AZ_BLUE};", 1200, 555, 255, 150, "reg2")

# ---------------------------------------------------------------- shared / global
add("shared", "Global  (rg-dnsfo-shared)", S_REGION + "fillColor=#FFFFFF;", 1490, 80, 290, 560)
icon("pz_azure", "networking/DNS_Zones", "<b>azure.contoso.internal</b><br>app1 → 10.50.0.1", 1610, 120, "shared", 44)
icon("pz_pl", "networking/DNS_Zones", "<b>privatelink.blob.core.windows.net</b><br>private endpoint A records", 1610, 230, "shared", 44)
icon("pz_lab", "networking/DNS_Zones", "<b>lab.contoso.internal</b> (test zone)<br>r1 copy: whoami → 10.255.1.1<br>r2 copy: whoami → 10.255.2.2", 1610, 340, "shared", 44)
add("shared_n", "Private DNS zones are global. Link each zone to BOTH hub VNets — "
    "only the inbound endpoint that receives the query has to be healthy.<br><br>"
    "The per-region <b>lab.</b> zone copies let every probe record which region answered.",
    S_TEXT + "fontColor=#605E5C;fontStyle=2;", 1505, 470, 260, 150, "shared")

# ---------------------------------------------------------------- legend
add("legend", "Legend", S_REGION + "fillColor=#FFFFFF;", 1490, 660, 290, 280)
leg = [(AZ_BLUE, False, "primary DNS path"), (ORANGE, True, "secondary DNS path (failover)"),
       (GREY, False, "VNet peering / hybrid link"), (GREEN, True, "private DNS zone link"),
       (PURPLE, False, "on-prem client → local DNS")]
for i, (c, d, txt) in enumerate(leg):
    yy = 700 + i * 30
    line(f"lg_{i}", 1505, yy + 10, 1560, yy + 10, c, d)
    add(f"lg_{i}_t", txt, S_TEXT + "verticalAlign=middle;", 1570, yy, 200, 22, "legend")
add("lg_f1a", "F1a", S_FAIL, 1505, 860, 26, 26, "legend")
add("lg_f1a_t", "Emulated outage: NSG deny-all on IE1 subnet", S_TEXT + "verticalAlign=middle;", 1537, 860, 235, 26, "legend")
add("lg_lb", "LB", S_FAIL, 1505, 895, 26, 26, "legend")
add("lg_lb_t", "Emulated link break: Location 1 ↔ hub r1", S_TEXT + "verticalAlign=middle;", 1537, 895, 235, 26, "legend")

# ---------------------------------------------------------------- failover / failback strip
add("flow", "", "rounded=1;arcSize=4;whiteSpace=wrap;html=1;fillColor=#FFFFFF;strokeColor=#C8C6C4;", 20, 960, 1760, 125)
steps = [
    ("1", "Normal operation", "Each client queries its preferred inbound endpoint (spoke B → IE1). "
     "The other endpoint is a hot standby that serves the same zones."),
    ("2", "Failover", "IE1 or region r1 becomes unreachable. The client's own resolver times out and retries the next "
     "listed server (IE2). Measured: Linux ≈5 s, Windows 17–56 s, BIND ≈ one query timeout."),
    ("3", "Failback", "When IE1 recovers, Linux returns to IE1 on the next query; Windows and BIND return after their "
     "server-health timers expire. No DNS or VNet configuration changes are needed."),
]
for i, (n, head, body) in enumerate(steps):
    x = 40 + i * 585
    add(f"st_{n}", n, S_STEP, x, 985, 34, 34)
    add(f"st_{n}_t", f"<b style='font-size:12px'>{head}</b><br>{body}", S_TEXT + "fontSize=11;", x + 45, 975, 520, 100)

# ---------------------------------------------------------------- edges
def link(cid, x1, y, x2):
    edges.append(f'<mxCell id="{cid}" value="" style="html=1;strokeWidth=3;strokeColor={GREY};endArrow=block;endFill=1;startArrow=block;startFill=1;" '
                 f'edge="1" parent="1"><mxGeometry relative="1" as="geometry"><mxPoint x="{x1}" y="{y}" as="sourcePoint"/>'
                 f'<mxPoint x="{x2}" y="{y}" as="targetPoint"/></mxGeometry></mxCell>')


# hybrid links (grey): site <-> corridor <-> hub
link("l_op1_c", 500, 470, 570)
link("l_c_h1", 740, 470, 800)
link("l_op2_c", 500, 880, 570)
link("l_c_h2", 740, 880, 800)
# spoke B peerings
edge("e_sb_h1", "spokeb", "hub1", "", GREY, width=2, both=True, extra="exitX=0;exitY=0.85;entryX=1;entryY=0.85;")
edge("e_sb_h2", "spokeb", "hub2", "", GREY, width=2, both=True, extra="exitX=0.5;exitY=1;entryX=0.92;entryY=0;", pts=[(1327, 510), (1150, 510)])
# on-prem DNS forwarding
edge("e_b1_ie1", "bind_op1", "ie1", "primary", AZ_BLUE, width=2, extra="exitX=1;exitY=0.5;entryX=0;entryY=0.5;")
edge("e_b1_ie2", "bind_op1", "ie2", "secondary", ORANGE, dashed=True, width=2, extra="exitX=1;exitY=0.8;entryX=0;entryY=0.85;", pts=[(720, 249), (720, 691)])
edge("e_b2_ie2", "bind_op2", "ie2", "primary", AZ_BLUE, width=2, extra="exitX=1;exitY=0.5;entryX=0;entryY=0.25;", pts=[(610, 636), (610, 666)])
edge("e_b2_ie1", "bind_op2", "ie1", "secondary", ORANGE, dashed=True, width=2, extra="exitX=1;exitY=0.8;entryX=0;entryY=0.2;", pts=[(670, 649), (670, 223)])
# spoke B DNS
edge("e_vb_ie1", "spokeb_t", "ie1", "primary", AZ_BLUE, width=2, extra="exitX=0;exitY=0.4;entryX=1;entryY=0.4;", pts=[(1172, 200), (1172, 232)])
edge("e_vb_ie2", "spokeb_t", "ie2", "", ORANGE, dashed=True, width=2, extra="exitX=0;exitY=0.8;entryX=1;entryY=0.6;", pts=[(1192, 225), (1192, 680)])
# zone links (labels omitted; see legend)
edge("e_z_h1", "pz_azure", "hub1", "", GREEN, dashed=True, width=1.5, extra="exitX=0;exitY=0.5;entryX=1;entryY=0.07;", pts=[(1480, 142), (1480, 100), (1186, 100), (1186, 141)])
edge("e_z_h2", "pz_pl", "hub2", "", GREEN, dashed=True, width=1.5, extra="exitX=0;exitY=0.5;entryX=1;entryY=0.95;", pts=[(1480, 252), (1480, 906)])

# emulated failure markers
add("f1a", "F1a", S_FAIL, 916, 200, 28, 28)
add("flb", "LB", S_FAIL, 531, 456, 28, 28)
xml = ('<mxfile host="drawio" type="device"><diagram id="refarch-b" name="Design B with on-premises">'
       '<mxGraphModel dx="1800" dy="1100" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" '
       'page="1" pageScale="1" pageWidth="1800" pageHeight="1100" background="#FFFFFF" math="0" shadow="0"><root>'
       '<mxCell id="0"/><mxCell id="1" parent="0"/>' + "".join(cells) + "".join(edges) + "</root></mxGraphModel></diagram></mxfile>")
OUT.write_text(xml, encoding="utf-8")
print(f"wrote {OUT} ({len(cells)} vertices, {len(edges)} edges)")
