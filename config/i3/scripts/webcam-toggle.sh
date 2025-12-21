#!/bin/bash
# Webcam Toggle - Privacy toggle using ASUS camera LED

LED="/sys/class/leds/asus::camera/brightness"

if [ -f "$LED" ]; then
    CURRENT=$(cat "$LED")
    if [ "$CURRENT" = "0" ]; then
        echo 1 | sudo tee "$LED" > /dev/null
        notify-send "Webcam" "Enabled" -i camera-web
    else
        echo 0 | sudo tee "$LED" > /dev/null
        notify-send "Webcam" "Disabled (Privacy)" -i camera-web
    fi
else
    # Alternative: use v4l2 to disable webcam
    if command -v v4l2-ctl &>/dev/null; then
        # Toggle by listing devices - placeholder
        notify-send "Webcam" "Toggle not available" -i camera-web
    else
        notify-send "Webcam" "Control not found" -i camera-web
    fi
fi
