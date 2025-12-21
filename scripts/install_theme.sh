#!/bin/bash
set -e

# ============================================================================
# Tokyo Night Theme Installer (GTK & Icons)
# ============================================================================

THEME_DIR="$HOME/.local/share/themes"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$THEME_DIR" "$ICON_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Downloading Tokyo Night GTK Theme...${NC}"

# Using the active and public Tokyo Night GTK theme repository
# We use 'Tokyonight-Dark-B' if available, otherwise fallback to finding the theme.
# Fausto-Korpsvart is the current maintainer.
if [ ! -d "$THEME_DIR/Tokyonight-Dark-B" ] && [ ! -d "$THEME_DIR/Tokyonight-Dark" ]; then
    # Clone depth 1 for minimalism (no history)
    git clone --depth 1 https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git /tmp/tokyonight-gtk
    
    # Try to find the specific variant or just install all themes found in the repo
    if [ -d "/tmp/tokyonight-gtk/themes/Tokyonight-Dark-B" ]; then
        cp -r /tmp/tokyonight-gtk/themes/Tokyonight-Dark-B "$THEME_DIR/"
        echo -e "${GREEN}Installed Tokyonight-Dark-B GTK Theme${NC}"
    elif [ -d "/tmp/tokyonight-gtk/themes" ]; then
        # Install all variants if specific one not found
        cp -r /tmp/tokyonight-gtk/themes/* "$THEME_DIR/"
        echo -e "${GREEN}Installed all Tokyo Night GTK Theme variants${NC}"
    else
        # If the structure is flat (theme at root), look for index.theme to confirm
        if [ -f "/tmp/tokyonight-gtk/index.theme" ]; then
             cp -r /tmp/tokyonight-gtk "$THEME_DIR/Tokyonight-GTK-Theme"
             echo -e "${GREEN}Installed Tokyo Night GTK Theme (Root)${NC}"
        else
             echo -e "${BLUE}Attempting to find theme folders...${NC}"
             # Find folders containing index.theme and copy their parents
             find /tmp/tokyonight-gtk -name "index.theme" -printf "%h\n" | while read -r theme_path; do
                cp -r "$theme_path" "$THEME_DIR/"
             done
             echo -e "${GREEN}Installed discovered themes${NC}"
        fi
    fi
    rm -rf /tmp/tokyonight-gtk
else
    echo "Tokyo Night GTK theme already installed."
fi

# Icons
if [ ! -d "$ICON_DIR/Tokyonight-Moon" ]; then
    echo -e "${BLUE}Downloading Tokyo Night Icons...${NC}"
    git clone --depth 1 https://github.com/ljmill/TokyoNight-Icons.git /tmp/tokyonight-icons
    # Move them
    if [ -d "/tmp/tokyonight-icons/TokyoNight-Moon" ]; then
        cp -r /tmp/tokyonight-icons/TokyoNight-Moon "$ICON_DIR/"
        echo -e "${GREEN}Installed Tokyonight-Moon Icons${NC}"
    else
        # Fallback if structure is different
        cp -r /tmp/tokyonight-icons/* "$ICON_DIR/" 2>/dev/null || true
        echo -e "${GREEN}Installed Icon assets${NC}"
    fi
    rm -rf /tmp/tokyonight-icons
else
    echo "Tokyonight-Moon icons already installed."
fi

echo -e "${GREEN}Theme assets installed.${NC}"
