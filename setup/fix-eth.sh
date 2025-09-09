#!/usr/bin/env bash
set -e

echo "🔧 Quick Ethernet Fix for Debian 13"

# 1. Get first non-loopback interface
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)

if [ -z "$IFACE" ]; then
    echo "❌ No network interface found!"
    exit 1
fi

echo "✅ Using interface: $IFACE"

# 2. Ensure NetworkManager is running
sudo systemctl enable --now NetworkManager || true

# 3. Delete old kiosk connections to avoid conflicts
sudo nmcli connection delete kiosk-eth >/dev/null 2>&1 || true
sudo nmcli connection delete static-eth >/dev/null 2>&1 || true

# 4. Add fresh DHCP connection
sudo nmcli connection add type ethernet ifname "$IFACE" con-name kiosk-eth
sudo nmcli connection modify kiosk-eth connection.autoconnect yes

# 5. Bring it up
sudo nmcli connection up kiosk-eth || sudo dhclient -v "$IFACE"

# 6. Test connectivity
if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
    echo "🌍 Internet works (ping 8.8.8.8 successful)"
else
    echo "⚠️ No internet via DHCP. You may need static IP."
    echo "👉 Example:"
    echo "   sudo nmcli connection add type ethernet ifname $IFACE con-name static-eth ip4 192.168.1.50/24 gw4 192.168.1.1"
fi
