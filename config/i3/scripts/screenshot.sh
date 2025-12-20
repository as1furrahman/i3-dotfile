#!/usr/bin/env bash
#
# Screenshot utility
# Captures selected area and copies to clipboard
# Requires: maim, xclip
#

set -e

# Take screenshot of selected area and copy to clipboard
maim -s | xclip -selection clipboard -t image/png

# Optional: Also save to file
# SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
# mkdir -p "$SCREENSHOTS_DIR"
# FILENAME="$SCREENSHOTS_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"
# xclip -selection clipboard -t image/png -o > "$FILENAME"

# Notify user
notify-send "Screenshot" "Copied to clipboard" -t 2000
