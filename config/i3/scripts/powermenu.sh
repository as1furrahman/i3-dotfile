#!/usr/bin/env bash
#
# Power menu for i3 using Rofi
# Options: Lock, Logout, Reboot, Shutdown
#

set -e

# Menu options
OPTIONS="󰌾 Lock\n󰍃 Logout\n󰜉 Reboot\n󰐥 Shutdown"

# Rofi command
ROFI_CMD="rofi -dmenu -i -p 'Power' -font 'Cascadia Code 12' -lines 4 -width 200"

# Show menu and get selection
CHOICE=$(echo -e "$OPTIONS" | $ROFI_CMD)

case "$CHOICE" in
    *Lock*)
        "$HOME/.config/i3/scripts/blur-lock"
        ;;
    *Logout*)
        i3-msg exit
        ;;
    *Reboot*)
        systemctl reboot
        ;;
    *Shutdown*)
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
