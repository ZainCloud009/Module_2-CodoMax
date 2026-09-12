# Network Firewalls: Security Groups & Host Defense (Amazon Linux 2023)

A comprehensive guide to multi-layered cloud security, stateful AWS Security Groups (Ports 22 & 80), `firewalld` host-level configuration, and verification testing on **Amazon Linux 2023 (AL2023)**.

---

## 1. Defense-in-Depth: The Layered Security Model

A secure cloud architecture enforces security across multiple independent boundaries:

```
                          UNTRUSTED INTERNET TRAFFIC
                                      │
                                      ▼
             ┌─────────────────────────────────────────────────┐
             │       LAYER 1: AWS Security Groups (SG)         │
             │          (Virtual Instance Perimeter)           │
             │                                                 │
             │   • Inbound Port 22 (SSH)  ──> My IP only       │
             │   • Inbound Port 80 (HTTP) ──> 0.0.0.0/0        │
             └────────────────────────┬────────────────────────┘
                                      │
                                      ▼
             ┌─────────────────────────────────────────────────┐
             │      LAYER 2: Host Firewall (firewalld)         │
             │           (Linux Kernel Netfilter Layer)        │
             │                                                 │
             │   • Service: ssh (Port 22) ──> ALLOW            │
             │   • Service: http (Port 80)──> ALLOW            │
             │   • Default Policy         ──> DROP / REJECT    │
             └────────────────────────┬────────────────────────┘
                                      │
                                      ▼
                     APACHE WEB SERVER SERVICE (httpd)
```

---

## 2. AWS Security Groups (Perimeter Firewall)

AWS Security Groups operate at the hypervisor Elastic Network Interface (ENI) level. They are **stateful**: return traffic is automatically permitted regardless of outbound rules.

### Applied Inbound Rules Configuration

| Type | Protocol | Port Range | Source | Rationale |
|:---:|:---:|:---:|---|---|
| **SSH** | TCP | `22` | `My IP` (`x.x.x.x/32`) | Restricts administrative terminal access strictly to your current public IP address. |
| **HTTP** | TCP | `80` | `0.0.0.0/0` | Opens web traffic to the world so visitors can reach the Apache server. |
| **HTTPS** | TCP | `443` | `0.0.0.0/0` | Reserved for future TLS/SSL encryption. |

### Applied Outbound Rules Configuration

| Type | Protocol | Port Range | Destination | Rationale |
|:---:|:---:|:---:|---|---|
| **All traffic** | All | All | `0.0.0.0/0` | Enables `dnf` repository updates, DNS lookups, and external NTP syncing. |

---

## 3. Host-Level Defense on AL2023: `firewalld`

On Amazon Linux 2023, host firewall rules are managed using **`firewalld`** (the standard firewall daemon on Fedora/RHEL derivatives, replacing Ubuntu's `ufw`):

### Step 1: Install and Enable `firewalld`
```bash
sudo dnf install firewalld -y
sudo systemctl enable firewalld --now
```

---

### Step 2: Open Allowed Services
> [!WARNING]
> Ensure the `ssh` service is added before enabling `firewalld` so your current connection is not terminated.

```bash
# Allow SSH (Port 22) and HTTP (Port 80) permanently
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http

# Alternatively, add by explicit port:
# sudo firewall-cmd --permanent --add-port=80/tcp

# Reload firewall to activate permanent changes
sudo firewall-cmd --reload
```

---

### Step 3: Inspect Active Firewall Rules
```bash
sudo firewall-cmd --list-all
```

**Sample Output (`firewall-cmd --list-all`):**
```text
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens5
  sources: 
  services: http ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```
- Only `http` (80) and `ssh` (22) services are permitted; all other inbound ports are blocked by default.

---

### Removing Rules
```bash
# Remove HTTP service if taking server offline for maintenance
sudo firewall-cmd --permanent --remove-service=http
sudo firewall-cmd --reload
```

---

## 4. Verification & Testing

### 1. Positive Connectivity Test (Allowed Port 80)
From your local client machine:
```bash
curl -I http://<YOUR_EC2_PUBLIC_IP>
```
*Expected Result:*
```text
HTTP/1.1 200 OK
Date: ...
Server: Apache/2.4.58 (Amazon Linux)
```

---

### 2. Negative Connectivity Test (Blocked Port 8080)
Test an unauthorized port:
```bash
nc -zv -w 3 <YOUR_EC2_PUBLIC_IP> 8080
```
*Expected Result:* The connection times out, confirming that traffic to unapproved ports is dropped at the AWS Security Group perimeter.
