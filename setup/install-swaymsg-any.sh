#!/usr/bin/env bash
set -euo pipefail

# Target path
TARGET="/usr/local/bin/swaymsg-any"

# Script content
WRAPPER='#!/usr/bin/env bash
# Wrapper for swaymsg that works outside of the sway TTY

SOCK=$(ls -t /run/user/$(id -u)/sway-ipc.*.sock 2>/dev/null | head -n1)

if [[ -z "$SOCK" ]]; then
  echo "❌ No sway socket found. Is sway running?" >&2
  exit 1
fi

SWAYSOCK="$SOCK" swaymsg "$@"
'

echo "🔧 Installing swaymsg-any into $TARGET ..."
echo "$WRAPPER" | sudo tee "$TARGET" > /dev/null
sudo chmod +x "$TARGET"

echo "✅ swaymsg-any installed."
echo "Try: swaymsg-any -t get_outputs"
