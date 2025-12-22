#!/bin/bash
# Minimal OSD Notification Helper
# Usage: notify-osd.sh <icon> <message> <replace-id> [progress]
#
# Uses dunstify for notification replacement.
# if progress (0-100) is provided, it shows a progress bar.

ICON="$1"
MSG="$2"
REPLACE_ID="${3:-9999}"
PROGRESS="$4"

# If icon is empty, look for device-specific defaults if implemented, or leave empty
# Actually wrapper scripts should provide the icon.

if [ -n "$PROGRESS" ] && [[ "$PROGRESS" =~ ^[0-9]+$ ]]; then
    dunstify -r "$REPLACE_ID" -t 1500 -u low -i "$ICON" -h int:value:"$PROGRESS" "$MSG"
else
    dunstify -r "$REPLACE_ID" -t 1500 -u low -i "$ICON" "$MSG"
fi
