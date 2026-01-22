#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for transform value
read -rp "Enter screen rotation (0, 90, 180, 270)(clockwise): " ROT
case "$ROT" in
    0|90|180|270) 
        echo "✅ Rotation set to $ROT"
        ;;
    *)
        echo "⚠️ Invalid rotation — must be 0, 90, 180, or 270."
        exit 1
        ;;
esac

### 2) Install OpenKiosk if missing
PKG_URL="https://www.mozdevgroup.com/dropbox/okcd/115/release/OpenKiosk115.20.0-2025-02-16-x86_64.deb"
if ! command -v OpenKiosk >/dev/null 2>&1; then
  echo "📦 Installing OpenKiosk..."
  wget -O /tmp/openkiosk.deb "$PKG_URL"
  sudo apt-get install -y /tmp/openkiosk.deb
  rm -f /tmp/openkiosk.deb
else
  echo "✅ OpenKiosk already installed."
fi

### 3) Create the autostart .service
AUTOSTART_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$AUTOSTART_DIR/openkiosk.service"

echo "• Setting up autostart entry..."
mkdir -p "$AUTOSTART_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=OpenKiosk (Wayland / Firefox backend)
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
Environment=MOZ_ENABLE_WAYLAND=1
ExecStart=/usr/bin/OpenKiosk
Restart=always
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF
systemctl --user daemon-reload
systemctl --user enable openkiosk.service
echo "  → Created $SERVICE_FILE"

### 4) Create sway config
SWAY_DIR="$HOME/.config/sway"
SWAY_CONFIG="$HOME/.config/sway/config"

echo "• Setting up sway config..."
mkdir -p "$SWAY_DIR"

cat > "$SWAY_CONFIG" <<EOF
### Variables
#Logo key. Use Mod1 for Alt.
set \$mod Mod4

# Your preferred terminal emulator
set \$term foot

### Output configuration

exec_always --no-startup-id ~/scripts/fetch-display.sh

### Input configuration

input type:keyboard {
    xkb_layout "us,ru"
    xkb_options "grp:win_space_toggle,grp:alt_shift_toggle"
}
### Key bindings
# Basics:

    # Start a terminal
    bindsym \$mod+Return exec \$term

    # Kill focused window
    bindsym \$mod+Shift+q kill

    # bind volume control buttons
    bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
    bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%

    # bind brightness control buttons
    bindsym XF86MonBrightnessUp exec light -A 5 
    bindsym XF86MonBrightnessDown exec light -U 5 

    # Reload the configuration file
    bindsym \$mod+Shift+c reload


# Disable F1–F12 from doing anything inside apps
bindsym --release F1 nop
bindsym --release F2 nop
bindsym --release F3 nop
bindsym --release F4 nop
bindsym --release F5 nop
bindsym --release F6 nop
bindsym --release F7 nop
bindsym --release F8 nop
bindsym --release F9 nop
bindsym --release F10 nop
bindsym --release F11 nop
bindsym --release F12 nop

include /etc/sway/config.d/*

EOF

echo "  → Sway config has been created"

### 5) Display fetch script
mkdir -p "$HOME/scripts"

cat > "$HOME/scripts/fetch-display.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

# Query sway for active output, max resolution, and touch device
RES=\$(swaymsg -t get_outputs -r \\
  | jq -r 'map(select(.active)) | first | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')

OUTPUT=\$(swaymsg -t get_outputs -r \\
  | jq -r 'map(select(.active)) | first | .name')

TOUCH=\$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')
ROTATION=$ROT
echo "Applying kiosk display config:"
echo "  OUTPUT=\$OUTPUT"
echo "  RES=\$RES"
echo "  TOUCH=\$TOUCH"

# Apply dynamically
swaymsg "output \$OUTPUT mode \$RES transform \$ROTATION"
swaymsg "input \$TOUCH map_to_output \$OUTPUT"
EOF

chmod +x "$HOME/scripts/fetch-display.sh"

echo "✅ All done! At next login, OpenKiosk will launch in kiosk mode."