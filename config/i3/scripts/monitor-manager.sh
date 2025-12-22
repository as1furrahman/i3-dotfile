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
    $HOME/.config/i3/scripts/notify-osd.sh "" "No Display" 1008
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
        $HOME/.config/i3/scripts/notify-osd.sh "" "Laptop Only" 1008
        ;;
    "$OPT_DUAL_RIGHT")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        $HOME/.config/i3/scripts/notify-osd.sh "" "Duel Right" 1008
        ;;
    "$OPT_DUAL_LEFT")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --left-of "$INTERNAL"
        $HOME/.config/i3/scripts/notify-osd.sh "" "Duel Left" 1008
        ;;
    "$OPT_EXTERNAL")
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary
        $HOME/.config/i3/scripts/notify-osd.sh "" "External" 1008
        ;;
    "$OPT_MIRROR")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        $HOME/.config/i3/scripts/notify-osd.sh "" "Mirrored" 1008
        ;;
esac

# Refresh wallpaper after layout change (feh needs to re-run)
~/.config/i3/scripts/wallpaper_manager.sh &
