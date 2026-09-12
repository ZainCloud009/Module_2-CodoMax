# Linux, Networking & Cloud Infrastructure

A comprehensive, production-grade guide and hands-on laboratory documentation covering Linux system administration, core computer networking principles, SSH cryptographic access, and cloud infrastructure deployment on **Amazon Linux 2023 (AL2023)** using **Apache (`httpd`)**.

---

## 📌 Repository Architecture & Overview

This repository is structured into modular domains representing foundational competencies for Cloud, DevOps, and Systems Engineers:

```
linux-networking-cloud-infrastructure/
│
├── README.md                              # Project overview, AL2023 architecture, and navigation
│
├── linux/                                 # Linux System Administration (Amazon Linux 2023)
│   ├── basic-commands.md                  # Essential CLI commands, dnf package manager & I/O
│   ├── filesystem.md                      # Linux FHS, NVMe/EBS disk management & mount persistence
│   ├── permissions.md                     # File security, octal/symbolic modes, wheel group & SUID
│   ├── users-groups.md                    # ec2-user, wheel administrative group & sudoers rules
│   ├── processes.md                       # Process lifecycle, signals, monitoring & httpd workers
│   └── services.md                        # systemd architecture, httpd lifecycle & journalctl
│
├── networking/                            # Computer Networking Fundamentals
│   ├── ip-addressing.md                   # IPv4/IPv6, CIDR notation, subnets & AWS VPC ranges
│   ├── ports.md                           # Layer 4 TCP/UDP protocols, well-known ports & socket inspection
│   ├── dns.md                             # Domain resolution flow, AmazonProvidedDNS & bind-utils
│   └── firewall.md                        # Layered defense, AWS Security Groups & firewalld
│
├── ssh/                                   # Secure Shell Administration
│   └── ssh-notes.md                       # Key generation, ec2-user config, agent forwarding & hardening
│
├── deployment/                            # Cloud Deployment Walkthrough
│   └── linux-server-deployment.md         # End-to-end AL2023 EC2 provisioning & Apache httpd deployment
│
└── screenshots/                           # Evidence & Visual Verification
    ├── ec2.png                            # AWS EC2 Management Console instance state (AL2023)
    ├── ssh.png                            # Remote terminal SSH authentication session (ec2-user)
    ├── linux-server.png                   # System configuration, wheel user & firewalld status
    ├── security-group.png                 # Inbound (22 to My IP, 80 to 0.0.0.0/0) & outbound rules
    └── nginx.png                          # Live HTTP response & Apache web page test in browser
```

---

## 🏗️ Cloud Infrastructure Architecture

The deployment implements a **defense-in-depth** model where traffic must pass through both network perimeter controls and host-level protections before reaching application services:

```
                                  INTERNET
                                     │
                                     ▼
        ┌────────────────────────────────────────────────────────┐
        │                 AWS Security Group                     │
        │              (Edge Perimeter Firewall)                 │
        │                                                        │
        │   • Inbound Port 22 (SSH)  ──> Restricted to My IP     │
        │   • Inbound Port 80 (HTTP) ──> Open to 0.0.0.0/0       │
        │   • Outbound Traffic       ──> Allowed (All Protocols) │
        └────────────────────────────┬───────────────────────────┘
                                     │
                                     ▼
        ┌────────────────────────────────────────────────────────┐
        │            AWS EC2 Virtual Machine (t2.micro)          │
        │                 Amazon Linux 2023 (AL2023)             │
        │                                                        │
        │  ┌──────────────────────────────────────────────────┐  │
        │  │         Host Firewall (firewalld / iptables)     │  │
        │  │                                                  │  │
        │  │   • Port 22/tcp (SSH)     ──> ALLOW              │  │
        │  │   • Port 80/tcp (HTTP)    ──> ALLOW              │  │
        │  │   • Default Inbound       ──> DROP / REJECT      │  │
        │  │   • Default Outbound      ──> ALLOW              │  │
        │  └──────────────────────────┬───────────────────────┘  │
        │                             │                          │
        │                             ▼                          │
        │  ┌──────────────────────────────────────────────────┐  │
        │  │          Apache HTTP Web Server (httpd)          │  │
        │  │             (systemd managed unit)               │  │
        │  │                                                  │  │
        │  │   • Process: httpd (root master + apache workers)│  │
        │  │   • Socket:  0.0.0.0:80 (LISTENING)              │  │
        │  │   • Content: /var/www/html/index.html            │  │
        │  └──────────────────────────────────────────────────┘  │
        └────────────────────────────────────────────────────────┘
```

