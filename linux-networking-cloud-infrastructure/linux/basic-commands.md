# Essential Linux Commands Reference Guide (Amazon Linux 2023)

A comprehensive, practical guide to foundational command-line operations, the `dnf` package manager, system inspection, text processing, and administrative workflows on **Amazon Linux 2023 (AL2023)**.

---

## 1. System Information & Environment

### `uname` — Kernel and Architecture Details
Prints core system and kernel information.
- **Syntax:** `uname [OPTIONS]`
- **Common Options:**
  - `-a`, `--all`: Print all system information.
  - `-r`, `--kernel-release`: Print kernel release version.
  - `-m`, `--machine`: Print machine hardware architecture (`x86_64` or `aarch64`).
- **Example:**
  ```bash
  uname -a
  ```
- **Sample Output on Amazon Linux 2023:**
  ```text
  Linux ip-172-31-42-84.ec2.internal 6.1.61-85.141.amzn2023.x86_64 #1 SMP PREEMPT_DYNAMIC Wed Nov 8 00:37:37 UTC 2023 x86_64 GNU/Linux
  ```

---

### `hostnamectl` — System & Host Identification
Queries and configures the system hostname and OS identity via `systemd`.
- **Syntax:** `hostnamectl [OPTIONS] [COMMAND]`
- **Example:**
  ```bash
  # View system status
  hostnamectl status

  # Set a custom persistent hostname
  sudo hostnamectl set-hostname al2023-web-server
  ```
- **Sample Output on AL2023:**
  ```text
   Static hostname: al2023-web-server
         Icon name: computer-vm
           Chassis: vm 🖴
        Machine ID: e56c7106cf3e4fcf859b139196b02a28
           Boot ID: 8bb1296c096443c5b88237d6a546059d
    Virtualization: amazon
  Operating System: Amazon Linux 2023.3.20240122
       CPE OS Name: cpe:2.3:o:amazon:amazon_linux:2023
            Kernel: Linux 6.1.61-85.141.amzn2023.x86_64
      Architecture: x86-64
  ```

---

### `cat /etc/os-release` — Distribution Identification
```bash
cat /etc/os-release
```
**Sample Output:**
```text
NAME="Amazon Linux"
VERSION="2023"
ID="amzn"
ID_LIKE="fedora"
VERSION_ID="2023"
PLATFORM_ID="platform:al2023"
PRETTY_NAME="Amazon Linux 2023"
ANSI_COLOR="0;33"
CPE_NAME="cpe:2.3:o:amazon:amazon_linux:2023"
HOME_URL="https://aws.amazon.com/linux/amazon-linux-2023/"
DOCUMENTATION_URL="https://docs.aws.amazon.com/linux/"
```

---

### `uptime` — System Load & Running Duration
Shows how long the server has been running and CPU load averages (1, 5, and 15 minute windows).
- **Example:**
  ```bash
  uptime
  ```
- **Sample Output:**
  ```text
  23:45:12 up 5 days,  4:18,  1 user,  load average: 0.02, 0.01, 0.00
  ```

---

### `whoami` & `id` — Identity Verification on AL2023
- On Amazon Linux 2023, the default user is **`ec2-user`**, who belongs to the **`wheel`** administrative group:
  ```bash
  whoami
  id
  ```
- **Sample Output:**
  ```text
  ec2-user
  uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),19(systemd-journal)
  ```

---

### `free` — Memory Utilization
Displays total, used, free, and cached physical RAM and swap.
- **Syntax:** `free [OPTIONS]`
  - `-h`: Display in human-readable units (MB, GB).
- **Example:**
  ```bash
  free -h
  ```
- **Sample Output on t2.micro:**
  ```text
                 total        used        free      shared  buff/cache   available
  Mem:           952Mi       184Mi       452Mi       1.0Mi       316Mi       655Mi
  Swap:             0B          0B          0B
  ```

---

### `df` — Disk Space Usage
Reports filesystem capacity and mount points.
- **Example:**
  ```bash
  df -hT
  ```
- **Sample Output on Amazon Linux 2023:**
  ```text
  Filesystem     Type      Size  Used Avail Use% Mounted on
  devtmpfs       devtmpfs  4.0M     0  4.0M   0% /dev
  tmpfs          tmpfs     477M     0  477M   0% /dev/shm
  /dev/xvda4     xfs       8.0G  2.2G  5.8G  28% /
  /dev/xvda3     xfs       9.9M  6.1M  3.8M  62% /boot
  /dev/xvda2     vfat      100M  6.0M   94M   6% /boot/efi
  ```

---

## 2. Package Management with `dnf` (Amazon Linux 2023)

Amazon Linux 2023 uses **`dnf`** (Dandified YUM) as its next-generation package management utility.

