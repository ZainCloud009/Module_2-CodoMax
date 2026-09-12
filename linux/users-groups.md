# Linux User & Group Management and Sudo Security (Amazon Linux 2023)

A detailed guide to user accounts, groups, system databases (`/etc/passwd`, `/etc/shadow`), user provisioning, and the `wheel` administrative group on **Amazon Linux 2023 (AL2023)**.

---

## 1. User and Group Architecture on AL2023

Amazon Linux 2023 follows the Fedora/RHEL identity conventions:
- **`root` (UID 0):** The superuser.
- **System Service Accounts (UID 1 – 999):** Unprivileged users reserved for system daemons:
  - `apache` (UID 48): Executes Apache HTTP web server child processes.
  - `sshd` (UID 74): Privilege separation user for OpenSSH daemon.
  - `chrony` (UID 998): Network Time Protocol daemon.
- **Standard Users (UID 1000+):**
  - `ec2-user` (UID 1000): The default administrative user created by AWS on Amazon Linux 2023 AMIs.

---

## 2. Core Account Configuration Files

### 1. `/etc/passwd`
Stores user account properties.
```bash
grep ec2-user /etc/passwd
```
**Sample Output:**
```text
ec2-user:x:1000:1000:EC2 Default User:/home/ec2-user:/bin/bash
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
```
- `ec2-user`: User login name.
- `x`: Password stored encrypted in `/etc/shadow`.
- `1000:1000`: UID and Primary GID.
- `/home/ec2-user`: Home directory.
- `/bin/bash`: Default interactive shell. (Notice `apache` has `/sbin/nologin` to prevent interactive shell logins).

---

### 2. `/etc/shadow`
Stores encrypted password hashes with strict `0000` or `0640` permissions readable only by `root`.
```text
ec2-user:!!:19643:0:99999:7:::
```
- `!!`: Account password is locked (passwords are disabled by default; keypair authentication is enforced).

---

### 3. `/etc/group` & The `wheel` Group
On Amazon Linux 2023, the administrative group that grants `sudo` privileges is named **`wheel`** (GID 10):
```text
wheel:x:10:ec2-user
apache:x:48:
```

---

## 3. User Management Commands on AL2023

### `useradd` — Create User Accounts
On RHEL and Amazon Linux 2023, `useradd` is the standard command:
```bash
# Create deployuser with a home directory (-m) and bash shell (-s)
sudo useradd -m -s /bin/bash -c "CI/CD Deployment User" deployuser
```

---

### `usermod` — Modify Users & Grant Sudo via `wheel`
> [!IMPORTANT]
> To grant administrative sudo rights on Amazon Linux 2023, add the user to the **`wheel`** group using `usermod -aG wheel`:

```bash
# Add deployuser to wheel group
sudo usermod -aG wheel deployuser

# Verify group membership
id deployuser
# Output: uid=1001(deployuser) gid=1001(deployuser) groups=1001(deployuser),10(wheel)
```

---

### `userdel` — Delete Users
```bash
# Delete user and wipe their home directory and mail spool
sudo userdel -r deployuser
```

---

### `passwd` — Password Configuration
```bash
# Set a password for user (optional, keys are preferred)
sudo passwd deployuser
```

---

## 4. Sudo Privileges & The `wheel` Group

In Amazon Linux 2023, `/etc/sudoers` contains this built-in rule:
```text
## Allows people in group wheel to run all commands
%wheel        ALL=(ALL)       ALL
```
Therefore, adding any user to the `wheel` group automatically confers full sudo authority.

### Automated Passwordless Sudo via `/etc/sudoers.d/`
For automation and CI/CD pipelines, place drop-in configuration files inside `/etc/sudoers.d/`:

```bash
# Configure passwordless sudo for deployuser
echo "deployuser ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/deployuser

# Apply strict security permissions (must be 0440)
sudo chmod 0440 /etc/sudoers.d/deployuser

# Verify sudoers syntax before saving
sudo visudo -cf /etc/sudoers.d/deployuser
```

---

## 5. Complete Practical Workflow: Provisioning `deployuser` on AL2023

```bash
# 1. Create user account
sudo useradd -m -s /bin/bash deployuser

# 2. Add to wheel group for sudo access
sudo usermod -aG wheel deployuser

# 3. Create SSH directory
sudo mkdir -p /home/deployuser/.ssh

# 4. Copy authorized public keys from ec2-user
sudo cp /home/ec2-user/.ssh/authorized_keys /home/deployuser/.ssh/authorized_keys

# 5. Set correct ownership and strict permissions
sudo chown -R deployuser:deployuser /home/deployuser/.ssh
sudo chmod 700 /home/deployuser/.ssh
sudo chmod 600 /home/deployuser/.ssh/authorized_keys

# 6. Test connection from client machine:
# ssh -i my-key.pem deployuser@<ec2-public-ip>
```
