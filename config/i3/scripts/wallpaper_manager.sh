#!/bin/bash

# Wallpaper Manager
# Dependencies: feh (required), xsetroot (fallback)

# Wait for X server to be ready (prevents black screen on startup)
sleep 0.3

FALLBACK_COLOR="#1a1b26"  # Tokyo Night background
CURRENT_WALL="$HOME/.current_wallpaper"

# Wallpaper search locations (in priority order)
WALLPAPER_DIRS=(
    "$HOME/wallpapers"                  # Primary: symlink from dotfiles
    "$HOME/i3-dotfile/wallpapers"       # Direct clone location
    "$HOME/.dotfiles/wallpapers"        # Alternative naming
    "$HOME/dotfiles/wallpapers"         # Alternative naming
)

# Also check relative to this script's location (for symlinked configs)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_WALL="$(cd "$SCRIPT_DIR/../../.." 2>/dev/null && pwd)/wallpapers"
[[ -d "$DOTFILES_WALL" ]] && WALLPAPER_DIRS+=("$DOTFILES_WALL")

set_wallpaper() {
    local img="$1"
    if command -v feh &>/dev/null; then
        feh --bg-fill "$img" 2>/dev/null && echo "$img" > "$CURRENT_WALL" && return 0
    fi
    if command -v hsetroot &>/dev/null; then
        hsetroot -fill "$img" 2>/dev/null && echo "$img" > "$CURRENT_WALL" && return 0
    fi
    return 1
}

find_random_wallpaper() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    # -L follows symlinks (required when wallpapers dir is symlinked)
    find -L "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n 1
}

# Search all wallpaper directories
for dir in "${WALLPAPER_DIRS[@]}"; do
    WALLPAPER=$(find_random_wallpaper "$dir")
    if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
        set_wallpaper "$WALLPAPER" && exit 0
    fi
done

# Fallback: solid Tokyo Night color (OLED-friendly)
xsetroot -solid "$FALLBACK_COLOR" 2>/dev/null

