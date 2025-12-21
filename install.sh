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



# Wrapper functions for modular scripts
run_backup() { bash "$SCRIPTS_DIR/backup.sh"; }
run_packages() { bash "$SCRIPTS_DIR/package_install.sh"; }
run_hardware() { bash "$SCRIPTS_DIR/hardware_setup.sh"; }
run_theme() { bash "$SCRIPTS_DIR/install_theme.sh"; }
run_post_install() { bash "$SCRIPTS_DIR/post_install.sh"; }

deploy_configs() {
    header "Deploying Config Files (Symlinking)"
    
    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"
    
    # List of configs to symlink (directory-based)
    local configs=(
        "i3" "i3blocks" "alacritty" "rofi" "picom" 
        "dunst" "nvim" "lf" "zathura" "gtk-3.0"
    )
    
    for cfg in "${configs[@]}"; do
        if [ -d "$DOTFILES_DIR/config/$cfg" ]; then
            ln -sfn "$DOTFILES_DIR/config/$cfg" "$CONFIG_DIR/$cfg"
            echo -e "${GREEN}[OK]${NC} Linked $cfg"
        fi
    done
    
    # Symlink shell configs
    ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/shell/.zsh_aliases" "$HOME/.zsh_aliases"
    ln -sf "$DOTFILES_DIR/shell/.xinitrc" "$HOME/.xinitrc"
    ln -sf "$DOTFILES_DIR/shell/.Xresources" "$HOME/.Xresources"
    echo -e "${GREEN}[OK]${NC} Linked shell configs"

    # Permissions
    chmod +x "$DOTFILES_DIR/config/i3/scripts/"*.sh 2>/dev/null || true
    chmod +x "$DOTFILES_DIR/config/lf/preview.sh" 2>/dev/null || true
    
    echo -e "${GREEN}[SUCCESS] Symlinks created.${NC}"
}

# Menus
full_install() {
    check_requirements

    run_backup
    run_packages
    run_hardware
    run_theme
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
    echo "7. Install Theme Assets"
    echo "8. Install GRUB Theme"
    echo "9. Exit"
    echo ""
    read -r -p "Enter choice [1-9]: " choice
    
    case $choice in
        1) full_install ;;
        2) check_requirements; run_packages ;;
        3) check_requirements; run_backup; deploy_configs ;;
        4) check_requirements; run_hardware ;;
        5) check_requirements; run_post_install ;;
        6) check_requirements; run_backup ;;
        7) check_requirements; run_theme ;;
        8) sudo bash "$SCRIPTS_DIR/install_grub_theme.sh" ;;
        9) exit 0 ;;
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
