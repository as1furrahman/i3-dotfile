#!/bin/bash
set -e

# ============================================================================
# Backup Utility
# ============================================================================

# Tokyo Night Color Palette
TN_BLUE='\033[38;5;111m'        # #7aa2f7 - Headers
TN_GREEN='\033[38;5;115m'       # #73daca - Success
TN_YELLOW='\033[38;5;179m'      # #e0af68 - Warnings
DIM='\033[2m'                   # Dim text
NC='\033[0m'                    # Reset

log() { echo -e "${DIM}  → $1${NC}"; }
success() { echo -e "${TN_GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${TN_YELLOW}  ⚠ $1${NC}"; }

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"

backup_configs() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Backing Up Existing Configurations${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
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
