#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

### 2) prompt for transform value
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

### 3) Create the autostart .service 
AUTOSTART_DIR="$HOME/.config/systemd/user"
DESKTOP_FILE="$AUTOSTART_DIR/chromium-kiosk.service"

echo "• Setting up autostart entry..."
mkdir -p "$AUTOSTART_DIR"

cat > "$DESKTOP_FILE" <<EOF
[Unit]
Description=Chromium Kiosk Mode
After=graphical.target sway-session.target
PartOf=graphical.target

[Service]
ExecStart=/usr/bin/chromium --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-save-password-bubble --disable-features=AutofillServerCommunication,KeyboardShortcuts --password-store=basic --incognito --no-first-run --disable-translate --disable-popup-blocking --disable-pinch --overscroll-history-navigation=0 https://$URL

Restart=always
RestartSec=2
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=%t
Environment=WAYLAND_DISPLAY=wayland-1

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable chromium-kiosk.service
echo "  → Created $DESKTOP_FILE"


### 4) create sway config
SWAY_DIR="$HOME/.config/sway"
SWAY_CONFIG="$HOME/.config/sway/config"
RES=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')
TOUCH=$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')
OUTPUT=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .name')

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


#output $OUTPUT {
#        mode $RES
#        transform $ROT
#}

### Input configuration

#input $TOUCH {
#    map_to_output $OUTPUT
#}


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

echo "sway config has been created"


### display fetch script 
mkdir -p "/home/kiosk/scripts"

cat > "/home/kiosk/scripts/fetch-display.sh" <<EOF
#!/usr/bin/env bash 
set -euo pipefail

# Query sway for active output, max resolution, and touch device
RES=\$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')
TOUCH=\$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')
OUTPUT=\$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .name')
ROTATION=$ROT
echo "Applying kiosk display config:"
echo "  OUTPUT=\$OUTPUT"
echo "  RES=\$RES"
echo "  TOUCH=\$TOUCH"

# Apply dynamically (no rotation here)
swaymsg "output \$OUTPUT mode \$RES transform \$ROTATION"
swaymsg "input \$TOUCH map_to_output \$OUTPUT"
EOF

chmod +x "/home/kiosk/scripts/fetch-display.sh"

echo "✅ All done! At next login, Chromium will launch in kiosk mode at https://$URL"


