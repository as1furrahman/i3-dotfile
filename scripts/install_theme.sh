#!/bin/bash
set -e

# ============================================================================
# Tokyo Night Theme Installer (GTK & Icons)
# Simple, non-interactive, no authentication required
# ============================================================================

THEME_DIR="$HOME/.local/share/themes"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$THEME_DIR" "$ICON_DIR"

# Tokyo Night Color Palette
TN_BLUE='\033[38;5;111m'        # #7aa2f7 - Headers
TN_GREEN='\033[38;5;115m'       # #73daca - Success
TN_YELLOW='\033[38;5;179m'      # #e0af68 - Warnings
DIM='\033[2m'                   # Dim text
NC='\033[0m'                    # Reset

log() { echo -e "${DIM}  → $1${NC}"; }
success() { echo -e "${TN_GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${TN_YELLOW}  ⚠ $1${NC}"; }

# Download function: uses wget (pre-installed on Debian) or curl as fallback
download() {
    local url="$1"
    local output="$2"
    
    if command -v wget &> /dev/null; then
        wget -q --show-progress -O "$output" "$url"
    elif command -v curl &> /dev/null; then
        curl -fsSL -o "$output" "$url"
    else
        # Install wget as last resort
        warn "No download tool found. Installing wget..."
        sudo apt-get install -y wget > /dev/null 2>&1
        wget -q --show-progress -O "$output" "$url"
    fi
}

# GTK Theme
if [ ! -d "$THEME_DIR/Tokyonight-Dark-B" ] && [ ! -d "$THEME_DIR/Tokyonight-Dark" ]; then
    log "Downloading Tokyo Night GTK Theme..."
    
    download "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme/archive/refs/heads/master.zip" "/tmp/tokyonight-gtk.zip"
    
    unzip -q -o /tmp/tokyonight-gtk.zip -d /tmp/
    
    # Find and install theme variants
    if [ -d "/tmp/Tokyo-Night-GTK-Theme-master/themes" ]; then
        cp -r /tmp/Tokyo-Night-GTK-Theme-master/themes/* "$THEME_DIR/" 2>/dev/null || true
        success "Tokyo Night GTK themes installed"
    elif [ -d "/tmp/Tokyonight-GTK-Theme-master/themes" ]; then
        cp -r /tmp/Tokyonight-GTK-Theme-master/themes/* "$THEME_DIR/" 2>/dev/null || true
        success "Tokyo Night GTK themes installed"
    else
        warn "Theme structure not found, installing root folder"
        find /tmp -maxdepth 2 -name "Tokyonight*" -type d | head -1 | xargs -I{} cp -r {} "$THEME_DIR/"
    fi
    
    rm -rf /tmp/tokyonight-gtk.zip /tmp/*GTK-Theme-master /tmp/Tokyo-Night* 2>/dev/null || true
else
    log "Tokyo Night GTK theme already installed."
fi

# Icons
if [ ! -d "$ICON_DIR/TokyoNight-Moon" ] && [ ! -d "$ICON_DIR/Tokyonight-Moon" ]; then
    log "Downloading Tokyo Night Icons..."
    
    download "https://github.com/ljmill/tokyo-night-icons/archive/refs/heads/master.zip" "/tmp/tokyonight-icons.zip"
    
    unzip -q -o /tmp/tokyonight-icons.zip -d /tmp/
    
    if [ -d "/tmp/tokyo-night-icons-master/TokyoNight-Moon" ]; then
        cp -r /tmp/tokyo-night-icons-master/TokyoNight-Moon "$ICON_DIR/"
        success "Tokyo Night icons installed"
    else
        # Copy whatever icon folders exist
        cp -r /tmp/tokyo-night-icons-master/* "$ICON_DIR/" 2>/dev/null || true
        success "Tokyo Night icon assets installed"
    fi
    
    rm -rf /tmp/tokyonight-icons.zip /tmp/tokyo-night-icons-master 2>/dev/null || true
else
    log "Tokyo Night icons already installed."
fi

success "Theme installation complete!"
