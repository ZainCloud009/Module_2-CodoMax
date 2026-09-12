# Setup Log

A record of the commands run while configuring and securing the EC2 instance. Fill in actual output/timestamps as you go.

## 1. Initial Connection
```bash
ssh -i my-key.pem ubuntu@<public-ip>
```

## 2. System Update
```bash
sudo apt update && sudo apt upgrade -y
```
_Result: [ paste summary of packages updated ]_

## 3. User & Group Management
```bash
sudo adduser deployuser
sudo usermod -aG sudo deployuser
groups deployuser
```
_Result: [ confirm user created and added to sudo group ]_

## 4. File Permissions Review
```bash
ls -l /etc/ssh/sshd_config
sudo chmod 600 ~/.ssh/authorized_keys
```

## 5. Process & Service Management
```bash
ps aux | head -20
systemctl list-units --type=service --state=running
```
_Result: [ note key services running, e.g. ssh, systemd-journald, nginx ]_

## 6. Firewall Configuration (UFW)
```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status verbose
```
_Result: [ paste ufw status output ]_

## 7. Service Deployment (Nginx)
```bash
sudo apt install nginx -y
sudo systemctl enable nginx --now
sudo systemctl status nginx
```
_Result: [ confirm active (running) ]_

## 8. SSH Hardening (optional but recommended)
```bash
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

---
**Notes / issues encountered:** [ add anything that went wrong and how you fixed it — this is valuable to show real troubleshooting ]
