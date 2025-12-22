#!/bin/bash
# Brightness Control Wrapper
# Usage: brightness_control.sh <up|down>

STEP="5%"
NOTIFY_ID=1002

case "$1" in
    up)
        brightnessctl set +$STEP
        ;;
    down)
        brightnessctl set $STEP-
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac

# Get current brightness percentage (0-100)
# brightnessctl -m format: name,device,val,percent,max,val
PCT_STR=$(brightnessctl -m | cut -d, -f4)
# Remove % sign
PCT=${PCT_STR%\%}

VAL="$PCT_STR"
PROG="$PCT"

# Select Icon
# Papirus names: notification-display-brightness-low, -medium, -high, -full
# Or display-brightness-low...
# Common names: display-brightness-low, display-brightness-medium, display-brightness-high

if [ "$PCT" -lt 30 ]; then
    ICON="display-brightness-low"
elif [ "$PCT" -lt 70 ]; then
    ICON="display-brightness-medium"
else
    ICON="display-brightness-high"
fi

# Send notification
$HOME/.config/i3/scripts/notify-osd.sh "$ICON" "$VAL" "$NOTIFY_ID" "$PROG"
