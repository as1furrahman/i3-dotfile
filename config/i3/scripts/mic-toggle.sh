#!/bin/bash

# Toggle microphone mute
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Get new status
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -o "MUTED")

# Handle hardware LED (Zenbook platform::micmute)
# Try standard LED paths
LED_PATH=""
if [ -d "/sys/class/leds/platform::micmute" ]; then
    LED_PATH="platform::micmute"
elif [ -d "/sys/class/leds/asus::micmute" ]; then
    LED_PATH="asus::micmute"
fi

# Set LED brightness (1 = LED ON = Muted for privacy indication)
# Or in some laptops 1 = LED ON = Active. 
# Usually for Mic Mute LED: Light ON means MUTED.
if [ -n "$LED_PATH" ]; then
    if [ "$STATUS" == "MUTED" ]; then
        brightnessctl -d "$LED_PATH" set 1
    else
        brightnessctl -d "$LED_PATH" set 0
    fi
fi

# Refresh i3blocks
pkill -RTMIN+11 i3blocks
