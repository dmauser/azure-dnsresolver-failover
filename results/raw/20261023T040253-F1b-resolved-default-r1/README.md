# INVALID RUN — do not use for conclusions

F1b (NSG deny UDP+TCP/53 outbound from spoke B to IE r1 10.10.0.4) was applied and appeared in the NIC's effective security rules, but DNS to 10.10.0.4 from the spoke-B VMs kept succeeding (UDP and TCP). The failure was never actually injected, so this run measures a healthy baseline.

It is kept for transparency. See `docs/why-this-design.md` (results note and observation 7).
