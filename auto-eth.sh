#!/bin/bash

# === Create auto-ethernet-fix.sh ===
cat << 'EOF' | sudo tee /usr/local/bin/auto-ethernet-fix.sh >/dev/null
#!/bin/bash

# Ищем реальный ethernet-интерфейс
REAL_IFACE=$(nmcli -t -f DEVICE,TYPE device | grep ethernet | cut -d: -f1 | head -n 1)

# Если интерфейс не найден — выходим
[ -z "$REAL_IFACE" ] && exit 0

# Ищем активное соединение Ethernet
CONFIG_IFACE=$(nmcli -t -f NAME,DEVICE connection show --active | grep ethernet | cut -d: -f2 | head -n 1)

# Если соединения нет — просто создаём новое
if [ -z "$CONFIG_IFACE" ]; then
    nmcli connection add type ethernet ifname "$REAL_IFACE" con-name auto-eth
    nmcli connection up auto-eth
    exit 0
fi

# Если имя интерфейса НЕ совпадает — пересоздать конфиг
if [ "$REAL_IFACE" != "$CONFIG_IFACE" ]; then
    nmcli connection delete auto-eth 2>/dev/null
    nmcli connection add type ethernet ifname "$REAL_IFACE" con-name auto-eth
    nmcli connection up auto-eth
fi
EOF

sudo chmod +x /usr/local/bin/auto-ethernet-fix.sh



# === Create systemd service ===
cat << 'EOF' | sudo tee /etc/systemd/system/auto-ethernet-fix.service >/dev/null
[Unit]
Description=Auto fix Ethernet interface name
After=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-ethernet-fix.sh

[Install]
WantedBy=multi-user.target
EOF



# === Reload systemd and enable the service ===
sudo systemctl daemon-reload
sudo systemctl enable auto-ethernet-fix.service
sudo systemctl start auto-ethernet-fix.service

echo "✓ Installed and enabled auto-ethernet-fix.service"

