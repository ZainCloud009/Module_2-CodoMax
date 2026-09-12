#!/usr/bin/env bash
# server-setup.sh — Automated Amazon Linux 2023 Hardening & Apache httpd Deployment
# Run as root or with sudo: sudo bash server-setup.sh [NEW_USER]

set -euo pipefail

NEW_USER="${1:-deployuser}"

echo "======================================================"
echo " Starting Automated Amazon Linux 2023 Provisioning"
echo " Target User: ${NEW_USER}"
echo " Web Server:  Apache (httpd)"
echo "======================================================"

# 1. Update system packages using dnf
echo ">>> [1/6] Updating system packages via dnf..."
dnf update -y

# 2. Create non-root user and add to wheel group
echo ">>> [2/6] Provisioning user ${NEW_USER} in wheel group..."
if ! id -u "${NEW_USER}" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "${NEW_USER}"
    usermod -aG wheel "${NEW_USER}"
    echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${NEW_USER}"
    chmod 0440 "/etc/sudoers.d/${NEW_USER}"
fi

# 3. Setup SSH directory
echo ">>> [3/6] Setting up SSH keys for ${NEW_USER}..."
mkdir -p "/home/${NEW_USER}/.ssh"
if [ -f "/home/ec2-user/.ssh/authorized_keys" ]; then
    cp "/home/ec2-user/.ssh/authorized_keys" "/home/${NEW_USER}/.ssh/authorized_keys"
fi
chown -R "${NEW_USER}:${NEW_USER}" "/home/${NEW_USER}/.ssh"
chmod 700 "/home/${NEW_USER}/.ssh"
chmod 600 "/home/${NEW_USER}/.ssh/authorized_keys"

# 4. Install and configure firewalld
echo ">>> [4/6] Configuring host firewall (firewalld)..."
dnf install -y firewalld
systemctl enable firewalld --now
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# 5. Install and enable Apache httpd
echo ">>> [5/6] Installing and starting Apache (httpd)..."
dnf install -y httpd
systemctl enable httpd --now

# 6. Verify listening ports
echo ">>> [6/6] Verifying open listening sockets..."
ss -tulpn

echo "======================================================"
echo " Deployment Complete! Test with: curl http://localhost"
echo "======================================================"
