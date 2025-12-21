#!/bin/bash

# Enable Network Time Protocol (NTP) for automatic time sync
timedatectl set-ntp true

# Detect Timezone via IP Geolocation (using ip-api.com)
TIMEZONE=$(curl -s http://ip-api.com/line?fields=timezone)

if [[ -n "$TIMEZONE" ]]; then
    CURRENT_TZ=$(timedatectl show --property=Timezone --value)
    
    if [[ "$TIMEZONE" != "$CURRENT_TZ" ]]; then
        # Set the detected timezone
        # Note: This may require sudo/polkit authentication depending on system config
        timedatectl set-timezone "$TIMEZONE"
        notify-send "Timezone Updated" "Switched to $TIMEZONE"
    fi
fi
