#!/bin/bash

# Monitor Manager for i3 - Rofi-based
# Theme
ROFI_THEME="$HOME/.config/rofi/ai-sidebar.rasi"

# Detect Monitors
# INTERNAL: Usually starts with eDP or LVDS
INTERNAL=$(xrandr | grep " connected" | grep -E "^(eDP|LVDS)" | awk '{print $1}' | head -n 1)
# EXTERNAL: The first connected monitor that is NOT the internal one
EXTERNAL=$(xrandr | grep " connected" | grep -v "$INTERNAL" | awk '{print $1}' | head -n 1)

# Options
OPT_LAPTOP="󰌢  Laptop"
OPT_DUAL_RIGHT="󰍹  Dual Right"
OPT_DUAL_LEFT="󰍹  Dual Left"
OPT_EXTERNAL="󰍹  External Only"
OPT_MIRROR="󰑕  Mirror"

# If no external monitor found, just show info or exit
if [[ -z "$EXTERNAL" ]]; then
    notify-send "Monitor Manager" "No external monitor detected."
    exit 0
fi

# Rofi Menu
# We reuse the sidebar theme but maybe with fewer lines?
# Actually, let's use a smaller constraint or just the theme default.
# We pipe options to rofi.
OPTIONS="$OPT_LAPTOP\n$OPT_DUAL_RIGHT\n$OPT_DUAL_LEFT\n$OPT_EXTERNAL\n$OPT_MIRROR"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰍹 " -theme "$ROFI_THEME" -mesg "<i>Select Display Layout</i>" -lines 6)

case "$CHOICE" in
    "$OPT_LAPTOP")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --off
        notify-send "Monitor" "Switched to Laptop Only"
        ;;
    "$OPT_DUAL_RIGHT")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        notify-send "Monitor" "Dual Display (External Right)"
        ;;
    "$OPT_DUAL_LEFT")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --left-of "$INTERNAL"
        notify-send "Monitor" "Dual Display (External Left)"
        ;;
    "$OPT_EXTERNAL")
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary
        notify-send "Monitor" "Switched to External Only"
        ;;
    "$OPT_MIRROR")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        notify-send "Monitor" "Displays Mirrored"
        ;;
esac

# Refresh wallpaper after layout change (feh needs to re-run)
~/.config/i3/scripts/wallpaper_manager.sh &
