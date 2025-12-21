#!/bin/bash
# Touchpad Toggle - Enable/Disable touchpad

TOUCHPAD=$(xinput list | grep -i "touchpad" | grep -o 'id=[0-9]*' | cut -d= -f2 | head -1)

if [ -z "$TOUCHPAD" ]; then
    notify-send "Touchpad" "No touchpad found" -i input-touchpad
    exit 1
fi

# Get current state
ENABLED=$(xinput list-props "$TOUCHPAD" | grep "Device Enabled" | awk '{print $NF}')

if [ "$ENABLED" = "1" ]; then
    xinput disable "$TOUCHPAD"
    notify-send "Touchpad" "Disabled" -i input-touchpad
else
    xinput enable "$TOUCHPAD"
    notify-send "Touchpad" "Enabled" -i input-touchpad
fi
