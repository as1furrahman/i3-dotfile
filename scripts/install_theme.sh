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

# Using a popular Tokyo Night GTK theme fork or similar
# Since official TokyoNight is mostly nvim/vim, we use 'Tokyonight-Dark-B' from reliable source if available.
# Fausto-Korrea is a common maintainer for these themes.
if [ ! -d "$THEME_DIR/Tokyonight-Dark-B" ]; then
    git clone https://github.com/Fausto-Korrea/Tokyonight-GTK-Theme.git /tmp/tokyonight-gtk
    cp -r /tmp/tokyonight-gtk/themes/Tokyonight-Dark-B "$THEME_DIR/"
    rm -rf /tmp/tokyonight-gtk
    echo -e "${GREEN}Installed Tokyonight-Dark-B GTK Theme${NC}"
else
    echo "Tokyonight-Dark-B already installed."
fi

# Icons (Tela-circle-tokyo-night or similar, or just stick to Papirus-Dark and modify folders?
# Let's install 'Papirus-Dark' via apt (done in packages) but we can use 'papirus-folders' to color it.
# BUT user wants "Fully Tokyo Night Themed".
# Using 'TokyoNight' icons if available.
# A popular one is 'TokyoNight-SE' or similar.
# For stability, we will grab the TokyoNight icon theme from a repo.

if [ ! -d "$ICON_DIR/Tokyonight-Moon" ]; then
    echo -e "${BLUE}Downloading Tokyo Night Icons...${NC}"
    git clone https://github.com/ljmill/TokyoNight-Icons.git /tmp/tokyonight-icons
    # Move them
    cp -r /tmp/tokyonight-icons/TokyoNight-Moon "$ICON_DIR/"
    rm -rf /tmp/tokyonight-icons
    echo -e "${GREEN}Installed Tokyonight-Moon Icons${NC}"
else
    echo "Tokyonight-Moon icons already installed."
fi

echo -e "${GREEN}Theme assets installed.${NC}"
