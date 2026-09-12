# Computer Networking: Ports, Protocols & Socket Analysis (Amazon Linux 2023)

A detailed guide to Layer 4 transport protocols (TCP vs. UDP), standard port allocations, Apache (`httpd`) socket inspection using `ss` and `lsof`, and remote port testing on **Amazon Linux 2023 (AL2023)**.

---

## 1. Transport Layer Protocols: TCP vs. UDP

**Layer 4 (Transport Layer)** manages end-to-end host-to-host delivery and socket multiplexing:

```
               APPLICATION LAYER (HTTP, SSH, DNS)
                               │
              ┌────────────────┴────────────────┐
              ▼                                 ▼
        TCP Protocol                      UDP Protocol
     (Connection-Oriented)               (Connectionless)
     • 3-Way Handshake                   • No Handshake
     • Reliable (Retransmission)         • Fast, Stateless
     • Ordered Sequence                  • Used for DNS & Media
     • Flow Control                      • Low Overhead
```

### The TCP Three-Way Handshake:
1. **`SYN`**: Client initiates synchronization.
2. **`SYN-ACK`**: Server acknowledges and returns its own synchronization sequence.
3. **`ACK`**: Client confirms synchronization. Connection becomes **`ESTABLISHED`**.

---

## 2. Port Ranges & Privileges

A port is a 16-bit integer ranging from **`0` to `65535`**:
- **`0 – 1023` (Well-Known / Privileged):** Requires `root` privilege to bind. (e.g., Apache binding to port 80).
- **`1024 – 49151` (Registered Ports):** Application services (e.g., MySQL 3306, Redis 6379).
- **`49152 – 65535` (Ephemeral Ports):** Randomly assigned outbound client ports.

---

## 3. Essential Ports Reference Catalogue

| Port | Protocol | Daemon / Service | Description |
|:---:|:---:|---|---|
| **`22`** | TCP | **SSH (`sshd`)** | Secure remote terminal access (Restricted to My IP) |
| **`80`** | TCP | **HTTP (`httpd`)** | Unencrypted web traffic (Publicly open to 0.0.0.0/0) |
| **`443`**| TCP | **HTTPS** | Encrypted TLS/SSL web traffic |
| **`53`** | UDP/TCP | **DNS** | Domain name resolution |
| **`123`**| UDP | **NTP (`chronyd`)** | Clock synchronization on Amazon Linux 2023 |
| **`3306`**| TCP | **MySQL / MariaDB**| Database listener |
| **`5432`**| TCP | **PostgreSQL** | Database listener |
| **`8080`**| TCP | **HTTP Alternate** | Alternate development web port |

---

## 4. Socket & Port Inspection on Amazon Linux 2023

### `ss` — Modern Socket Statistics
Inspect all listening ports on your Amazon Linux 2023 EC2 instance:
```bash
sudo ss -tulpn
```

### Breakdown of Flags:
- `-t`: TCP sockets
- `-u`: UDP sockets
- `-l`: Listening sockets only
- `-p`: Show process name and PID
- `-n`: Numeric port numbers (e.g., `80` instead of `http`)

### Sample Output on Configured AL2023 Apache Server:
```text
Netid  State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process
tcp    LISTEN  0       128            0.0.0.0:22          0.0.0.0:*      users:(("sshd",pid=650,fd=3))
tcp    LISTEN  0       511            0.0.0.0:80          0.0.0.0:*      users:(("httpd",pid=1420,fd=4),("httpd",pid=1421,fd=4))
tcp    LISTEN  0       128               [::]:22             [::]:*      users:(("sshd",pid=650,fd=4))
tcp    LISTEN  0       511               [::]:80             [::]:*      users:(("httpd",pid=1420,fd=5),("httpd",pid=1421,fd=5))
```
- **`0.0.0.0:22`**: `sshd` is listening for administrative connections.
- **`0.0.0.0:80`**: `httpd` (Apache) is actively listening for incoming HTTP web requests.

---

### `lsof` — List Open Sockets by Port
```bash
# Install lsof on AL2023 if required
sudo dnf install lsof -y

# Check what process is listening on port 80
sudo lsof -i :80
```
**Sample Output:**
```text
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
httpd    1420   root    4u  IPv4  24150      0t0  TCP *:http (LISTEN)
httpd    1421 apache    4u  IPv4  24150      0t0  TCP *:http (LISTEN)
```

---

## 5. Remote Port Connectivity Testing

```
 Client (Your PC) ───> [AWS Security Group: Port 80 & 22] ───> [Apache httpd]
```

### 1. `curl` — HTTP Verification
```bash
# From client machine:
curl -I http://<YOUR_EC2_PUBLIC_IP>
```
*Expected Result:* Returns `HTTP/1.1 200 OK` with `Server: Apache/...`.

---

### 2. `nc` (Netcat) — TCP Port Check
```bash
# Verify port 80 is open
nc -zv -w 3 <YOUR_EC2_PUBLIC_IP> 80
# Connection to <EC2_PUBLIC_IP> 80 port [tcp/http] succeeded!

# Verify unauthorized port 8080 is blocked by AWS Security Group
nc -zv -w 3 <YOUR_EC2_PUBLIC_IP> 8080
# nc: connect to <EC2_PUBLIC_IP> port 8080 timed out
```
