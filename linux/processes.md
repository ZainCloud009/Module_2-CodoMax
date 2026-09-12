# Linux Process Management & Monitoring (Amazon Linux 2023)

A technical guide to process architecture, execution states, `httpd` master/worker inspection, signal handling, and background job control on **Amazon Linux 2023 (AL2023)**.

---

## 1. Process Architecture on AL2023

A **process** is an active program executing in memory. In Amazon Linux 2023:
- **PID 1:** Handled by `systemd` (`/usr/lib/systemd/systemd`).
- **Apache (`httpd`) Process Model:**
  - **Master Process (Root):** Runs as `root` because binding to privileged port 80 requires superuser privileges.
  - **Worker Processes (Apache):** Forked child processes that run as the unprivileged user `apache` to process client HTTP requests securely.

```bash
ps -ef | grep httpd
```
**Sample Output:**
```text
root       1420      1  0 18:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     1421   1420  0 18:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     1422   1420  0 18:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     1423   1420  0 18:00 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
- Notice that PID 1420 is the master owned by `root`, while PIDs 1421–1423 are workers owned by `apache` with `PPID = 1420`.

---

## 2. Process Lifecycle & Execution States

| State Code | State Name | Meaning & Behavior |
|:---:|---|---|
| **`R`** | **Running / Runnable** | Actively executing on CPU or in the run queue. |
| **`S`** | **Interruptible Sleep** | Waiting on an event (e.g., Apache waiting for an incoming HTTP request). |
| **`D`** | **Uninterruptible Sleep** | Blocked waiting on disk I/O. Cannot be interrupted by signals. |
| **`T`** | **Stopped** | Suspended by job control (`Ctrl+Z`) or `SIGSTOP`. |
| **`Z`** | **Zombie** | Completed execution but parent process hasn't read its exit status. |

---

## 3. Process Inspection Commands

### `ps` — Snapshot of Processes
```bash
# BSD format
ps aux | grep httpd

# System V format
ps -ef | grep httpd
```

### `pgrep` & `pidof`
```bash
# Find PIDs of all Apache processes
pgrep httpd

# Show process names alongside PIDs
pgrep -l httpd

# Get exact PIDs of httpd
pidof httpd
```

---

### Real-Time Monitoring: `top` & `htop`
```bash
# Launch standard top viewer
top
```
- Press `M`: Sort processes by memory consumption.
- Press `P`: Sort processes by CPU consumption.
- Press `q`: Quit.

```bash
# Install and run htop on AL2023
sudo dnf install htop -y
htop
```

---

## 4. Linux Signals & Controlling `httpd`

| Signal | Number | Effect on Apache `httpd` |
|:---:|:---:|---|
| **`SIGHUP`** | `1` | **Graceful Reload:** Re-reads configuration files without terminating active client connections. |
| **`SIGINT`** | `2` | **Interrupt:** Stops the process immediately (`Ctrl+C`). |
| **`SIGKILL`** | `9` | **Force Kill:** Unconditional termination by the kernel (no cleanup). |
| **`SIGTERM`** | `15` | **Graceful Stop:** Asks httpd to stop cleanly after finishing current requests. |

### Sending Signals:
```bash
# Reload Apache configuration using SIGHUP
sudo kill -HUP $(pidof httpd | awk '{print $NF}')

# Graceful termination (SIGTERM)
sudo kill 1420

# Force kill a hung process (SIGKILL)
sudo kill -9 1420

# Kill all httpd processes at once
sudo killall httpd
```

---

## 5. Job Control: Foreground & Background

```bash
# Run a script in the background using '&'
python3 test_load.py &

# View active background jobs
jobs -l

# Bring background job to foreground
fg %1

# Run process immune to hangups (survives SSH logout)
nohup python3 worker.py > worker.log 2>&1 &
```