---

## 🚀 Key Modules Summary (Amazon Linux 2023)

| Module | Core Topics Covered | Primary Commands & Tools |
|---|---|---|
| [**Linux Basics**](linux/basic-commands.md) | Navigation, file manipulation, text processing, `dnf` packages | `dnf`, `ls`, `grep`, `find`, `cat`, `tar`, `free`, `df` |
| [**Filesystem**](linux/filesystem.md) | FHS standards, NVMe/EBS disks, partition tables, mount persistence | `df -hT`, `du -sh`, `lsblk -f`, `mount`, `/etc/fstab` |
| [**Permissions**](linux/permissions.md) | Read/Write/Execute bits, octal calculation, `apache` ownership | `chmod`, `chown`, `chgrp`, `umask`, `setfacl` |
| [**Users & Groups**](linux/users-groups.md) | `ec2-user`, `wheel` administrative group, shadow security, sudo rules | `useradd`, `usermod -aG wheel`, `visudo`, `id` |
| [**Processes**](linux/processes.md) | Signals, background jobs, monitoring `httpd` worker processes | `ps aux`, `top`, `htop`, `kill -9`, `pkill httpd` |
| [**Services**](linux/services.md) | systemd units, startup targets, `httpd.service` control & journal | `systemctl`, `journalctl -u httpd -f` |
| [**IP Addressing**](networking/ip-addressing.md) | CIDR math, RFC 1918 private vs public IPs, AWS VPC & IMDSv2 | `ip addr`, `ip route`, `ping`, `traceroute`, `curl` |
| [**Ports & Sockets**](networking/ports.md) | TCP vs UDP, port catalogue, `httpd` socket inspection | `ss -tulpn`, `lsof -i :80`, `nc -zv` |
| [**DNS**](networking/dns.md) | Hierarchical resolution, AmazonProvidedDNS (`172.31.0.2`), dig | `dig`, `nslookup`, `host`, `/etc/resolv.conf` |
| [**Firewalls**](networking/firewall.md) | Stateful Security Groups (22 My IP, 80 Any) + `firewalld` rules | `firewall-cmd`, AWS EC2 Security Group rules |
| [**SSH Security**](ssh/ssh-notes.md) | Keypairs, `ec2-user` authentication, client configs, hardening | `ssh -i`, `ec2-user@<ip>`, `sshd_config`, `scp` |
| [**Cloud Deployment**](deployment/linux-server-deployment.md) | Full AL2023 rollout: EC2 launch, Apache httpd, automated script | `dnf install httpd`, systemd, browser curl verification |

---

## 🛠️ Verification & Connectivity Testing

To confirm that the deployed server and networking configuration operate correctly:

1. **Local Socket Check (on the server):**
   ```bash
   sudo ss -tulpn
   ```
   *Expected:* Confirms `sshd` is listening on port `22` and `httpd` is listening on port `80`.

2. **Local HTTP Verification:**
   ```bash
   curl -I http://localhost
   ```
   *Expected:* `HTTP/1.1 200 OK` from Apache (`Server: Apache/...`).

3. **Remote Browser Verification:**
   Navigate to `http://<YOUR_EC2_PUBLIC_IP>` in your web browser.
   *Expected:* The Apache web page renders successfully.

4. **Firewall Negative Test:**
   ```bash
   nc -zv -w 3 <YOUR_EC2_PUBLIC_IP> 8080
   ```
   *Expected:* The connection times out or is refused, confirming that unauthorized ports are blocked by the firewall.

---

## 🔒 Security Best Practices Implemented

- **Private Key Safeguards:** SSH private keys use strict permissions (`chmod 400`) and are excluded from version control via `.gitignore`.
- **Administrative Privileges:** Administrative delegation managed through the Linux `wheel` group with verified `sudoers` policies.
- **Restricted Administrative Access:** SSH port 22 is restricted to the administrator's public IP address in the AWS Security Group.
- **Two-Tiered Firewall:** AWS Security Group operates at the virtual network layer while host protections operate inside the Amazon Linux 2023 kernel.
