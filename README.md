# Cybersec-automation-scripts

> A growing collection of automation scripts for reconnaissance, web application testing, network security, OSINT, and defensive monitoring — built on Kali Linux using Bash and Python.

---

## About This Repository

This repository documents my journey of building cybersecurity automation tools from scratch. Every script here is written, tested, and understood by me — not copy pasted. The goal is to automate repetitive security tasks, sharpen scripting skills, and build a practical toolkit for real world use.

Scripts are organized by phase — from beginner foundations to advanced pipelines — so the progression makes sense whether you are learning alongside me or just browsing for tools.

---

## Roadmap

### Phase 1 — Foundations *(Bash Basics)*
> Learn scripting fundamentals through practically useful tools

- [ ] `tool-installer.sh` — Installs a full pentesting toolkit on a fresh Kali machine
- [ ] `wordlist-generator.sh` — Generates custom wordlists based on target information

---

### Phase 2 — Reconnaissance *(Single Tool Wrappers)*
> Automate information gathering one tool at a time

- [ ] `subdomain-enumerator.sh` — Runs subfinder, amass, assetfinder and merges results
- [ ] `passive-recon-aggregator.sh` — Pulls WHOIS, DNS records, and certificate data into one report
- [ ] `port-scanner.sh` — Nmap scan with auto risk categorization of open ports

---

### Phase 3 — Web & Network *(Python + Chaining Tools)*
> Combine tools and introduce Python for web and network tasks

- [ ] `js-secret-scraper.py` — Extracts API keys, tokens, and passwords from JavaScript files
- [ ] `subdomain-takeover-checker.py` — Detects dangling DNS pointing to unclaimed services
- [ ] `rogue-device-detector.py` — Monitors network for unknown MAC addresses and alerts

---

### Phase 4 — Defense & Monitoring *(System Level Scripting)*
> Work with Linux logs and build defensive automation

- [ ] `log-analyzer.sh` — Parses auth.log and flags brute force attempts and sudo abuse
- [ ] `failed-login-alerter.sh` — Monitors login failures and triggers alerts on threshold
- [ ] `file-integrity-monitor.py` — Detects unauthorized changes to critical system files

---

### Phase 5 — Advanced & Reporting *(Full Pipelines)*
> Chain everything together with clean output and reporting

- [ ] `auto-recon-pipeline.py` — Full recon workflow from domain to vulnerability report
- [ ] `pentest-report-generator.py` — Takes scan outputs and produces a clean PDF report
- [ ] `cve-monitor.py` — Checks installed software versions against latest CVEs daily

---

## Tech Stack

- OS — Kali Linux
- Languages — Bash, Python 3
- Tools Used — nmap, subfinder, amass, whois, dig, gobuster, nikto, nuclei, sqlmap, curl

---

## Repository Structure

```
cybersec-automation-scripts/
├── phase1-foundations/
│   ├── tool-installer.sh
│   └── wordlist-generator.sh
├── phase2-recon/
│   ├── subdomain-enumerator.sh
│   ├── passive-recon-aggregator.sh
│   └── port-scanner.sh
├── phase3-web-network/
│   ├── js-secret-scraper.py
│   ├── subdomain-takeover-checker.py
│   └── rogue-device-detector.py
├── phase4-defense/
│   ├── log-analyzer.sh
│   ├── failed-login-alerter.sh
│   └── file-integrity-monitor.py
├── phase5-advanced/
│   ├── auto-recon-pipeline.py
│   ├── pentest-report-generator.py
│   └── cve-monitor.py
└── README.md
```

---

## Progress Tracker

| Phase | Scripts Planned | Scripts Complete | Status |
|---|---|---|---|
| Phase 1 — Foundations | 2 | 0 | 🔲 Not Started |
| Phase 2 — Recon | 3 | 0 | 🔲 Not Started |
| Phase 3 — Web & Network | 3 | 0 | 🔲 Not Started |
| Phase 4 — Defense | 3 | 0 | 🔲 Not Started |
| Phase 5 — Advanced | 3 | 0 | 🔲 Not Started |

---

## Disclaimer

All scripts in this repository are intended for ethical and educational use only. Only run these tools on systems you own or have explicit written permission to test. The author is not responsible for any misuse.

---

## Connect

Built and maintained by [Your Name] — feel free to open issues, suggest improvements, or follow along as this toolkit grows.
