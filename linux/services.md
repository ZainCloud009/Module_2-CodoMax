# Linux Service Management & systemd Architecture (Amazon Linux 2023)

A complete administrator's guide to systemd initialization, unit configuration, managing Apache (`httpd.service`) via `systemctl`, log auditing with `journalctl`, and custom service creation on **Amazon Linux 2023 (AL2023)**.

---

## 1. systemd Init System on AL2023

In Amazon Linux 2023, **systemd** runs as **PID 1**, managing system startup targets, daemon lifecycles, and dependency ordering.

### Key Unit Types:
- `.service`: Background daemons (e.g., `httpd.service`, `sshd.service`, `chronyd.service`).
- `.socket`: Sockets used for socket-activated services.
- `.target`: Grouping checkpoints (e.g., `multi-user.target`).
- `.timer`: Event schedulers replacing legacy `cron`.

---

## 2. Managing Apache (`httpd`) with `systemctl`

```bash
# Start Apache service
sudo systemctl start httpd

# Stop Apache service
sudo systemctl stop httpd

# Restart Apache (full stop and restart)
sudo systemctl restart httpd

# Reload configuration without dropping client web sessions
sudo systemctl reload httpd

# Check operational status and recent logs
sudo systemctl status httpd
```

### Sample Output: `systemctl status httpd`
```text
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
     Active: active (running) since Thu 2026-09-10 14:02:18 UTC; 2 days ago
       Docs: man:httpd.service(8)
   Main PID: 1420 (httpd)
     Status: "Total requests: 15; Idle/Busy workers 100/0;Requests/sec: 0.001; Bytes served/sec:   2 B/sec"
      Tasks: 177 (limit: 1143)
     Memory: 28.4M
        CPU: 420ms
     CGroup: /system.slice/httpd.service
             ├─1420 /usr/sbin/httpd -DFOREGROUND
             ├─1421 /usr/sbin/httpd -DFOREGROUND
             └─1422 /usr/sbin/httpd -DFOREGROUND
```

---

### Boot Persistence

```bash
# Enable Apache to start automatically on system boot AND start it immediately
sudo systemctl enable httpd --now

# Disable Apache from starting on boot AND stop it immediately
sudo systemctl disable httpd --now

# Verify boot enablement status
systemctl is-enabled httpd
# Output: enabled

# Verify runtime status
systemctl is-active httpd
# Output: active
```

---

## 3. Log Auditing with `journalctl`

systemd captures all `stdout` and `stderr` streams into a binary journal database.

```bash
# View complete log output for Apache httpd
sudo journalctl -u httpd.service

# Follow live Apache logs in real-time
sudo journalctl -u httpd.service -f

# View the last 50 log lines without launching a pager
sudo journalctl -u httpd.service -n 50 --no-pager

# Filter logs from the last 1 hour
sudo journalctl -u httpd.service --since "1 hour ago"

# View system boot logs
sudo journalctl -b

# Detailed diagnostic output when a service fails to start
sudo journalctl -xeu httpd.service
```

---

## 4. Creating a Custom systemd Service on AL2023

To deploy a custom background daemon (e.g., Python API) on Amazon Linux 2023:

### Step 1: Create Unit File
```bash
sudo nano /etc/systemd/system/webapp.service
```

### Step 2: Define Unit Configuration
```ini
[Unit]
Description=Production Python Application Service
After=network.target httpd.service
Wants=network-online.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/webapp
ExecStart=/usr/bin/python3 /home/ec2-user/webapp/app.py
Restart=always
RestartSec=5s
Environment="PORT=5000"
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Step 3: Register and Start Unit
```bash
# 1. Reload systemd daemon
sudo systemctl daemon-reload

# 2. Enable and start service
sudo systemctl enable --now webapp.service

# 3. Check health status
sudo systemctl status webapp.service
```
