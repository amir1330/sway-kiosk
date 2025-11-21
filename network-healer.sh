#!/bin/bash
set -e

echo "=== Installing Network Healer ==="

# ===========================
# Create main script
# ===========================
sudo tee /usr/local/bin/network-healer.sh >/dev/null << 'EOF'
#!/bin/bash

LOG="/var/log/network-healer.log"
echo -e "\n\n==== $(date) Starting Network Healer ====" >> "$LOG"

log() {
    echo "[+] $1" | tee -a "$LOG"
}

# -------------------------------------
# 1. Detect real ethernet device
# -------------------------------------
REAL_IFACE=$(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1 | head -n1)

if [ -z "$REAL_IFACE" ]; then
    log "No Ethernet interface detected. Exiting."
    exit 0
fi

log "Ethernet interface found: $REAL_IFACE"

# -------------------------------------
# 2. Check active ethernet connection
# -------------------------------------
ACTIVE_CONN=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$REAL_IFACE" | cut -d: -f1)

if [ -z "$ACTIVE_CONN" ]; then
    log "No active connection on $REAL_IFACE. Creating auto-eth."
    nmcli connection delete auto-eth 2>/dev/null
    nmcli connection add type ethernet ifname "$REAL_IFACE" con-name auto-eth
    nmcli connection up auto-eth
else
    log "Active connection: $ACTIVE_CONN"
fi

# -------------------------------------
# 3. Fix DNS always
# -------------------------------------
log "Setting reliable DNS..."
nmcli connection modify auto-eth ipv4.dns "8.8.8.8 1.1.1.1"
nmcli connection modify auto-eth ipv4.ignore-auto-dns yes

# -------------------------------------
# 4. Ensure DHCP enabled (IP + gateway)
# -------------------------------------
log "Ensuring IPv4 auto mode..."
nmcli connection modify auto-eth ipv4.method auto

# -------------------------------------
# 5. Bring the connection up
# -------------------------------------
log "Activating auto-eth..."
nmcli connection up auto-eth

# -------------------------------------
# 6. Test ping to gateway + DNS
# -------------------------------------
log "Testing connection..."

GATEWAY=$(ip route | grep default | awk '{print $3}')

if [ -n "$GATEWAY" ]; then
    log "Gateway detected: $GATEWAY"
    ping -c 1 "$GATEWAY" &>/dev/null && log "Gateway reachable." || log "Gateway NOT reachable!"
else
    log "No gateway detected!"
fi

ping -c 1 8.8.8.8 &>/dev/null && log "Internet ping OK." || log "Cannot reach 8.8.8.8!"

# DNS test
host google.com 8.8.8.8 &>/dev/null && log "DNS resolution OK." || log "DNS resolution FAILED!"

log "Network healer finished."
EOF

sudo chmod +x /usr/local/bin/network-healer.sh



# ===========================
# Create systemd service
# ===========================
sudo tee /etc/systemd/system/network-healer.service >/dev/null << 'EOF'
[Unit]
Description=Automatic Network Repair on Boot
After=NetworkManager.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/network-healer.sh

[Install]
WantedBy=multi-user.target
EOF


# ===========================
# Enable + start service
# ===========================
sudo systemctl daemon-reload
sudo systemctl enable network-healer.service
sudo systemctl start network-healer.service

echo "=== Network Healer installed and running ==="

