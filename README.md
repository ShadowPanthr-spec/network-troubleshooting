# Network Troubleshooting: Methodology and Case Study

A portfolio piece showing how I approach network instability — the general framework I follow, and a specific incident where I walked it end to end.

## Contents

| File | What it is |
| --- | --- |
| `METHODOLOGY.md` | A four-phase framework for diagnosing intermittent network issues. The mental model. |
| `CASE_STUDY.md` | A real incident: intermittent drops to global servers, isolated to a faulty cable using `pathping`. The framework applied. |
| `SECURITY_NOTES.md` | The adversarial mirror of the methodology. What does each phase look like when the cause is an attacker, not an accident? |
| `scripts/Capture-Pathping.ps1` | PowerShell utility that captures `pathping` output to timestamped log files. Real, runnable. |
| `scripts/sample-output/` | Illustrative sample of a `pathping` capture, annotated to show how to read it. |

## Why split this way

The methodology shows how I think. The case study shows that I've actually walked the framework end to end. The security notes show I hold both accidental and adversarial hypotheses in mind. The scripts show the documentation isn't theoretical — there's working tooling behind it.

Splitting into focused files lets a reader skim for the signal they care about without wading through the rest.

## What this repo demonstrates

- Systematic, layered troubleshooting aligned with the CompTIA Network+ methodology and OSI-model thinking
- Command-line fluency: PowerShell scripting, `pathping`, `tracert`, packet capture at the core switch
- Cybersecurity-aware analysis: distinguishing accidental network failures from adversarial mimicry, with reference to MITRE ATT&CK
- Stakeholder expectation management during active incidents (under-promise, over-deliver)
- Documentation habits that make incidents reproducible and auditable

## Tools referenced

PowerShell · `pathping` · `tracert` · Wireshark · ICMP behavior analysis · physical-layer diagnostics · MITRE ATT&CK

---

## How to read this repo

- **30 seconds** — read this page.
- **2 minutes** — skim `METHODOLOGY.md` for the four-phase framework.
- **5 minutes** — read `CASE_STUDY.md` for the worked example, with the sample `pathping` output open alongside.
- **10 minutes** — finish with `SECURITY_NOTES.md` for the adversarial mirror.
