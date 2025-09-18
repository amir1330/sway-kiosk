#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Updating package lists..."
sudo apt update

echo "📦 Installing PipeWire and related components..."
sudo apt install -y \
  pipewire \
  pipewire-pulse \
  pipewire-audio-client-libraries \
  libspa-0.2-bluetooth \
  libspa-0.2-jack \
  gstreamer1.0-pipewire

echo "📦 Installing SDDM (minimal, no recommends)..."
sudo apt install -y --no-install-recommends sddm

echo "📦 Installing Sway + tools..."
sudo apt install -y \
  sway \
  git \
  jq \
  chromium \
  xwayland isc-dhcp-client iproute2 net-tools wireless-tools iw wpasupplicant rfkill curl wget network-manager


sudo systemctl enable NetworkManager


echo "✅ All packages installed successfully."
