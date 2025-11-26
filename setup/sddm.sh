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

### Silent boot (GRUB2)
echo "🤫 Configuring silent boot..."
sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub || true
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*$/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub || true
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub || true
sudo update-grub
echo "✅ GRUB updated for silent boot."
