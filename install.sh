#!/bin/bash
set -e

# ============================================================================
# Dotfiles Installer for Debian 13 (Trixie) + i3
# Optimized for Asus Zenbook S 13 OLED (UM5302TA)
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Paths
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
CONFIG_DIR="$HOME/.config"

# Helper Functions
header() {
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_requirements() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}[ERROR] Do not run as root. The script will ask for sudo.${NC}"
        exit 1
    fi
    
    if [[ ! -f /etc/debian_version ]]; then
        echo -e "${RED}[ERROR] This script is for Debian only.${NC}"
        exit 1
    fi

    # Internet check
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}[ERROR] No internet connection.${NC}"
        exit 1
    fi
}

bios_check() {
    header "BIOS Configuration Check"
    echo -e "${YELLOW}Ensure the following BIOS settings are configured:${NC}"
    echo "1. VMD Controller: DISABLED (Critical for NVMe)"
    echo "2. Secure Boot: DISABLED"
    echo "3. Fast Boot: DISABLED"
    echo ""
    read -r -p "Are these settings configured? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) ;;
        *) echo -e "${RED}Please configure BIOS first.${NC}"; exit 1 ;;
    esac
}

# Wrapper functions for modular scripts
run_backup() { bash "$SCRIPTS_DIR/backup.sh"; }
run_packages() { bash "$SCRIPTS_DIR/package_install.sh"; }
run_hardware() { bash "$SCRIPTS_DIR/hardware_setup.sh"; }
run_post_install() { bash "$SCRIPTS_DIR/post_install.sh"; }
run_distrobox() { bash "$SCRIPTS_DIR/distrobox_setup.sh"; }

deploy_configs() {
    header "Deploying Config Files"
    
    # Ensure config directories exist (covered by post_install mostly, but good to be safe)
    mkdir -p "$CONFIG_DIR"
    
    # Copy configs
    # Using specific list to match requirements
    cp -r "$DOTFILES_DIR/config/i3" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/i3blocks" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/alacritty" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/rofi" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/picom" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/dunst" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/nvim" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/lf" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/zathura" "$CONFIG_DIR/"
    cp -r "$DOTFILES_DIR/config/gtk-3.0" "$CONFIG_DIR/"
    
    # Copy shell configs
    cp "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    cp "$DOTFILES_DIR/shell/.zsh_aliases" "$HOME/.zsh_aliases"

    # Perms
    chmod +x "$CONFIG_DIR/i3/scripts/"*.sh
    chmod +x "$CONFIG_DIR/lf/preview.sh"
    
    echo -e "${GREEN}[SUCCESS] Configuration files deployed.${NC}"
}

# Menus
full_install() {
    check_requirements
    bios_check
    run_backup
    run_packages
    run_hardware
    deploy_configs
    run_post_install
    
    header "Installation Complete!"
    echo "Please reboot your system."
}

show_menu() {
    clear
    echo -e "${BLUE}Dotfiles Installer - Debian 13 (Trixie)${NC}"
    echo "1. Full Installation"
    echo "2. Install Packages Only"
    echo "3. Deploy Configs Only"
    echo "4. Hardware Setup Only"
    echo "5. Post-Install Setup Only"
    echo "6. Backup Existing Configs"
    echo "7. Setup Distrobox"
    echo "8. Exit"
    echo ""
    read -r -p "Enter choice [1-8]: " choice
    
    case $choice in
        1) full_install ;;
        2) check_requirements; run_packages ;;
        3) check_requirements; run_backup; deploy_configs ;;
        4) check_requirements; run_hardware ;;
        5) check_requirements; run_post_install ;;
        6) check_requirements; run_backup ;;
        7) check_requirements; run_distrobox ;;
        8) exit 0 ;;
        *) echo "Invalid option"; sleep 1; show_menu ;;
    esac
}

# Main
mkdir -p "$SCRIPTS_DIR" # Safety check
if [[ $# -eq 0 ]]; then
    show_menu
else
    # Simple CLI args support
    case $1 in
        --full) full_install ;;
        --packages) run_packages ;;
        --configs) deploy_configs ;;
        --hardware) run_hardware ;;
        --help) echo "Usage: ./install.sh [--full|--packages|--configs|--hardware]"; exit 0 ;;
        *) echo "Unknown option"; exit 1 ;;
    esac
fi
