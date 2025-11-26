#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi
[[ "$URL" =~ ^https?:// ]] || URL="https://$URL"

HOST=$(python3 -c "from urllib.parse import urlparse;print(urlparse('$URL').hostname or '')")

### 2) Prompt for transform value
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

### 3) Install OpenKiosk if missing
PKG_URL="https://openkiosk.mozdevgroup.com/files/openkiosk-2021.1.0.en-US.linux-x86_64.deb"
if ! command -v OpenKiosk >/dev/null 2>&1; then
  echo "📦 Installing OpenKiosk..."
  wget -O /tmp/openkiosk.deb "$PKG_URL"
  sudo apt-get install -y /tmp/openkiosk.deb
  rm -f /tmp/openkiosk.deb
else
  echo "✅ OpenKiosk already installed."
fi

### 4) Create OpenKiosk profile
PROFILE_DIR="$HOME/.openkiosk-profile"
echo "• Setting up OpenKiosk profile..."
mkdir -p "$PROFILE_DIR/chrome"

cat > "$PROFILE_DIR/user.js" <<EOF
// Homepage & startup
user_pref("browser.startup.homepage", "$URL");
user_pref("startup.homepage_welcome_url", "$URL");
user_pref("startup.homepage_welcome_url.additional", "$URL");

// OpenKiosk lockdown
user_pref("kiosk.enabled", true);
user_pref("kiosk.fullscreen", true);
user_pref("kiosk.hide_navigation_bar", true);
user_pref("kiosk.hide_tab_bar", true);
user_pref("kiosk.no_print", true);
user_pref("kiosk.no_downloads", true);
user_pref("kiosk.no_preferences", true);
user_pref("kiosk.force_navigation", true);
user_pref("kiosk.homepage", "$URL");

// Disable nags
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnOpen", false);
EOF


### 5) Create the autostart .service
AUTOSTART_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$AUTOSTART_DIR/openkiosk.service"

echo "• Setting up autostart entry..."
mkdir -p "$AUTOSTART_DIR"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=OpenKiosk Mode
After=graphical.target sway-session.target
PartOf=graphical.target

[Service]
Environment=MOZ_ENABLE_WAYLAND=1
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=%t
ExecStart=/usr/bin/OpenKiosk -profile $PROFILE_DIR

Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable openkiosk.service
echo "  → Created $SERVICE_FILE"

### 6) Create sway config
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

### 7) Display fetch script
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

echo "✅ All done! At next login, OpenKiosk will launch in kiosk mode at $URL"