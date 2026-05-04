# Network Instability: A Troubleshooting Methodology

A repeatable, time-prioritized framework for isolating intermittent connectivity issues during or after a deployment. The goal is to minimize downtime, keep stakeholders calmly informed, and avoid the most common trap: escalating to vendors or ISPs before the cheap, fast checks are exhausted.

## Guiding principle

**Eliminate the reachable first.** The cheapest variable to control is the one already inside your administrative boundary. Work outward from there.

---

## The four phases

### Phase 1 — Internal triage and endpoint verification

**Goal:** rule out the easy stuff before anyone else gets involved.

- **Workstation audit.** Pull endpoint logs and configurations. Is the issue isolated to one host or systemic across the floor?
- **Cabling and power.** Verify physical-layer integrity. Are power supplies rated for the throughput? Under-rated cables and supplies cause heat-driven intermittent drops that look like network problems and waste days of investigation.
- **Configuration baseline.** Diff the current live configuration against a known-good baseline from day one. Verify firewall rules and port settings against vendor best practices.

> *Applied in practice:* see [CASE_STUDY.md](./CASE_STUDY.md). Phase 1 is where the faulty cable was eventually isolated.

### Phase 2 — External and environmental analysis

**Goal:** determine whether the fault lives outside the local administrative boundary.

- **ISP and demarcation point.** Trace traffic past the D-mark to isolate ISP-side issues. Path-trace to known global servers to identify upstream bottlenecks or regional outages.
- **Physical environment.** Walk the server room. Electromagnetic interference from motors, copiers, or other high-power equipment near network racks will degrade signal integrity in ways the logs don't show.
- **Traffic analysis.** Capture packets at the core switch with Wireshark. Look for broadcast storms, ARP floods, or anomalous patterns that can starve legitimate traffic.

### Phase 3 — System logic and rollback strategy

**Goal:** rule out software, firmware, and scheduled-task interactions before reaching for hardware.

- **Scheduled task audit.** If drops happen at the same time every day, check for backups, database syncs, or update jobs that could saturate the link. Recurring timing is itself diagnostic data.
- **Rollback protocol.** Reverting to a known-good state is the cleanest way to differentiate a configuration regression from a hardware failure. If the rollback resolves it, the rollout introduced it.
- **Firmware validation.** Treat firmware as a tier-two fix. Vendor patch notes sometimes describe the exact load conditions you're observing.

### Phase 4 — Escalation and hardware replacement

**Goal:** address physical hardware degradation only after the cheaper paths are exhausted.

- **Manufacturer diagnostics.** Open a ticket with the vendor for deep-dive diagnostics under the maintenance plan.
- **RMA / replacement.** If internal diagnostics, factory resets, and software fixes have all failed, the logic points to hidden hardware faults — failing memory, intermittent solder joints, degraded optics — and a unit replacement is justified.

---

## Timeline and stakeholder expectations

Communicated up front, following the under-promise / over-deliver principle. Real resolutions almost always come in faster than this, but giving leadership the worst case lets them plan around it.

| Milestone | Estimated duration |
| --- | --- |
| Initial triage and isolation | 1–2 days |
| Manufacturer deep-dive diagnostic | 2–3 days |
| Hardware shipping (if required) | 2–5 days |
| Configuration and reinstallation | 1 day |
| **Total recovery time (worst case)** | **1–2 weeks** |

---

## Key takeaways

- **Eliminate the reachable.** Always start with internal data — logs, cabling, baselines — before escalating to external providers like the ISP or a hardware vendor.
- **Timing is data.** Recurring drops at the same time often point to scheduled jobs masking themselves as network instability.
- **The baseline is everything.** A day-one configuration record is the only fast way to detect drift introduced during a rollout.
- **Document while you investigate, not after.** Timestamped tool output turns a story you tell into evidence anyone can audit.

---

## See also

- [CASE_STUDY.md](./CASE_STUDY.md) — applied walkthrough of Phases 1 and 2 against a real incident.
- [SECURITY_NOTES.md](./SECURITY_NOTES.md) — the adversarial mirror of each phase. What does it look like when network instability isn't accidental?
