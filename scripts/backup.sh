#!/bin/bash
set -e

# ============================================================================
# Backup Utility
# ============================================================================

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"

backup_configs() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Backing Up Existing Configurations${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    mkdir -p "$BACKUP_DIR"
    log "Backup directory: $BACKUP_DIR"
    
    # List of configs to backup
    local configs=(
        "$CONFIG_DIR/i3"
        "$CONFIG_DIR/i3blocks"
        "$CONFIG_DIR/alacritty"
        "$CONFIG_DIR/picom"
        "$CONFIG_DIR/nvim"
        "$CONFIG_DIR/lf"
        "$CONFIG_DIR/rofi"
        "$CONFIG_DIR/dunst"
        "$CONFIG_DIR/zathura"
        "$CONFIG_DIR/gtk-3.0"
        "$HOME/.zshrc"
        "$HOME/.zsh_aliases"
        "$HOME/.screenlayout"
    )
    
    local backed_up=0
    for config in "${configs[@]}"; do
        if [[ -e "$config" ]]; then
            local dest="$BACKUP_DIR/$(basename "$config")"
            cp -r "$config" "$dest"
            log "Backed up: $config"
            ((backed_up++)) || true
        fi
    done
    
    if [[ $backed_up -eq 0 ]]; then
        log "No existing configs found to backup."
    else
        success "Backed up $backed_up configuration(s) to $BACKUP_DIR"
    fi
}

# If run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    backup_configs
fi
