#!/usr/bin/env bash
set -euo pipefail

### 1) Prompt for your kiosk domain
read -rp "Enter the domain you want to open in kiosk mode (e.g. google.com or bromart.kz): " URL
if [[ -z "$URL" ]]; then
  echo "⚠️  No domain entered — exiting."
  exit 1
fi

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

### 3) Create OpenKiosk profile
PROFILE_DIR="$HOME/.openkiosk-profile"
mkdir -p "$PROFILE_DIR/extensions"

cat > "$PROFILE_DIR/user.js" <<EOF
// OpenKiosk startup page
user_pref("browser.startup.homepage", "https://$URL");
user_pref("startup.homepage_welcome_url", "https://$URL");
user_pref("startup.homepage_welcome_url.additional", "https://$URL");

// Force kiosk lockdown
user_pref("kiosk.enabled", true);
user_pref("kiosk.fullscreen", true);
user_pref("kiosk.no_print", true);
user_pref("kiosk.no_downloads", true);

// Whitelist / force redirect
user_pref("kiosk.whitelist", "https://$URL/*");
user_pref("kiosk.blacklist", "*");
user_pref("kiosk.force_navigation", true);

// Disable first-run & nags
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnOpen", false);
EOF

### 4) Install Touchscreen Swipe Navigation extension
echo "• Downloading Touchscreen Swipe Navigation..."
wget -q -O "$PROFILE_DIR/extensions/touchswipe@extension.xpi" \
  "https://addons.mozilla.org/firefox/downloads/latest/touchscreen-swipe-navigation/latest.xpi" || {
    echo "⚠️ Failed to download extension — continuing without it."
}

echo "✅ OpenKiosk profile created at $PROFILE_DIR"

### 5) Create systemd autostart service for OpenKiosk
AUTOSTART_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$AUTOSTART_DIR/openkiosk.service"

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
ExecStart=/usr/bin/openkiosk -profile $PROFILE_DIR
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable openkiosk.service
echo "✅ Created $SERVICE_FILE"

### 6) Create sway config
SWAY_DIR="$HOME/.config/sway"
SWAY_CONFIG="$SWAY_DIR/config"
RES=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')
TOUCH=$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')
OUTPUT=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .name')

echo "• Setting up sway config..."
mkdir -p "$SWAY_DIR"

cat > "$SWAY_CONFIG" <<EOF
### Variables
set \$mod Mod4
set \$term foot

exec_always --no-startup-id ~/scripts/fetch-display.sh

### Key bindings
bindsym \$mod+Return exec \$term
bindsym \$mod+Shift+q kill

# Disable F1–F12
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

echo "✅ sway config created"

### 7) Display fetch script
mkdir -p "$HOME/scripts"

cat > "$HOME/scripts/fetch-display.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

RES=\$(swaymsg -t get_outputs -r \
  | jq -r 'map(select(.active)) | first | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')

OUTPUT=\$(swaymsg -t get_outputs -r \
  | jq -r 'map(select(.active)) | first | .name')

TOUCH=\$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')

ROTATION=$ROT

echo "Applying kiosk display config:"
echo "  OUTPUT=\$OUTPUT"
echo "  RES=\$RES"
echo "  TOUCH=\$TOUCH"

swaymsg "output \$OUTPUT mode \$RES transform \$ROTATION"
swaymsg "input \$TOUCH map_to_output \$OUTPUT"
EOF

chmod +x "$HOME/scripts/fetch-display.sh"

### 8) Configure GRUB2 for silent boot
echo "• Configuring GRUB bootloader..."
sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub || true
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*$/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub || true
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub || true
sudo update-grub

echo "✅ GRUB is now set to boot straight into Debian (no menu)"

echo "🎉 All done! At next login, OpenKiosk will launch in kiosk mode at https://$URL"