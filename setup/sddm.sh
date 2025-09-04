#!/usr/bin/env bash
set -euo pipefail

# Make sure the directory exists
sudo mkdir -p /etc/sddm.conf.d

# Create the sway.conf file if it doesn't exist
if [[ ! -f /etc/sddm.conf.d/sway.conf ]]; then
  sudo tee /etc/sddm.conf.d/sway.conf > /dev/null <<'EOF'
[Autologin]
User=kiosk
Session=sway.desktop
EOF
  echo "✅ Created sway.conf."
else
  echo "⚠️  /etc/sddm.conf.d/sway.conf already exists, not overwriting."
fi

echo "🔧 Enabling and setting SDDM as default display manager..."
sudo systemctl enable sddm.service
sudo systemctl set-default graphical.target

echo "✅ SDDM enabled. You can now reboot."

