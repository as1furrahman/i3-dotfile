#!/bin/bash
# Volume Control Wrapper
# Usage: volume_control.sh <up|down|mute>

SINK="@DEFAULT_AUDIO_SINK@"
STEP="5%"
NOTIFY_ID=1001

case "$1" in
    up)
        wpctl set-volume -l 1.5 "$SINK" "$STEP"+
        ;;
    down)
        wpctl set-volume "$SINK" "$STEP"-
        ;;
    mute)
        wpctl set-mute "$SINK" toggle
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac

# Refresh status bar
pkill -RTMIN+10 i3blocks

# Get status
STATUS=$(wpctl get-volume "$SINK")
# STATUS format examples: "Volume: 0.40" or "Volume: 0.40 [MUTED]"

if echo "$STATUS" | grep -q "MUTED"; then
    ICON="audio-volume-muted"
    VAL="Muted"
    PROG="0" # Or maybe keep the level but show muted? Usually 0 visual confirms mute.
else
    # Extract volume as percentage (0-150)
    # Status string: Volume: 0.40 
    # awk gets 0.40 -> 40
    VOL_DEC=$(echo "$STATUS" | awk '{print $2}')
    VOL_PCT=$(awk -v v="$VOL_DEC" 'BEGIN {print int(v*100)}')
    
    VAL="${VOL_PCT}%"
    PROG="$VOL_PCT"

    # Select Icon
    if [ "$VOL_PCT" -eq 0 ]; then
        ICON="audio-volume-muted"
    elif [ "$VOL_PCT" -lt 30 ]; then
        ICON="audio-volume-low"
    elif [ "$VOL_PCT" -lt 70 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi
fi

# Send notification
$HOME/.config/i3/scripts/notify-osd.sh "$ICON" "$VAL" "$NOTIFY_ID" "$PROG"
