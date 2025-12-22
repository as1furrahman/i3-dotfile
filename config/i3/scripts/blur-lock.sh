#!/bin/bash

# Blur Lock Script for i3
# Dependencies: i3lock, maim, imagemagick (for blur effect)

TMPBG="/tmp/screen_locked.png"

# Try to create blurred background, fallback to solid color
if command -v maim &>/dev/null && command -v convert &>/dev/null; then
    # Take screenshot and blur
    maim "$TMPBG" 2>/dev/null && convert "$TMPBG" -blur 0x8 "$TMPBG" 2>/dev/null
fi

# Lock screen (Tokyo Night background color: #1a1b26)
if [[ -f "$TMPBG" ]]; then
    i3lock -i "$TMPBG" -c 1a1b26
else
    # Fallback: solid Tokyo Night color lock
    i3lock -c 1a1b26
fi

# Cleanup
rm -f "$TMPBG"