| Operation | Command | Purpose |
|---|---|---|
| **Update Repositories & System** | `sudo dnf update -y` | Updates all installed packages to latest stable releases |
| **Install a Package** | `sudo dnf install httpd -y` | Downloads and installs Apache HTTP server and dependencies |
| **Remove a Package** | `sudo dnf remove httpd -y` | Uninstalls package from system |
| **Search Packages** | `dnf search nginx` | Searches repository package names and descriptions |
| **Display Package Info** | `dnf info httpd` | Shows version, release, architecture, and summary |
| **List Installed Packages** | `dnf list installed` | Lists all RPM packages currently installed |
| **Clean Package Cache** | `sudo dnf clean all` | Removes downloaded headers and cached packages to save space |

---

## 3. Navigation & Directory Inspection

### `pwd` — Print Working Directory
Displays the current working directory path.
```bash
pwd
# /home/ec2-user
```

---

### `ls` — List Directory Contents
- **Options:**
  - `-l`: Long listing format.
  - `-a`: Show hidden files (e.g., `.bashrc`, `.ssh`).
  - `-h`: Human-readable file sizes.
  - `-t`: Sort by modification time.
- **Example:**
  ```bash
  ls -lah /var/log/httpd/
  ```
- **Sample Output:**
  ```text
  drwxr-xr-x. 2 root root 4.0K Sep 12 18:00 .
  drwxr-xr-x. 9 root root 4.0K Sep 12 17:30 ..
  -rw-r--r--. 1 root root  12K Sep 12 18:30 access_log
  -rw-r--r--. 1 root root 2.1K Sep 12 18:30 error_log
  ```

---

### `cd` — Change Working Directory
- `cd ~`: Switch to current user's home directory (`/home/ec2-user`).
- `cd ..`: Move to parent directory.
- `cd -`: Switch to previously active directory.
- `cd /var/www/html`: Go directly to the Apache web document root.

---

## 4. File & Directory Management

### `mkdir` — Create Directories
```bash
# Create nested directories without error
mkdir -p /var/www/html/assets/images
```

### `touch` — Create Blank Files
```bash
touch /var/www/html/index.html
```

### `cp` — Copy Files and Directories
```bash
# Backup the main Apache configuration file before making changes
sudo cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

# Recursively copy web files
cp -r /home/ec2-user/site/* /var/www/html/
```

### `mv` — Move or Rename Files
```bash
mv app_old.conf app_new.conf
```

### `rm` — Remove Files and Directories
```bash
# Delete a file
rm old-config.txt

# Delete a directory recursively
rm -rf /tmp/test-build/
```

### `ln` — Create Symbolic Links
```bash
# Create a symbolic link to web root for quick navigation
ln -s /var/www/html ~/myweb
```

---

## 5. Reading, Searching & Inspecting Text Files

### File Viewers: `cat`, `less`, `head`, `tail`
- `cat /etc/os-release`: Print entire file content.
- `less /var/log/messages`: Page through system log (`q` to exit, `/` to search).
- `head -n 20 /etc/httpd/conf/httpd.conf`: View top 20 lines.
- `sudo tail -f /var/log/httpd/access_log`: **Follow live Apache access logs as web requests arrive.**

---

### `grep` — Pattern Searching
```bash
# Search for error messages in Apache logs
sudo grep -ri "error" /var/log/httpd/

# View active directives in httpd.conf (excluding comment lines and blank lines)
grep -v '^#' /etc/httpd/conf/httpd.conf | grep -v '^$'
```

---

### `find` — Locating Files
```bash
# Find all files ending in .conf under /etc/httpd/
find /etc/httpd -type f -name "*.conf"

# Find files modified in the last 24 hours
find /var/www/html -type f -mtime -1
```

---

### `wc` — Line, Word, and Byte Counts
```bash
# Count total requests logged by Apache
wc -l /var/log/httpd/access_log
```

---

## 6. Input/Output Redirection & Pipelines

| Operator | Function | Example |
|---|---|---|
| `>` | Overwrite stdout to file | `echo "ServerName localhost" > /etc/httpd/conf.d/name.conf` |
| `>>` | Append stdout to file | `echo "127.0.0.1 test" >> /etc/hosts` |
| `2>` | Redirect stderr | `ls /fake 2> error.log` |
| `&>` | Redirect stdout and stderr | `dnf update -y &> update.log` |
| `\|` (pipe) | Send output to next command | `ps aux \| grep httpd` |
| `tee` | Write to stdout and file simultaneously | `echo "web content" \| sudo tee /var/www/html/index.html` |

---

## 7. Archiving with `tar`

```bash
# Create a gzipped tar archive of the Apache web directory
sudo tar -czvf /home/ec2-user/web_backup.tar.gz /var/www/html/

# Extract archive
tar -xzvf /home/ec2-user/web_backup.tar.gz -C /tmp/restore/
```
