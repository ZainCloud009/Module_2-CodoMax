# Linux, Networking & Cloud Infrastructure — Module 2

Hands-on deployment of a secured Linux server on AWS EC2, covering Linux administration, networking fundamentals, and cloud security group configuration.

## 📋 Project Overview

**Goal:** Create VM → Configure Linux → Secure Access → Deploy Service → Test Connectivity

**Stack:** AWS EC2 (Amazon Linux 2023, t3.micro) · SSH · UFW · Nginx

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
          │   EC2 Instance (Amazon Linux 2023) │
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
- Launched an EC2 instance: **Amazon Linux 2023**, `t3.micro` (free-tier eligible)
- Generated a new SSH key pair during launch (`.pem` file — **not committed to this repo**, see `.gitignore`)

### 2. Configure the Security Group
See [`configs/security-group-rules.md`](configs/security-group-rules.md) for the full inbound/outbound rule set.

### 3. Secure Access (SSH)
```bash
chmod 400 "testingserver.pem"
ssh -i "testingserver.pem" ec2-user@ec2-56-228-35-86.eu-north-1.compute.amazonaws.com
```
Password authentication is disabled — key-based auth only.

### 4. Configure the Linux server
Full command log in [`docs/setup-log.md`](docs/setup-log.md). Summary:
- System updated (`apt update && apt upgrade`)
- Created a non-root sudo user
- Configured UFW firewall (allow OpenSSH, allow 80/tcp)
- Reviewed running services with `systemctl`

