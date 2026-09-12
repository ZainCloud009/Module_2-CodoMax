# Secure Shell (SSH) Administration & Server Hardening (Amazon Linux 2023)

A comprehensive guide to asymmetric key cryptography, connecting as `ec2-user`, client configuration files, permission matrices, and server hardening on **Amazon Linux 2023 (AL2023)**.

---

## 1. Asymmetric Public-Key Authentication

OpenSSH on Amazon Linux 2023 relies on asymmetric key cryptography:
- **Private Key (`my-key.pem`):** Stored strictly on your local computer.
- **Public Key (`~/.ssh/authorized_keys`):** Deployed inside the remote server's home directory (`/home/ec2-user/.ssh/authorized_keys`).

```
      LOCAL CLIENT (Your Machine)                         REMOTE AL2023 SERVER
 ┌───────────────────────────────────┐               ┌───────────────────────────────────┐
 │       Private Key (.pem)          │               │      authorized_keys              │
 │    (Kept private on client)       │               │ (/home/ec2-user/.ssh/auth_keys)   │
 └─────────────────┬─────────────────┘               └─────────────────┬─────────────────┘
                   │                                                   │
                   │ 1. Client connects as ec2-user                    │
                   ├──────────────────────────────────────────────────>│
                   │                                                   │
                   │ 2. Server encrypts random challenge with pubkey   │
                   │<──────────────────────────────────────────────────┤
                   │                                                   │
                   │ 3. Client decrypts with private key & signs       │
                   ├──────────────────────────────────────────────────>│
                   │                                                   │
                   │ 4. Authentication verified. Access Granted!       │
                   │<──────────────────────────────────────────────────┤
```

---

## 2. Connecting to Amazon Linux 2023 via SSH

The default administrative user on Amazon Linux 2023 AMIs is **`ec2-user`**.

### 1. Set Strict Permissions on Private Key
OpenSSH rejects private keys accessible by other users on your operating system:
```bash
# Set owner read-only permission (Linux / macOS / Git Bash)
chmod 400 ~/.ssh/my-key.pem
```

### 2. Execute the SSH Connection
```bash
ssh -i ~/.ssh/my-key.pem ec2-user@<YOUR_EC2_PUBLIC_IP>
```

---

## 3. Strict Permission Requirements Matrix

| Location | Item | Required Mode | Command to Apply |
|---|---|:---:|---|
| **Client Machine** | Private Key (`.pem` / `id_ed25519`) | **`400`** | `chmod 400 my-key.pem` |
| **Client Machine** | Local `.ssh` folder | **`700`** | `chmod 700 ~/.ssh` |
| **AL2023 Server** | Server `.ssh` directory (`/home/ec2-user/.ssh`) | **`700`** | `chmod 700 ~/.ssh` |
| **AL2023 Server** | `authorized_keys` file | **`600`** | `chmod 600 ~/.ssh/authorized_keys` |

---

## 4. Simplifying Connections with `~/.ssh/config`

Configure host aliases on your local machine so you don't have to re-type keys and IP addresses:

Edit `~/.ssh/config`:
```ssh-config
Host al2023
    HostName 54.210.35.120
    User ec2-user
    IdentityFile ~/.ssh/my-key.pem
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Now connect with a single command:
```bash
ssh al2023
```

---

## 5. SSH Server Hardening on AL2023 (`/etc/ssh/sshd_config`)

To safeguard your Amazon Linux 2023 server:

```ini
# /etc/ssh/sshd_config directives:

# 1. Disable root login
PermitRootLogin no

# 2. Disable password authentication (force keypairs only)
PasswordAuthentication no
PermitEmptyPasswords no

# 3. Enforce public key authentication
PubkeyAuthentication yes

# 4. Limit login attempts
MaxAuthTries 3

# 5. Restrict allowed SSH users
AllowUsers ec2-user deployuser
```

### Testing and Applying Changes:
> [!IMPORTANT]
> On Amazon Linux 2023 (as with RHEL/CentOS), the OpenSSH systemd service is named **`sshd.service`** (not `ssh`):

```bash
# 1. Test configuration syntax before reloading
sudo sshd -t

# 2. Restart sshd service
sudo systemctl restart sshd
```

---

## 6. Secure File Transfer with `scp`

```bash
# Upload a file to ec2-user home directory
scp -i my-key.pem index.html ec2-user@<YOUR_EC2_PUBLIC_IP>:/home/ec2-user/

# Upload website files directly to Apache document root (using sudo afterwards)
scp -i my-key.pem -r ./site/* ec2-user@<YOUR_EC2_PUBLIC_IP>:/tmp/
# On the server: sudo cp -r /tmp/site/* /var/www/html/
```
