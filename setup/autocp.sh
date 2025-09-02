#!/usr/bin/bash 

mkdir -p ~/.config/systemd/user
cp ~/sway-kiosk/setup/chromium-kiosk.service ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable chromium-kiosk.service


