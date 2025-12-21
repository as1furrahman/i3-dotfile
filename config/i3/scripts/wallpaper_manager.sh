#!/bin/bash

# Wallpaper Manager
# Dependencies: feh (preferred), xsetroot (fallback)

WALL_DIR="$HOME/.config/i3/wallpapers"
CURRENT_WALL="$HOME/.current_wallpaper"
FALLBACK_COLOR="#1a1b26"  # Tokyo Night background

set_wallpaper() {
    local img="$1"
    if command -v feh &>/dev/null; then
        feh --bg-fill "$img"
        echo "$img" > "$CURRENT_WALL"
    elif command -v hsetroot &>/dev/null; then
        hsetroot -fill "$img"
        echo "$img" > "$CURRENT_WALL"
    else
        # No image setter available, use solid color
        xsetroot -solid "$FALLBACK_COLOR"
    fi
}

# Check if wallpaper directory exists and has image files
if [[ -d "$WALL_DIR" ]]; then
    WALLPAPER=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)
    
    if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
        set_wallpaper "$WALLPAPER"
        exit 0
    fi
fi

# Fallback: solid Tokyo Night color
xsetroot -solid "$FALLBACK_COLOR"
