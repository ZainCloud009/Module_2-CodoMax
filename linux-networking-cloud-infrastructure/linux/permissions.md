# Linux File Permissions & Access Control (Amazon Linux 2023)

A comprehensive guide to Linux discretionary access control (DAC), octal and symbolic modes, Apache web directory ownership (`apache:apache`), special attributes (SUID/SGID/Sticky Bit), and Access Control Lists (ACLs) on **Amazon Linux 2023 (AL2023)**.

---

## 1. The Linux Permission Model

Every file and directory in Linux has an owner (User), an assigned Group, and permission bits defining access for **User (u)**, **Group (g)**, and **Others (o)**.

Inspecting the Apache web directory with `ls -l`:

```
 - r w - r - - r - -   1   apache   apache   1420   Sep 12 18:00   index.html
 │ └───┬───┘ └───┬───┘ └───┬───┘
 │     │         │         │
 │     │         │         └─ Others (World): r-- (Read-only, allows web visitors)
 │     │         └─────────── Group: r-- (Read-only for apache group)
 │     └───────────────────── Owner: rw- (Read and Write for apache user)
 └─────────────────────────── File Type (- = Regular file, d = Directory, l = Symlink)
```

---

## 2. Octal (Numeric) vs. Symbolic Notation

### The Octal Mathematical System

| Symbol | Binary | Octal Value | Description |
|:---:|:---:|:---:|---|
| `---` | `000` | **0** | No permissions |
| `--x` | `001` | **1** | Execute only |
| `-w-` | `010` | **2** | Write only |
| `-wx` | `011` | **3** | Write and Execute (2 + 1) |
| `r--` | `100` | **4** | Read only |
| `r-x` | `101` | **5** | Read and Execute (4 + 1) |
| `rw-` | `110` | **6** | Read and Write (4 + 2) |
| `rwx` | `111` | **7** | Full permissions (4 + 2 + 1) |

$$\text{Octal Mode} = (\text{User Mode}) \times 100 + (\text{Group Mode}) \times 10 + (\text{Others Mode})$$

### Standard Modes in Amazon Linux 2023:
- **`755` (`rwxr-xr-x`):** Standard for directories (`/var/www/html`) and scripts.
- **`644` (`rw-r--r--`):** Standard for web documents (`index.html`) and configuration files.
- **`600` (`rw-------`):** Standard for sensitive files (`~/.ssh/authorized_keys`).
- **`400` (`r--------`):** Strictly enforced for SSH private keys (`my-key.pem`).

---

## 3. Modifying Permissions: `chmod`

```bash
# Set Apache web root directory executable/traversable by web server
sudo chmod 755 /var/www/html

# Set HTML file readable by public web visitors
sudo chmod 644 /var/www/html/index.html

# Secure private key on local client
chmod 400 ~/.ssh/my-key.pem

# Recursive permission assignment
sudo chmod -R 755 /var/www/html/
```

### Symbolic Mode:
```bash
# Add execute permission to deploy script
chmod u+x deploy.sh

# Revoke write permissions from group and others
chmod go-w /etc/httpd/conf/httpd.conf
```

---

## 4. Ownership Management: `chown` & `chgrp`

On Amazon Linux 2023, the Apache HTTP daemon runs under the user and group **`apache:apache`**.

```bash
# Grant Apache ownership of web content so it can serve files
sudo chown -R apache:apache /var/www/html

# Grant ec2-user ownership of personal project files
sudo chown -R ec2-user:ec2-user /home/ec2-user/project/

# Change group only
sudo chgrp wheel /opt/scripts/
```

---

## 5. File Creation Mask: `umask`

The `umask` determines default permissions for newly created files and directories.
- Default directory base: `777`
- Default regular file base: `666`

$$\text{Final Mode} = \text{Base Mode} - \text{umask}$$

On Amazon Linux 2023, default umask is `0022`:
- New directories get: $777 - 022 = \mathbf{755}$
- New files get: $666 - 022 = \mathbf{644}$

---

## 6. Special Permissions (SUID, SGID, Sticky Bit)

### 1. SUID (`4000`):
Executes binary with owner permissions (`rwsr-xr-x`).
```bash
# Example: /usr/bin/passwd has SUID to modify /etc/shadow as root
ls -l /usr/bin/passwd
```

### 2. SGID (`2000`):
When applied to a directory, new files inherit group ownership of the directory rather than the creator's group (`drwxrwsr-x`).
```bash
# Enable group collaboration for Apache web developers
sudo chmod 2775 /var/www/html
```

### 3. Sticky Bit (`1000`):
Only file owner or root can delete files inside the directory (`drwxrwxrwt`).
```bash
# Protect shared temporary directory
sudo chmod +t /tmp
```

---

## 7. Granular Access: POSIX ACLs (`setfacl` / `getfacl`)

To allow `ec2-user` to write directly to `/var/www/html` without changing Apache ownership:

```bash
# Install ACL utilities if needed
sudo dnf install acl -y

# Grant ec2-user read/write/execute permissions on /var/www/html
sudo setfacl -R -m u:ec2-user:rwx /var/www/html

# Set default ACLs for all newly created files in web root
sudo setfacl -R -d -m u:ec2-user:rwx /var/www/html

# View effective ACL permissions
getfacl /var/www/html
```
