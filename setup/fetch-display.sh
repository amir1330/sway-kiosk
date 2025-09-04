#!/usr/bin/env bash
set -euo pipefail

# Query sway for active output, max resolution, and touch device
RES=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .modes | max_by(.width * .height) | "\(.width)x\(.height)"')
TOUCH=$(swaymsg -t get_inputs -r | jq -r '.[] | select(.type=="touch") | .identifier')
OUTPUT=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | .name')

echo "Applying kiosk display config:"
echo "  OUTPUT=$OUTPUT"
echo "  RES=$RES"
echo "  TOUCH=$TOUCH"

# Apply dynamically (no rotation here)
swaymsg "output $OUTPUT mode $RES"
swaymsg "input $TOUCH map_to_output $OUTPUT"
