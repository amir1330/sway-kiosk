#!/usr/bin/env bash
set -euo pipefail

# Make sure the directory exists
sudo mkdir -p /etc/sddm.conf.d

# Create or overwrite sway.conf
sudo tee /etc/sddm.conf.d/sway.conf > /dev/null <<EOF
[Autologin]
User=$USER
Session=sway
EOF

echo "✅ /etc/sddm.conf.d/sway.conf has been created/updated with user '$USER'."

echo "🔧 Enabling and setting SDDM as the default display manager..."
sudo systemctl enable sddm.service
sudo systemctl set-default graphical.target

echo "✅ SDDM enabled and configured for user '$USER'. You can now reboot."
