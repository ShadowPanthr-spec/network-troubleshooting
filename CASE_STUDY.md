# Case Study: Intermittent Drops to Global Servers

> **Context.** Lab scenario based on the CompTIA Network+ troubleshooting framework. The incident, environment, and resolution below describe how I would walk the methodology end to end against this kind of failure, not a production engagement. The PowerShell capture script in [scripts/](./scripts/) is real and runnable.

## The incident

On day two of full operational capability after a network deployment, the company began experiencing intermittent connectivity drops to global servers. The drops persisted day and night for three days and caused unpredictable breaks in productivity. The IT team needed to diagnose the issue methodically and prioritize limiting downtime.

## Approach

I applied the standard seven-step troubleshooting methodology — closely aligned with the CompTIA Network+ framework, and consistent with Phases 1 and 2 of my [general methodology](./METHODOLOGY.md).

### 1. Identify the problem

Intermittent internet connectivity to global servers from employee host computers.

### 2. Collect information

After interviewing employees, I confirmed the issue surfaced when staff were stationary at their workstations — not roaming. That ruled out a wireless handoff issue and pointed toward the wired path.

### 3. Develop a hypothesis

A drop somewhere between the local network and the destination, most likely at the first wired hop or the link feeding it.

### 4. Test the theory

I ran `pathping` from PowerShell against a known-stable global target:

```powershell
pathping 8.8.8.8 -q 30
```

The `Lost/Sent = Pct` value under the `This Node/Link` column showed **35% packet loss on the first hop** — the router immediately upstream of the host. Repeating `pathping` during each occurrence consistently pointed to the same link, which made the failure pattern reproducible rather than ghostly.

> Why `pathping` and not `tracert`? See the [tool deep-dive](#tool-deep-dive-pathping) below.

### 5. Establish a plan and implement the solution

The data pointed to the **link**, not the **hop** — meaning the cable between the host and the first router, not the router itself. I swapped the cable. The drops stopped.

### 6. Verify and implement preventive measures

I monitored the network for a week. No further intermittent connectivity events. Resolved.

### 7. Document findings

Each `pathping` run was captured to a timestamped `.txt` file via [scripts/Capture-Pathping.ps1](./scripts/Capture-Pathping.ps1) and bundled with this README. A redacted sample run is included at [scripts/sample-output/](./scripts/sample-output/). Reproducibility matters; the next person who encounters this pattern shouldn't have to rederive it.

---

## Tool deep-dive: pathping

`pathping` was the right tool here because it combines two things `tracert` and `ping` do separately:

- `ping` answers "are you there?"
- `tracert` answers "what path did my packet take?"
- `pathping` answers both, **and** adds per-hop packet loss statistics over a sampling window.

That last part is what makes it the right tool for intermittent problems. A single `tracert` might catch a clean run; `pathping` accumulates samples and surfaces the loss percentage at each hop, making transient failures visible.

It is also useful for catching false positives. ICMP packets are often deprioritized or filtered by Windows hosts (Defender, host firewalls, or upstream policy). If `pathping` shows a drop at one hop but the loss does not propagate downstream, that is a strong signal that the hop is dropping ICMP rather than dropping the actual user traffic — i.e., a false positive that would mislead a less careful analyst.

### Reading pathping output

| Column | What it tells you |
| --- | --- |
| **Hop** | Sequential router count from the source. Hop 0 is the local host. |
| **RTT** | Round-trip time in milliseconds for a packet to leave and return. |
| **Source to Here** | Cumulative packet loss percentage from the host up through this hop. |
| **This Node/Link** | Loss percentage on this specific hop or the link feeding it. The most diagnostic column for isolating where a drop lives. |
| **Address** | FQDN and IPv4 / IPv6 of the current hop. |

### Useful options

| Flag | Purpose |
| --- | --- |
| `-g host-list` | Loose source route along the specified host list. |
| `-h maximum_hops` | Maximum number of hops to search for the target. |
| `-i address` | Use the specified source address. |
| `-n` | Do not resolve addresses to hostnames (faster output, less noise). |
| `-p period` | Wait `period` milliseconds between pings. |
| `-q num_queries` | Number of queries per hop. Higher = more reliable loss statistics. |
| `-w timeout` | Wait `timeout` milliseconds for each reply. |
| `-4` | Force IPv4. |
| `-6` | Force IPv6. |

---

## What I'd take away from this incident

- **Layer 1 wins more often than people expect.** A copper cable degraded enough to drop 35% of packets, but not enough to fail a simple continuity test, is a common failure mode in newly deployed environments. Reach for the cable before reaching for the firewall.
- **Sampling beats single-shot.** For intermittent issues, a tool that aggregates over time (`pathping`, continuous packet capture) will out-diagnose a tool that takes one snapshot (`ping`, `tracert`).
- **Document while you investigate.** Timestamped output files turn troubleshooting from a story you tell into evidence anyone can audit.

---

For the broader framework this incident lives inside, see [METHODOLOGY.md](./METHODOLOGY.md).
