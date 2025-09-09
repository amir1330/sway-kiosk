#!/usr/bin/env bash
set -e

IFACE="enp2s0"

echo "🌐 Internet Fix Script Starting..."

# 1. Bring interface up
sudo ip link set "$IFACE" up || true

# 2. Ensure DHCP config exists for systemd-networkd
sudo mkdir -p /etc/systemd/network
cat <<EOF | sudo tee /etc/systemd/network/20-wired.network >/dev/null
[Match]
Name=$IFACE

[Network]
DHCP=ipv4
EOF

# 3. Restart network services
sudo systemctl enable systemd-networkd --now
sudo systemctl restart systemd-networkd
sudo systemctl enable systemd-resolved --now
sudo systemctl restart systemd-resolved

# 4. Fix resolv.conf symlink
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# 5. Add fallback DNS if none provided
if ! grep -q "nameserver" /etc/resolv.conf; then
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
    echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf
fi

# 6. Wait a bit for DHCP
sleep 3

# 7. Show IP
IP=$(ip -4 addr show "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
echo "📡 Current IP: ${IP:-none}"

# 8. Test connectivity
if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
    echo "✅ Can reach the internet (IP level)"
else
    echo "❌ No internet access"
    exit 1
fi

if ping -c 2 google.com >/dev/null 2>&1; then
    echo "✅ DNS works fine"
else
    echo "⚠️ DNS still broken, forcing fallback..."
    echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf
    sudo systemctl restart systemd-resolved
    ping -c 2 google.com || { echo "❌ DNS failed completely"; exit 1; }
fi

echo "🎉 Internet is fully working everywhere!"

