# Computer Networking: IP Addressing & Subnetting (Amazon Linux 2023)

A thorough guide to IPv4 and IPv6 architecture, RFC 1918 private networking, CIDR notation, AWS VPC subnets, and IP inspection on **Amazon Linux 2023 (AL2023)**.

---

## 1. Foundations of IP Addressing

An **Internet Protocol (IP) address** is a unique numerical identifier assigned to every network interface participating in TCP/IP communication.

### IPv4 vs. IPv6

| Characteristic | IPv4 | IPv6 |
|---|---|---|
| **Length** | 32 bits (4 decimal octets) | 128 bits (8 hexadecimal quartets) |
| **Address Total** | $\approx 4.3 \times 10^9$ addresses | $\approx 3.4 \times 10^{38}$ addresses |
| **Example** | `198.51.100.14` | `2001:0db8:85a3::8a2e:0370:7334` |
| **Localhost** | `127.0.0.1` | `::1` |
| **Default Route** | `0.0.0.0/0` | `::/0` |

---

## 2. Public vs. Private IP Addresses

### Private Address Ranges (RFC 1918)
Private IP addresses are reserved for internal, non-routable communication within your AWS VPC or local network:

| Class | CIDR Prefix | Address Range | Common Cloud Usage |
|:---:|:---:|:---:|---|
| **Class A** | `10.0.0.0/8` | `10.0.0.0` – `10.255.255.255` | Enterprise multi-region VPC topologies |
| **Class B** | `172.16.0.0/12` | `172.16.0.0` – `172.31.255.255` | **AWS Default VPC** (e.g., `172.31.0.0/16`) |
| **Class C** | `192.168.0.0/16` | `192.168.0.0` – `192.255.255.255` | Local networks, development environments |

### Special Addresses:
- **`127.0.0.1` (Localhost):** Loopback adapter.
- **`0.0.0.0/0`:** Represents all IPv4 addresses on the Internet in firewall rules and routing tables.
- **`169.254.169.254` (AWS IMDS Endpoint):** The link-local IP used by Amazon Linux 2023 instances to query instance metadata, public IP, and IAM role credentials.

---

## 3. CIDR & AWS Subnet Calculations

$$\text{Total IPs} = 2^{(32 - n)}$$

### Subnet Reference Matrix

| Prefix | Subnet Mask | Total IPs | Standard Usable Hosts | AWS VPC Usable Hosts |
|:---:|---|:---:|:---:|:---:|
| `/32` | `255.255.255.255` | 1 | 1 (Single Host) | 0 (Host only) |
| `/24` | `255.255.255.0` | 256 | 254 | 251 |
| `/20` | `255.255.240.0` | 4,096 | 4,094 | 4,091 |
| `/16` | `255.255.0.0` | 65,536 | 65,534 | 65,531 |

> [!IMPORTANT]
> **The 5 AWS Reserved IPs:** In every AWS subnet, Amazon reserves 5 IP addresses:
> 1. `*.0`: Network address
> 2. `*.1`: VPC internal router gateway
> 3. `*.2`: AmazonProvidedDNS resolver
> 4. `*.3`: Reserved for future AWS use
> 5. `*.255`: Subnet broadcast address

---

## 4. Network Inspection on Amazon Linux 2023

Amazon Linux 2023 uses modern Linux networking managed by `systemd-networkd`.

### `ip addr` (`ip a`) — Inspecting Interfaces
```bash
ip a
```
**Sample Output on AL2023 EC2:**
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc fq_codel state UP group default qlen 1000
    link/ether 06:2e:88:65:42:19 brd ff:ff:ff:ff:ff:ff
    inet 172.31.42.84/20 metric 1024 brd 172.31.47.255 scope global dynamic ens5
       valid_lft 2845sec preferred_lft 2845sec
```
- `ens5`: The virtual Elastic Network Interface (ENI) assigned by AWS.
- `172.31.42.84/20`: The instance's private IPv4 address.

---

### `ip route` (`ip r`) — Routing Table
```bash
ip r
```
**Sample Output:**
```text
default via 172.31.32.1 dev ens5 proto dhcp src 172.31.42.84 metric 1024 
172.31.32.0/20 dev ens5 proto kernel scope link src 172.31.42.84 metric 1024 
```

---

### Discovering Public IP from the Instance CLI

Because EC2 instances sit behind AWS 1:1 NAT, running `ip a` displays the **private IP**. Retrieve the **public IP** via:

```bash
# Method 1: Using IMDSv2 (Secure AWS standard on AL2023)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4

# Method 2: Public reflection services
curl -s https://checkip.amazonaws.com
curl -s https://ifconfig.me
```

---

### Connectivity Diagnostics
```bash
# Test reachability to Google DNS
ping -c 4 8.8.8.8

# Trace network route
tracepath 8.8.8.8
```
