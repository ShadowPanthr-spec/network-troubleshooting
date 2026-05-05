# Security Notes: When Network Instability Is Adversarial

The phases in [METHODOLOGY.md](./METHODOLOGY.md) assume the cause of network instability is **accidental** — a degraded cable, a scheduled job, an upstream ISP issue. That assumption is usually correct, and starting with low-cost local checks is exactly the right default.

But the same symptoms can also be **deliberate**. A cybersecurity-aware troubleshooter holds both possibilities in mind and watches for signatures that distinguish them. This document maps each phase of the methodology to the attack patterns most likely to mimic the symptoms there, and notes how a defender would tell the difference.

> The voice here is "what to look for," not "what I have hunted in production." This is the analyst mindset I'm building toward, anchored to a framework I already use.

---

## Phase 1 mirror — endpoint compromise

The Phase 1 question is *"is this isolated or systemic?"* The adversarial mirror asks *"is the affected host compromised?"*

**Symptoms that warrant a closer look:**

- Persistent DNS-resolution failures on a single host (consider local hosts file or DNS-cache tampering)
- Workstation logs showing repeated outbound connections to unfamiliar IPs at regular intervals (consider command-and-control beaconing)
- Configuration drift on a single host with no change ticket (consider unauthorized local-admin activity)

**How a defender distinguishes from accidental causes:**

- Compare `C:\Windows\System32\drivers\etc\hosts` against a known-good copy. Legitimate edits are rare; tampered hosts files are a classic redirection technique.
- Review Windows Event Viewer (and Sysmon, if deployed) for outbound connection patterns. Beaconing has a regular cadence; legitimate user traffic is bursty and varied.
- Examine process trees. Office applications spawning `cmd.exe` or `PowerShell` is suspicious; legitimate workflow rarely produces that parent-child relationship.

---

## Phase 2 mirror — traffic-layer attacks

This is where Phase 2 traffic analysis becomes security analysis. The same Wireshark capture that catches a broadcast storm can catch:

- **ARP poisoning / spoofing** — duplicate IP-to-MAC mappings, or rapid changes to the ARP table on the local segment. Often visible as gratuitous ARP replies.
- **Rogue DHCP server** — multiple DHCP OFFER responses on the wire, hosts receiving unexpected default gateways.
- **Beaconing C2 traffic** — small, regularly timed outbound connections to a consistent external IP, often during off-hours.
- **Unauthorized port mirroring (SPAN)** — visible only by inspecting switch configuration; the traffic itself looks normal at the wire.

**How a defender distinguishes:**

| Pattern | Adversarial signature | Accidental signature |
| --- | --- | --- |
| Traffic explosion | Targeted, structured (e.g. ARP spoofing) | Random, unstructured (e.g. broadcast storm) |
| Outbound connections | Regular cadence, single destination | Bursty, varied destinations |
| Configuration changes | No change ticket, unusual hours | Tied to a documented rollout |

---

## Phase 3 mirror — scheduled-task abuse

Phase 3 looks for legitimate scheduled tasks that could explain timed bandwidth spikes. The adversarial mirror is **scheduled-task abuse for persistence** — [MITRE ATT&CK technique T1053](https://attack.mitre.org/techniques/T1053/).

**Warning signs:**

- A "scheduled backup" running at 02:00 that nobody on the IT team configured
- Scheduled tasks pointing to binaries in unusual paths: `C:\ProgramData\`, `C:\Users\Public\`, or anywhere under `AppData`
- Sudden changes to scheduled task definitions without a corresponding change ticket
- Tasks that run with SYSTEM privileges and were created by an account that shouldn't have admin rights

**How a defender distinguishes:**

- Compare the current scheduled-task inventory against a baseline snapshot from a known-good state.
- Check the SID of the principal that created each task. Built-in service accounts are normal; unexpected user accounts are not.
- Verify the binary the task invokes against an allowlist (AppLocker / WDAC) where available.

---

## Phase 4 mirror — supply-chain and firmware concerns

Phase 4 escalates to the manufacturer for hardware diagnostics. The adversarial mirror is **firmware-level compromise** — much rarer than the others, but consequential when it happens, because firmware sits below the operating system's visibility.

**Warning signs:**

- Network appliances reporting firmware versions that don't match the vendor's published build numbers
- Devices behaving inconsistently after a firmware update sourced from anywhere other than the vendor portal
- New unsolicited management traffic from network appliances to unknown destinations

This layer is where troubleshooting hands off to a dedicated security investigation. The right move is to isolate the device, capture its current firmware image if possible, and engage the vendor's product security response team — not to attempt local remediation, which can destroy evidence.

---

## The unifying principle

The methodology in [METHODOLOGY.md](./METHODOLOGY.md) is designed to find the **most likely** cause first. That's the right default — most network problems are accidents, not attacks, and chasing adversaries every time you see a packet drop is a fast way to burn out an IT team.

But "most likely" is statistical, not absolute. The cost of being wrong rises sharply when the cause actually *is* an adversary already in the environment, because every minute of accidental-cause troubleshooting is a minute they have to dig in deeper.

A useful habit at each phase, before declaring an issue resolved:

> *Could this also be explained by an attack? If yes, and the evidence doesn't decisively rule it out, log the symptom and capture supporting data before clearing the ticket.*

Lost evidence is the most common reason intrusions go undetected for months.

---

## Reference frameworks

- [MITRE ATT&CK](https://attack.mitre.org) — adversarial technique catalog. Most useful for naming what you're looking at.
- CompTIA Network+ troubleshooting methodology — the operational backbone of [METHODOLOGY.md](./METHODOLOGY.md), and the structure I'm mirroring here for security.

---

For the operational framework this document mirrors, see [METHODOLOGY.md](./METHODOLOGY.md). For an applied incident walkthrough, see [CASE_STUDY.md](./CASE_STUDY.md).
