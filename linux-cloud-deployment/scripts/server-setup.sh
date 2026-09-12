#!/bin/bash
# server-setup.sh
# Hardens a fresh Ubuntu EC2 instance and deploys Nginx as a test service.
# Run as: sudo bash server-setup.sh

set -e

echo ">>> Updating system packages..."
apt update && apt upgrade -y

echo ">>> Creating a non-root sudo user..."
read -p "Enter new username: " NEW_USER
adduser --gecos "" "$NEW_USER"
usermod -aG sudo "$NEW_USER"

echo ">>> Setting up SSH directory for new user..."
mkdir -p /home/"$NEW_USER"/.ssh
cp ~/.ssh/authorized_keys /home/"$NEW_USER"/.ssh/authorized_keys
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh
chmod 700 /home/"$NEW_USER"/.ssh
chmod 600 /home/"$NEW_USER"/.ssh/authorized_keys

echo ">>> Configuring UFW firewall..."
ufw allow OpenSSH
ufw allow 80/tcp
ufw --force enable
ufw status verbose

echo ">>> Installing and enabling Nginx..."
apt install nginx -y
systemctl enable nginx --now
systemctl status nginx --no-pager

echo ">>> Checking listening ports..."
ss -tulpn

echo ">>> Setup complete. Test with: curl localhost"
