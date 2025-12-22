#!/bin/bash

# Automatic Timezone Setup
# Uses rofi-askpass for clean password prompt (instead of ugly polkit popup)

ASKPASS_SCRIPT="$HOME/.config/i3/scripts/rofi-askpass.sh"

# Enable Network Time Protocol (NTP) for automatic time sync
timedatectl set-ntp true 2>/dev/null || true

# Detect Timezone via IP Geolocation (using ip-api.com)
TIMEZONE=$(curl -s --connect-timeout 3 http://ip-api.com/line?fields=timezone)

if [[ -n "$TIMEZONE" ]]; then
    CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null)
    
    if [[ "$TIMEZONE" != "$CURRENT_TZ" ]]; then
        # Try silent sudo first (if NOPASSWD is configured)
        if sudo -n timedatectl set-timezone "$TIMEZONE" 2>/dev/null; then
            : # Success, no password needed
        elif [[ -x "$ASKPASS_SCRIPT" ]]; then
            # Use rofi-askpass for a clean, minimal password prompt
            export SUDO_ASKPASS="$ASKPASS_SCRIPT"
            sudo -A timedatectl set-timezone "$TIMEZONE" 2>/dev/null || true
        fi
        
        # Notify if timezone was changed
        NEW_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null)
        if [[ "$NEW_TZ" == "$TIMEZONE" ]] && command -v notify-send &>/dev/null; then
            notify-send -u low "Timezone" "Set to $TIMEZONE"
        fi
    fi
fi
