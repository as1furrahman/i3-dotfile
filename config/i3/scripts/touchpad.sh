#!/bin/bash

# ============================================================================
# Touchpad Configuration Script for i3 (requires xinput)
# ============================================================================

# Check if xinput is installed
if ! command -v xinput &> /dev/null; then
    echo "xinput not found. Please install it (sudo apt install xinput)."
    exit 1
fi

# Find all touchpad devices
# Grep for 'touchpad', ignore case, extract ID
TOUCHPAD_IDS=$(xinput list | grep -i "touchpad" | grep -o 'id=[0-9]*' | cut -d= -f2)

if [ -z "$TOUCHPAD_IDS" ]; then
    echo "No touchpad found."
    exit 0
fi

for id in $TOUCHPAD_IDS; do
    echo "Configuring Touchpad (ID: $id)..."

    # Enable Tap to Click (1 = enabled)
    # 283 usually corresponds to "libinput Tapping Enabled" but we use the name to be safe
    xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null && echo "  - Tapping Enabled" || echo "  - Failed to enable tapping"

    # Enable Natural Scrolling (1 = enabled)
    xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null && echo "  - Natural Scrolling Enabled" || echo "  - Failed to enable natural scrolling"

    # Enable Middle Button Emulation (optional, 1 = enabled)
    xinput set-prop "$id" "libinput Middle Emulation Enabled" 1 2>/dev/null && echo "  - Middle Emulation Enabled" || echo "  - Failed to enable middle emulation"
    
    # Disable While Typing (1 = enabled) - often enabled by default by libinput but good to force
    xinput set-prop "$id" "libinput Disable While Typing Enabled" 1 2>/dev/null && echo "  - DWT Enabled" || echo "  - Failed to enable DWT"
done

echo "Touchpad configuration complete."
