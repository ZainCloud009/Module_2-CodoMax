# Linux Filesystem Architecture & Disk Management (Amazon Linux 2023)

A deep dive into the Linux Filesystem Hierarchy Standard (FHS), NVMe and EBS block devices on AWS EC2, XFS filesystem structures, mounting persistence, and inode management on **Amazon Linux 2023 (AL2023)**.

---

## 1. Filesystem Hierarchy Standard (FHS) on AL2023

In Amazon Linux 2023, all files, disks, EBS volumes, and virtual hardware interfaces exist under the unified root directory `/`.

```
                                      / (Root)
     ┌──────────┬──────────┬──────────┼──────────┬──────────┬──────────┐
   /bin       /etc       /home      /var       /usr       /dev       /proc
 (Binaries) (Configs)   (Users)  (Variable)  (Apps)   (Devices)   (Kernel)
                          │           │
                     /home/ec2-user   ├────────────┬────────────┐
                                   /var/log     /var/www     /var/log/httpd
                                 (Sys Messages) (Apache Root) (Access Logs)
```

### Key Directory Specifications on Amazon Linux 2023:

| Directory | Name / Purpose | Amazon Linux 2023 Specifics |
|---|---|---|
| `/` | **Root Directory** | Top of the hierarchy. Formatted as **XFS** by default on AL2023. |
| `/etc/httpd` | **Apache Configuration** | Main configuration directory for Apache (`conf/httpd.conf`, `conf.d/`). |
| `/home/ec2-user`| **Default User Home** | Primary home directory for the default cloud user `ec2-user`. |
| `/var/log/messages`| **System Log** | Central operating system syslog facility on AL2023 (RHEL-based). |
| `/var/log/httpd` | **Apache Logs** | Default directory for `access_log` and `error_log`. |
| `/var/www/html` | **Web Document Root** | Standard Apache directory where `index.html` is served to web visitors. |
| `/dev` | **Device Nodes** | Hardware nodes: `/dev/xvda` or `/dev/nvme0n1` (NVMe block devices on modern Nitro EC2 instances). |
| `/proc` & `/sys` | **Kernel Virtual FS** | In-memory representations of processes (`/proc/<PID>`) and kernel parameters. |
| `/opt` | **Optional Packages** | Location for third-party tools like AWS CLI, CodeDeploy agent, SSM agent. |

---

## 2. Disk Space & Storage Inspection

### `df` — Filesystem Utilization
```bash
df -hT
```
**Sample Output on Amazon Linux 2023 (t2.micro):**
```text
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  4.0M     0  4.0M   0% /dev
tmpfs          tmpfs     477M     0  477M   0% /dev/shm
/dev/xvda4     xfs       8.0G  2.2G  5.8G  28% /
/dev/xvda3     xfs       9.9M  6.1M  3.8M  62% /boot
/dev/xvda2     vfat      100M  6.0M   94M   6% /boot/efi
```
> [!NOTE]
> Unlike Ubuntu which defaults to `ext4`, **Amazon Linux 2023 defaults to the high-performance `xfs` filesystem**.

---

### `lsblk` — List Block Devices (EBS & NVMe)
Shows block devices attached to the virtual machine:
```bash
lsblk -f
```
**Sample Output:**
```text
NAME        FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
xvda                                                                               
├─xvda1                                                                            
├─xvda2     vfat   FAT16       8E6A-DE9E                              94.0M     6% /boot/efi
├─xvda3     xfs          boot  b124a91c-34d1-4e89-a312-887711223344    3.8M    62% /boot
└─xvda4     xfs          root  d48e89f1-a7b2-4d56-8219-9876543210ab    5.8G    28% /
```

---

### `du` — Directory Space Utilization
```bash
# Check size of web root directory
sudo du -sh /var/www/html/

# Find top 10 largest folders on the server
sudo du -hx / | sort -rh | head -n 10
```

---

## 3. Storage Provisioning: Partitioning, Formatting & Mounting

When attaching a secondary EBS volume (e.g., `/dev/xvdf` or `/dev/nvme1n1`) on AWS EC2:

```bash
# 1. Inspect the new raw block device
sudo lsblk

# 2. Format with XFS filesystem (standard on AL2023)
sudo mkfs.xfs -L data-volume /dev/xvdf
# (Or use mkfs.ext4 if ext4 compatibility is needed)

# 3. Create mount target directory
sudo mkdir -p /mnt/data

# 4. Mount the volume
sudo mount /dev/xvdf /mnt/data

# 5. Verify mount
df -h /mnt/data
```

---

## 4. Persistent Mounting via `/etc/fstab`

Manual mounts disappear upon server reboot. To ensure the filesystem mounts automatically:

### 1. Get Device UUID
```bash
sudo blkid /dev/xvdf
# Output: /dev/xvdf: UUID="f1c24a5b-1123-4c56-91e8-7890abcd1234" BLOCK_SIZE="4096" TYPE="xfs"
```

### 2. Append Entry to `/etc/fstab`
```text
UUID=f1c24a5b-1123-4c56-91e8-7890abcd1234  /mnt/data  xfs  defaults,nofail  0  2
```

> [!IMPORTANT]
> Always include the **`nofail`** option when adding external or EBS mounts on AWS EC2. If the volume is detached in AWS, the instance will still boot normally without halting into emergency mode.

### 3. Verify Before Rebooting
```bash
# Test /etc/fstab configuration safely
sudo mount -a
```

---

## 5. Inodes and File Links

An **inode** (index node) stores file metadata (permissions, owner, size, timestamps, data block pointers).
- Check inode capacity:
  ```bash
  df -i
  ```
- Check file inode number:
  ```bash
  ls -li /var/www/html/index.html
  ```

### Hard Link vs. Soft Link:
```bash
# Hard Link: shares the same inode number
ln /var/www/html/index.html /home/ec2-user/index-hardlink.html

# Soft (Symbolic) Link: points to path by name (new inode)
ln -s /var/www/html/index.html /home/ec2-user/index-symlink.html
```
