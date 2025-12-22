#!/bin/bash

# Screenshot wrapper using maim
# Dependencies: maim, xclip, rofi (optional for menu)

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"

# Check arguments
if [[ "$1" == "select" ]]; then
    # Select area/window
    maim -s -u "$FILENAME"
elif [[ "$1" == "clipboard" ]]; then
    # Copy to clipboard
    maim -s -u | xclip -selection clipboard -t image/png
else
    # Full screen
    maim "$FILENAME"
fi

# Notify (if notify-send is available)
if command -v notify-send &> /dev/null; then
    if [[ -f "$FILENAME" ]]; then
        $HOME/.config/i3/scripts/notify-osd.sh "" "Saved" 1009
    fi
fi
