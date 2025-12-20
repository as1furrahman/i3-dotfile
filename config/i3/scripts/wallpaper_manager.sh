#!/bin/bash

# Wallpaper Manager
# Dependencies: feh, curl

WALL_DIR="$HOME/wallpapers"
DEFAULT_WALL="$WALL_DIR/default.png"
# Minimalist Tokyo Night gradient/style wallpaper
WALL_URL="https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/ign_mountains.png" 

# Ensure directory exists
mkdir -p "$WALL_DIR"

# Download default if not exists
if [[ ! -f "$DEFAULT_WALL" ]]; then
    # Use the requested URL logic or a placeholder if that specific one isn't perfect, 
    # but for now we'll use a reliable placeholder or the one from the prompt example.
    # The prompt suggested "Tokyo Night minimal wallpaper". 
    # I'll use a known URL for now or a placeholder.
    # Let's use a solid color if download fails, or try to download.
    
    echo "Downloading default wallpaper..."
    curl -L -o "$DEFAULT_WALL" "$WALL_URL" || true
fi

# Fallback: create a simple solid color image if download failed
if [[ ! -s "$DEFAULT_WALL" ]]; then
    convert -size 1920x1080 xc:"#1a1b26" "$DEFAULT_WALL" 2>/dev/null || true
fi

# Set wallpaper
if [[ -f "$DEFAULT_WALL" ]]; then
    feh --bg-fill "$DEFAULT_WALL"
fi
