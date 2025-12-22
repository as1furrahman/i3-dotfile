#!/bin/bash
# WiFi Toggle Wrapper
# Usage: wifi_toggle.sh

NOTIFY_ID=1004

# Toggle WiFi
nmcli radio wifi toggle

# Wait for state change
sleep 0.5

# Get new status and capitalize (Enabled/Disabled)
STATUS=$(nmcli radio wifi | sed 's/^./\u&/')

# Send notification
$HOME/.config/i3/scripts/notify-osd.sh "" "$STATUS" "$NOTIFY_ID"
