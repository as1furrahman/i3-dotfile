#!/bin/bash
# Touchpad Toggle - Zenbook S 13 OLED
# Uses /sys to enable/disable touchpad via device power

TOUCHPAD="/sys/devices/platform/AMDI0010:01/i2c-1/i2c-ASUE140D:00/0018:04F3:31B9.0001/power/control"

toggle_touchpad() {
    # Method 1: Try xinput if available
    if command -v xinput &>/dev/null; then
        ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d= -f2 | head -1)
        if [ -n "$ID" ]; then
            ENABLED=$(xinput list-props "$ID" 2>/dev/null | grep "Device Enabled" | awk '{print $NF}')
            if [ "$ENABLED" = "1" ]; then
                xinput disable "$ID"
                notify-send "Touchpad" "Disabled" 2>/dev/null
            else
                xinput enable "$ID"
                notify-send "Touchpad" "Enabled" 2>/dev/null
            fi
            return
        fi
    fi
    
    # Method 2: Use libinput quirks (create a quirk file)
    QUIRK_FILE="/etc/libinput/local-overrides.quirks"
    if [ -f "$QUIRK_FILE" ] && grep -q "AttrEventCodeDisable" "$QUIRK_FILE" 2>/dev/null; then
        sudo rm "$QUIRK_FILE" 2>/dev/null
        notify-send "Touchpad" "Enabled (reboot may be needed)" 2>/dev/null
    else
        echo "[ASUE140D Touchpad Disable]" | sudo tee "$QUIRK_FILE" > /dev/null
        echo "MatchName=*04F3:31B9*" | sudo tee -a "$QUIRK_FILE" > /dev/null
        echo "AttrEventCodeDisable=EV_ABS;EV_KEY" | sudo tee -a "$QUIRK_FILE" > /dev/null
        notify-send "Touchpad" "Disabled (reboot may be needed)" 2>/dev/null
    fi
}

# Simple notify if nothing works
notify_fallback() {
    notify-send "Touchpad" "Use BIOS Fn key or install xinput" 2>/dev/null
}

# Check if touchpad key is hardware-handled
# On many Zenbooks, the touchpad Fn key is handled by firmware directly
# This script is a fallback

toggle_touchpad
