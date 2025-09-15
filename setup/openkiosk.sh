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
    0|90|180|270) echo "✅ Rotation set to $ROT" ;;
    *) echo "⚠️ Invalid rotation — must be 0, 90, 180, or 270." ; exit 1 ;;
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
mkdir -p "$PROFILE_DIR/extensions" "$PROFILE_DIR/chrome"

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

// Extensions forced active
user_pref("extensions.enabledScopes", 15);
user_pref("extensions.autoDisableScopes", 0);
user_pref("extensions.startupScanScopes", 0);

// Disable nags
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnOpen", false);
EOF

### 5) Redirector extension
EXT_DIR="$PROFILE_DIR/extensions"
TMPDIR=$(mktemp -d)
cat > "$TMPDIR/manifest.json" <<EOF
{
  "manifest_version": 2,
  "name": "OpenKiosk Redirector",
  "version": "1.0",
  "permissions": ["webRequest","webRequestBlocking","<all_urls>"],
  "background": { "scripts": ["background.js"] },
  "applications": { "gecko": { "id": "openkiosk-redirector@local" } }
}
EOF

cat > "$TMPDIR/background.js" <<EOF
const HOME="$URL";
const ALLOWED="$HOST";
function isAllowed(url) {
  try { let u=new URL(url); return u.hostname===ALLOWED||u.hostname.endsWith("."+ALLOWED);}catch(e){return false;}
}
browser.webRequest.onBeforeRequest.addListener(d=>{
  if(d.type!=="main_frame") return {};
  if(isAllowed(d.url)||d.url===HOME) return {};
  return {redirectUrl: HOME};
},{urls:["<all_urls>"]},["blocking"]);
EOF

(cd "$TMPDIR" && zip -r redirector.xpi . >/dev/null)
mv "$TMPDIR/redirector.xpi" "$EXT_DIR/openkiosk-redirector@local.xpi"
rm -rf "$TMPDIR"

### 6) Touchscreen Swipe Navigation extension
wget -q -O "$EXT_DIR/touchswipec@lucasgbde@gmail.com.xpi" \
  "https://addons.mozilla.org/firefox/downloads/latest/touchscreen-swipe-navigation/latest.xpi" || {
    echo "⚠️ Failed to download extension."
}

### 7) CSS fallback to hide bars
cat > "$PROFILE_DIR/chrome/userChrome.css" <<EOF
#TabsToolbar, #nav-bar, #titlebar { visibility: collapse !important; height: 0 !important; }
EOF

echo "✅ OpenKiosk profile created at $PROFILE_DIR"

### 8) Systemd autostart
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
ExecStart=/usr/bin/OpenKiosk -profile $PROFILE_DIR
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable openkiosk.service
echo "✅ Created $SERVICE_FILE"

### 9) sway config
SWAY_DIR="$HOME/.config/sway"
SWAY_CONFIG="$SWAY_DIR/config"
mkdir -p "$SWAY_DIR"

cat > "$SWAY_CONFIG" <<EOF
set \$mod Mod4
set \$term foot

exec_always --no-startup-id ~/scripts/fetch-display.sh

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

### 10) Display fetch script
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

swaymsg "output \$OUTPUT mode \$RES transform \$ROTATION"
swaymsg "input \$TOUCH map_to_output \$OUTPUT"
EOF
chmod +x "$HOME/scripts/fetch-display.sh"

### 11) Silent boot (GRUB2)
sudo sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub || true
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*$/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub || true
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub || true
sudo update-grub

echo "🎉 All done!"
echo "👉 Homepage: $URL"
echo "👉 Redirector installed (auto-redirects foreign domains)"
echo "👉 Touchscreen Swipe Navigation installed & enabled"
echo "👉 Tabs hidden"
echo "👉 GRUB menu disabled"