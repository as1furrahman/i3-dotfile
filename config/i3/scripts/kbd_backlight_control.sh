#!/bin/bash
# Keyboard Backlight Control Wrapper
# Usage: kbd_backlight_control.sh <up|down|off>

DEVICE="asus::kbd_backlight"
NOTIFY_ID=1003

case "$1" in
    up)
        brightnessctl -d "$DEVICE" set +33%
        ;;
    down)
        brightnessctl -d "$DEVICE" set 33%-
        ;;
    off)
        brightnessctl -d "$DEVICE" set 0
        ;;
    *)
        echo "Usage: $0 {up|down|off}"
        exit 1
        ;;
esac

# Get current percentage
PCT_STR=$(brightnessctl -d "$DEVICE" -m | cut -d, -f4)
PCT=${PCT_STR%\%}

# Determine Status
if [[ "$PCT_STR" == "0%" ]]; then
    VAL="Off"
    ICON="keyboard-brightness-low" # Or a "disabled" icon if available
    PROG="0"
else
    VAL="$PCT_STR"
    PROG="$PCT"
    ICON="keyboard-brightness-high"
fi

# Ideally find better icons like input-keyboard
if [ -z "$ICON" ]; then
    ICON="input-keyboard"
fi


# Send notification
$HOME/.config/i3/scripts/notify-osd.sh "$ICON" "$VAL" "$NOTIFY_ID" "$PROG"
