#!/bin/bash

# Dependencies: maim, imagemagick, i3lock

ICON="$HOME/.config/i3/lock-icon.png"
TMPBG="/tmp/screen_locked.png"

# Take a screenshot
maim "$TMPBG"

# Blur the screenshot (fast blur)
convert "$TMPBG" -blur 0x8 "$TMPBG"

# Add lock icon if available (optional)
# if [[ -f "$ICON" ]]; then
#     convert "$TMPBG" "$ICON" -gravity center -composite -matte "$TMPBG"
# fi

# Lock the screen
i3lock -i "$TMPBG" -n -c 000000

# Cleanup
rm "$TMPBG"
