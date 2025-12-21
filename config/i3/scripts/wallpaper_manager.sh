#!/bin/bash

# Wallpaper Manager
# Dependencies: feh
# Source: https://github.com/AmadeusWM/dotfiles-hyprland

WALL_DIR="$HOME/repo/i3-dotfile/wallpapers"
CURRENT_WALL="$HOME/.current_wallpaper"

# Check if wallpaper directory exists and has files
if [[ -d "$WALL_DIR" ]] && [[ $(ls -A "$WALL_DIR" 2>/dev/null) ]]; then
    # Get random wallpaper
    WALLPAPER=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
    
    if [[ -n "$WALLPAPER" ]]; then
        feh --bg-fill "$WALLPAPER"
        echo "$WALLPAPER" > "$CURRENT_WALL"
    fi
else
    # Fallback: create a solid Tokyo Night color
    convert -size 1920x1080 xc:"#1a1b26" /tmp/fallback_wall.png 2>/dev/null && feh --bg-fill /tmp/fallback_wall.png
fi
