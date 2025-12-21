#!/bin/bash
set -e

# ============================================================================
# GRUB Theme Installer (Breeze)
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_NAME="breeze"
THEME_SOURCE="$DOTFILES_DIR/themes/grub/$THEME_NAME"
THEME_DEST="/boot/grub/themes/$THEME_NAME"
GRUB_CONFIG="/etc/default/grub"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing GRUB Theme: $THEME_NAME${NC}"

# Check for sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or via sudo"
    exit 1
fi

# 1. Copy theme files
echo "Copying theme to /boot/grub/themes/..."
mkdir -p /boot/grub/themes
if [ -d "$THEME_DEST" ]; then
    rm -rf "$THEME_DEST"
fi
cp -r "$THEME_SOURCE" /boot/grub/themes/

# 2. Update initramfs/grub config
echo "Updating $GRUB_CONFIG..."

# Comment out existing GRUB_THEME line if present
sed -i 's/^GRUB_THEME=/#GRUB_THEME=/' "$GRUB_CONFIG"

# Add new GRUB_THEME line
echo "GRUB_THEME=\"$THEME_DEST/theme.txt\"" >> "$GRUB_CONFIG"

# 3. Update GRUB
echo "Running update-grub..."
update-grub

echo -e "${GREEN}GRUB theme installed successfully! Reboot to see changes.${NC}"
