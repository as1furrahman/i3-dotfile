#!/bin/bash

# Wallpaper Manager
# Dependencies: feh (preferred), xsetroot (fallback)

# Get dotfiles directory (relative to this script)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# Primary: dotfiles wallpapers, Fallback: user's ~/wallpapers
WALL_DIR="$DOTFILES_DIR/wallpapers"
WALL_DIR_USER="$HOME/wallpapers"
CURRENT_WALL="$HOME/.current_wallpaper"
FALLBACK_COLOR="#1a1b26"  # Tokyo Night background

# Known dotfiles locations (fallback if primary path doesn't exist)
KNOWN_LOCATIONS=(
    "$HOME/i3-dotfile/wallpapers"
    "$HOME/.dotfiles/wallpapers"
    "$HOME/dotfiles/wallpapers"
)

# Try known locations if primary doesn't exist
if [[ ! -d "$WALL_DIR" ]]; then
    for loc in "${KNOWN_LOCATIONS[@]}"; do
        if [[ -d "$loc" ]]; then
            WALL_DIR="$loc"
            break
        fi
    done
fi

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

find_wallpaper() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | shuf -n 1
    fi
}

# Try dotfiles wallpapers first, then user wallpapers
WALLPAPER=$(find_wallpaper "$WALL_DIR")
[[ -z "$WALLPAPER" ]] && WALLPAPER=$(find_wallpaper "$WALL_DIR_USER")

if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    set_wallpaper "$WALLPAPER"
    exit 0
fi

# Fallback: solid Tokyo Night color
xsetroot -solid "$FALLBACK_COLOR"

