#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <1|2>"
  echo "  1 = Enable audio (PipeWire + WirePlumber)"
  echo "  2 = Disable audio (all audio off)"
  exit 1
fi

case "$1" in
  1)
    echo "🔊 Enabling audio with PipeWire..."
    systemctl --user disable pulseaudio.service pulseaudio.socket || true

    systemctl --user enable pipewire.service pipewire.socket
    systemctl --user enable pipewire-pulse.service pipewire-pulse.socket
    systemctl --user enable wireplumber.service

    systemctl --user start pipewire.service pipewire.socket
    systemctl --user start pipewire-pulse.service pipewire-pulse.socket
    systemctl --user start wireplumber.service
    ;;

  2)
    echo "🔇 Disabling all audio..."
    systemctl --user disable pulseaudio.service pulseaudio.socket || true
    systemctl --user disable pipewire.service pipewire.socket || true
    systemctl --user disable pipewire-pulse.service pipewire-pulse.socket || true
    systemctl --user disable wireplumber.service || true

    systemctl --user stop pulseaudio.service pulseaudio.socket || true
    systemctl --user stop pipewire.service pipewire.socket || true
    systemctl --user stop pipewire-pulse.service pipewire-pulse.socket || true
    systemctl --user stop wireplumber.service || true
    ;;

  *)
    echo "⚠️ Invalid option: $1"
    echo "Usage: $0 <1|2>"
    exit 1
    ;;
esac

echo "✅ Done."
