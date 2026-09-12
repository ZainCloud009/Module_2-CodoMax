# Linux, Networking & Cloud Infrastructure — Module 2

Hands-on deployment of a secured Linux server on AWS EC2, covering Linux administration, networking fundamentals, and cloud security group configuration.

## 📋 Project Overview

**Goal:** Create VM → Configure Linux → Secure Access → Deploy Service → Test Connectivity

**Stack:** AWS EC2 (Ubuntu Server 22.04 LTS, t2.micro) · SSH · UFW · Nginx

---

## 🏗️ Architecture

```
                    Internet
                       │
                       ▼
          ┌────────────────────────┐
          │   AWS Security Group    │
          │  Inbound: 22 (my IP)    │
          │  Inbound: 80 (0.0.0.0/0)│
          └────────────┬─────────────┘
                       │
                       ▼
          ┌────────────────────────┐
          │   EC2 Instance (Ubuntu) │
          │  ┌──────────────────┐   │
          │  │  UFW Firewall     │   │
          │  │  allow: OpenSSH   │   │
          │  │  allow: 80/tcp    │   │
          │  └────────┬──────────┘   │
          │           ▼              │
          │      Nginx service       │
          │      (systemd managed)   │
          └────────────────────────┘
```

## 🚀 Deployment Steps

### 1. Create the VM
- Launched an EC2 instance: **Ubuntu Server 22.04 LTS**, `t2.micro` (free-tier eligible)
- Generated a new SSH key pair during launch (`.pem` file — **not committed to this repo**, see `.gitignore`)

### 2. Configure the Security Group
See [`configs/security-group-rules.md`](configs/security-group-rules.md) for the full inbound/outbound rule set.

### 3. Secure Access (SSH)
```bash
chmod 400 my-key.pem
ssh -i my-key.pem ubuntu@<public-ip>
```
Password authentication is disabled — key-based auth only.

### 4. Configure the Linux server
Full command log in [`docs/setup-log.md`](docs/setup-log.md). Summary:
- System updated (`apt update && apt upgrade`)
- Created a non-root sudo user
- Configured UFW firewall (allow OpenSSH, allow 80/tcp)
- Reviewed running services with `systemctl`

### 5. Deploy a service
Installed and enabled **Nginx** as the test web service:
```bash
sudo apt install nginx -y
sudo systemctl enable nginx --now
```

### 6. Test connectivity
- ✅ `curl localhost` → returned Nginx welcome page
- ✅ `curl <public-ip>` from local machine → success
- ✅ Browser test at `http://<public-ip>` → Nginx welcome page loaded
- ✅ `sudo ss -tulpn` → confirmed only ports 22 and 80 listening

See [`docs/connectivity-test-results.md`](docs/connectivity-test-results.md) for full output and screenshots.

---

## 📁 Repo Structure

```
linux-cloud-deployment/
├── README.md
├── scripts/
│   └── server-setup.sh       # Automated hardening + nginx install script
├── configs/
│   └── security-group-rules.md
└── docs/
    ├── setup-log.md           # Full command-by-command log
    ├── connectivity-test-results.md
    └── screenshots/            # (add your screenshots here)
```

## 🔑 Key Concepts Demonstrated
- Linux CLI: file permissions (`chmod`/`chown`), user & group management, process management (`ps`, `systemctl`)
- SSH key-based authentication (no password auth)
- Networking: IP addressing, ports, DNS basics
- Defense in depth: AWS Security Group (network layer) + UFW (host layer)
- Service deployment & verification via `systemd`

## ⚠️ Security Note
No private keys, `.pem` files, or credentials are included in this repository (see `.gitignore`).
