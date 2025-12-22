#!/bin/bash

# Monitor Manager for i3 - Rofi-based
# Supports scaling for mixed DPI setups (Zenbook OLED + Arzopa 14")

ROFI_THEME="$HOME/.config/rofi/ai-sidebar.rasi"

# Detect Monitors
INTERNAL=$(xrandr | grep " connected" | grep -E "^(eDP|LVDS)" | awk '{print $1}' | head -n 1)
EXTERNAL=$(xrandr | grep " connected" | grep -v "$INTERNAL" | awk '{print $1}' | head -n 1)

# Internal: 2880x1800 @ 13.3" = ~255 PPI
# External (Arzopa 14" 1080p): 1920x1080 @ 14" = ~157 PPI
# Scale factor for external to match internal effective size: ~0.6x

# Options
OPT_LAPTOP="󰌢  Laptop"
OPT_DUAL_RIGHT="󰍹  Dual Right"
OPT_DUAL_LEFT="󰍹  Dual Left"
OPT_EXTERNAL="󰍹  External Only"
OPT_MIRROR="󰑕  Mirror"

if [[ -z "$EXTERNAL" ]]; then
    $HOME/.config/i3/scripts/notify-osd.sh "" "No Display" 1008
    exit 0
fi

OPTIONS="$OPT_LAPTOP\n$OPT_DUAL_RIGHT\n$OPT_DUAL_LEFT\n$OPT_EXTERNAL\n$OPT_MIRROR"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰍹 " -theme "$ROFI_THEME" -mesg "<i>Select Display Layout</i>" -lines 6)

case "$CHOICE" in
    "$OPT_LAPTOP")
        xrandr --output "$INTERNAL" --auto --primary --scale 1x1 --output "$EXTERNAL" --off
        $HOME/.config/i3/scripts/notify-osd.sh "" "Laptop Only" 1008
        ;;
    "$OPT_DUAL_RIGHT")
        # Scale external to match internal effective DPI
        xrandr --output "$INTERNAL" --auto --primary --scale 1x1 \
               --output "$EXTERNAL" --auto --right-of "$INTERNAL" --scale 1.25x1.25
        $HOME/.config/i3/scripts/notify-osd.sh "" "Dual Right" 1008
        ;;
    "$OPT_DUAL_LEFT")
        xrandr --output "$INTERNAL" --auto --primary --scale 1x1 \
               --output "$EXTERNAL" --auto --left-of "$INTERNAL" --scale 1.25x1.25
        $HOME/.config/i3/scripts/notify-osd.sh "" "Dual Left" 1008
        ;;
    "$OPT_EXTERNAL")
        # External only - use native resolution with no scaling
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary --scale 1x1
        $HOME/.config/i3/scripts/notify-osd.sh "" "External" 1008
        ;;
    "$OPT_MIRROR")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        $HOME/.config/i3/scripts/notify-osd.sh "" "Mirrored" 1008
        ;;
esac

# Refresh wallpaper after layout change
~/.config/i3/scripts/wallpaper_manager.sh &
