# Computer Networking: Domain Name System (DNS) Architecture (Amazon Linux 2023)

A comprehensive guide to DNS hierarchical resolution, record types, the Linux OS resolver stack, `AmazonProvidedDNS`, and diagnostic tooling using `dig` and `nslookup` on **Amazon Linux 2023 (AL2023)**.

---

## 1. How DNS Operates: The Hierarchical Resolution Flow

The **Domain Name System (DNS)** translates human-readable domain names into machine-routable IP addresses.

```
                              CLIENT / APPLICATION
                                       │
                              (1) Query: api.example.com
                                       │
                                       ▼
                       AWS VPC RESOLVER (AmazonProvidedDNS)
                                 (172.31.0.2)
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         │ (2) Query Root              │ (4) Query TLD               │ (6) Query Auth
         ▼                             ▼                             ▼
   ROOT NAMESERVERS             TLD NAMESERVERS            AUTHORITATIVE DNS
        (`.`)                       (`.com`)                (AWS Route 53)
         │                             │                             │
         ▼                             ▼                             ▼
 (3) Refer to .com             (5) Refer to Auth             (7) Answer: 198.51.100.25
                                                                     │
                                       ┌─────────────────────────────┘
                                       ▼
                       AWS VPC RESOLVER (AmazonProvidedDNS)
                                       │
                         (8) Returns IP & Caches TTL
                                       │
                                       ▼
                                 CLIENT EC2
```

---

## 2. Core DNS Record Types

| Record | Full Name | Purpose | Example Value |
|:---:|---|---|---|
| **`A`** | **IPv4 Address** | Maps a domain directly to an IPv4 address | `example.com. IN A 54.210.35.120` |
| **`AAAA`** | **IPv6 Address** | Maps a domain to a 128-bit IPv6 address | `example.com. IN AAAA 2001:db8::1` |
| **`CNAME`** | **Canonical Name** | Maps an alias hostname to another hostname | `www.example.com. IN CNAME example.com.` |
| **`MX`** | **Mail Exchanger** | Identifies incoming mail servers with priority | `example.com. IN MX 10 mail.example.com.` |
| **`TXT`** | **Text Record** | Arbitrary text; used for SPF, DKIM, verification | `example.com. IN TXT "v=spf1 ..."` |
| **`NS`** | **Name Server** | Identifies authoritative nameservers for a zone | `example.com. IN NS ns-1.awsdns.com.` |
| **`PTR`** | **Pointer Record** | Reverse DNS (maps an IP address back to domain) | `120.35.210.54.in-addr.arpa. IN PTR ...` |

---

## 3. The Linux DNS Resolver Stack on AL2023

In Amazon Linux 2023:
1. **`/etc/hosts`**: Static local IP-to-hostname mappings. Checked first according to `/etc/nsswitch.conf`.
2. **`/etc/resolv.conf`**: Configured automatically by DHCP from the AWS VPC router to point to `AmazonProvidedDNS`:
   ```text
   nameserver 172.31.0.2
   search us-east-1.compute.internal
   ```
   - In AWS VPCs, `AmazonProvidedDNS` is always located at the VPC base network address plus 2 (`172.31.0.2` in a default `172.31.0.0/16` VPC).

---

## 4. DNS Diagnostics Tools on AL2023: `bind-utils`

On Amazon Linux 2023, the `dig`, `nslookup`, and `host` utilities are installed via the **`bind-utils`** package:

```bash
# Install DNS diagnostic tools via dnf
sudo dnf install bind-utils -y
```

---

### `dig` — Domain Information Groper

```bash
# Basic domain lookup
dig example.com

# Short output (clean IP address for scripts)
dig +short example.com

# Query specific record type (MX or TXT)
dig example.com MX
dig example.com TXT

# Query external resolver directly (bypassing local VPC resolver)
dig @8.8.8.8 example.com

# Reverse lookup (rDNS)
dig -x 54.210.35.120

# Trace full hierarchical resolution path from root servers
dig +trace example.com
```

---

### `nslookup` & `host`
```bash
# Query domain with nslookup
nslookup example.com

# Simple host resolution
host example.com
```

---

## 5. Cloud DNS: AWS Route 53

When mapping a custom domain to your Amazon Linux 2023 EC2 instance:
- **Public Hosted Zone:** Create an **`A` record** in Route 53 pointing `example.com` to your EC2 instance's **Public Elastic IP**.
- **TTL (Time to Live):** Typically set to 300 seconds (5 minutes) during deployment testing so IP changes propagate quickly.
