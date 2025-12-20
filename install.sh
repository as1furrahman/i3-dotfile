#!/usr/bin/env bash
#
# Dotfiles Installer for Debian 13 (Trixie) + i3
# Optimized for Asus Zenbook S 13 OLED (UM5302TA)
#
# Usage:
#   ./install.sh                 - Full installation
#   ./install.sh --backup        - Backup existing configs only
#   ./install.sh --configs-only  - Deploy configs without packages
#   ./install.sh --packages-only - Install packages only
#   ./install.sh --hardware      - Configure Zenbook hardware only
#   ./install.sh --help          - Show help
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DIR="$HOME/.config"
readonly LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Packages to install
readonly PACKAGES=(
    # X11 and i3
    xorg xinit i3-wm i3blocks i3lock suckless-tools
    # Terminal and tools
    alacritty picom feh xautolock maim xclip brightnessctl
    # File managers
    thunar lf
    # System monitors
    btop htop
    # Editors
    neovim micro
    # Launcher and notifications
    rofi dunst clipman
    # Shell
    zsh zsh-autosuggestions zsh-syntax-highlighting
    # Applications
    pass zathura firefox-esr evince
    # Audio (Pipewire)
    pipewire pipewire-pulse wireplumber pavucontrol
    # Firmware and drivers
    firmware-linux firmware-linux-nonfree firmware-amd-graphics
    firmware-sof-signed firmware-iwlwifi
    # System
    bluez network-manager tlp tlp-rdw powertop
    # Fonts and themes
    fonts-noto-color-emoji papirus-icon-theme arc-theme
    # Utilities
    dex arandr imagemagick curl wget git unzip fontconfig
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
    exit 1
}

header() {
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_help() {
    cat << 'EOF'
Dotfiles Installer for Debian 13 (Trixie) + i3
Optimized for Asus Zenbook S 13 OLED (UM5302TA)

Usage: ./install.sh [OPTION]

Options:
    (no option)       Full installation (recommended for fresh install)
    --backup          Backup existing configs only
    --configs-only    Deploy configs without installing packages
    --packages-only   Install packages only (no config deployment)
    --hardware        Configure Zenbook hardware only
    --help            Show this help message

Examples:
    ./install.sh                    # Full installation
    ./install.sh --backup           # Just backup current configs
    ./install.sh --configs-only     # Deploy configs (packages already installed)

For more information, see README.md
EOF
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root. It will ask for sudo when needed."
    fi
}

check_os() {
    header "Checking Operating System"
    
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot detect OS. /etc/os-release not found."
    fi
    
    # shellcheck source=/dev/null
    source /etc/os-release
    
    if [[ "$ID" != "debian" ]]; then
        error "This script is designed for Debian. Detected: $ID"
    fi
    
    if [[ "$VERSION_CODENAME" != "trixie" && "$VERSION_CODENAME" != "sid" ]]; then
        warn "This script is optimized for Debian 13 (Trixie)."
        warn "Detected: $VERSION_CODENAME. Proceeding anyway..."
    else
        success "Detected Debian 13 (Trixie)"
    fi
}

show_bios_warning() {
    header "BIOS Configuration Warning"
    
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  IMPORTANT: Check BIOS settings before continuing!           ║${NC}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}║  For Asus Zenbook S 13 OLED (UM5302TA):                      ║${NC}"
    echo -e "${YELLOW}║                                                              ║${NC}"
    echo -e "${YELLOW}║  1. VMD Controller: DISABLED (required for NVMe detection)   ║${NC}"
    echo -e "${YELLOW}║  2. Secure Boot: DISABLED (for third-party drivers)          ║${NC}"
    echo -e "${YELLOW}║  3. Fast Boot: DISABLED (for proper USB detection)           ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -r -p "Have you configured BIOS correctly? [y/N] " REPLY
    case "$REPLY" in
        [Yy]|[Yy][Ee][Ss])
            success "BIOS configuration confirmed. Continuing..."
            ;;
        *)
            warn "Please configure BIOS and run this script again."
            echo ""
            read -r -p "Press Enter to exit..."
            exit 0
            ;;
    esac
}

# ============================================================================
# BACKUP FUNCTIONS
# ============================================================================

backup_configs() {
    header "Backing Up Existing Configurations"
    
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

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

enable_repositories() {
    header "Enabling Non-Free Repositories"
    
    # Check if non-free is already enabled
    if grep -q "non-free" /etc/apt/sources.list 2>/dev/null; then
        log "Non-free repositories already enabled."
        return 0
    fi
    
    log "Adding contrib, non-free, and non-free-firmware to sources.list..."
    
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
    
    # Update sources.list to include non-free
    sudo sed -i 's/main$/main contrib non-free non-free-firmware/' /etc/apt/sources.list
    
    success "Repositories updated"
}

install_packages() {
    header "Installing Packages"
    
    log "Updating package lists..."
    sudo apt update
    
    log "Installing packages (this may take a while)..."
    
    local failed_packages=()
    
    for pkg in "${PACKAGES[@]}"; do
        if dpkg -l "$pkg" &> /dev/null 2>&1; then
            log "Already installed: $pkg"
        else
            if sudo apt install -y "$pkg" >> "$LOG_FILE" 2>&1; then
                success "Installed: $pkg"
            else
                warn "Failed to install: $pkg"
                failed_packages+=("$pkg")
            fi
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        warn "Some packages failed to install: ${failed_packages[*]}"
        warn "You may need to install them manually."
    else
        success "All packages installed successfully"
    fi
}

# ============================================================================
# FONT INSTALLATION
# ============================================================================

install_fonts() {
    header "Installing Fonts"
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Install Cascadia Code
    log "Installing Cascadia Code..."
    local cascadia_url="https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip"
    local cascadia_zip="/tmp/CascadiaCode.zip"
    
    if [[ ! -f "$fonts_dir/CascadiaCode-Regular.otf" ]]; then
        if curl -fsSL -o "$cascadia_zip" "$cascadia_url" 2>/dev/null || wget -q -O "$cascadia_zip" "$cascadia_url"; then
            unzip -q -o "$cascadia_zip" -d /tmp/CascadiaCode
            cp /tmp/CascadiaCode/ttf/*.ttf "$fonts_dir/" 2>/dev/null || true
            cp /tmp/CascadiaCode/otf/static/*.otf "$fonts_dir/" 2>/dev/null || true
            rm -rf /tmp/CascadiaCode "$cascadia_zip"
            success "Cascadia Code installed"
        else
            warn "Failed to download Cascadia Code"
        fi
    else
        log "Cascadia Code already installed"
    fi
    
    # Install JetBrains Mono
    log "Installing JetBrains Mono..."
    local jetbrains_url="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
    local jetbrains_zip="/tmp/JetBrainsMono.zip"
    
    if [[ ! -f "$fonts_dir/JetBrainsMono-Regular.ttf" ]]; then
        if curl -fsSL -o "$jetbrains_zip" "$jetbrains_url" 2>/dev/null || wget -q -O "$jetbrains_zip" "$jetbrains_url"; then
            unzip -q -o "$jetbrains_zip" -d /tmp/JetBrainsMono
            cp /tmp/JetBrainsMono/fonts/ttf/*.ttf "$fonts_dir/" 2>/dev/null || true
            rm -rf /tmp/JetBrainsMono "$jetbrains_zip"
            success "JetBrains Mono installed"
        else
            warn "Failed to download JetBrains Mono"
        fi
    else
        log "JetBrains Mono already installed"
    fi
    
    # Refresh font cache
    log "Refreshing font cache..."
    fc-cache -fv >> "$LOG_FILE" 2>&1 || true
    success "Font cache updated"
}

# ============================================================================
# HARDWARE CONFIGURATION
# ============================================================================

configure_hardware() {
    header "Configuring Hardware (Zenbook S 13 OLED)"
    
    # Configure Pipewire (replace PulseAudio)
    log "Configuring Pipewire audio..."
    if command -v pipewire &> /dev/null; then
        # Remove PulseAudio if present
        if dpkg -l pulseaudio &> /dev/null 2>&1; then
            log "Removing PulseAudio..."
            sudo apt remove -y pulseaudio pulseaudio-utils >> "$LOG_FILE" 2>&1 || true
        fi
        
        # Enable Pipewire services
        systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
        success "Pipewire configured"
    else
        warn "Pipewire not found. Install packages first."
    fi
    
    # Configure TLP for battery optimization
    log "Configuring TLP..."
    if command -v tlp &> /dev/null; then
        sudo systemctl enable tlp >> "$LOG_FILE" 2>&1 || true
        sudo systemctl start tlp >> "$LOG_FILE" 2>&1 || true
        success "TLP enabled"
    else
        warn "TLP not found. Install packages first."
    fi
    
    # Configure swappiness for better performance on SSD
    log "Configuring swappiness..."
    if ! grep -q "vm.swappiness=10" /etc/sysctl.conf 2>/dev/null; then
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
        sudo sysctl -p >> "$LOG_FILE" 2>&1 || true
        success "Swappiness set to 10"
    else
        log "Swappiness already configured"
    fi
    
    # Add user to video group for brightness control
    if ! groups | grep -q video; then
        log "Adding user to video group..."
        sudo usermod -aG video "$USER"
        success "Added to video group (re-login required)"
    else
        log "User already in video group"
    fi
    
    # Add user to input group for input devices
    if ! groups | grep -q input; then
        log "Adding user to input group..."
        sudo usermod -aG input "$USER"
        success "Added to input group (re-login required)"
    else
        log "User already in input group"
    fi
    
    success "Hardware configuration complete"
}

# ============================================================================
# CONFIG DEPLOYMENT
# ============================================================================

deploy_configs() {
    header "Deploying Configuration Files"
    
    # Create necessary directories
    mkdir -p "$CONFIG_DIR"/{i3/scripts,i3blocks,alacritty,picom,nvim,lf,rofi,dunst,zathura,gtk-3.0,wallpapers}
    mkdir -p "$HOME/projects"
    mkdir -p "$HOME/.screenlayout"
    
    # Deploy i3 config
    if [[ -f "$DOTFILES_DIR/config/i3/config" ]]; then
        cp "$DOTFILES_DIR/config/i3/config" "$CONFIG_DIR/i3/config"
        success "Deployed: i3 config"
    else
        warn "Missing: i3 config"
    fi
    
    # Deploy i3 scripts
    if [[ -d "$DOTFILES_DIR/config/i3/scripts" ]]; then
        cp "$DOTFILES_DIR/config/i3/scripts/"* "$CONFIG_DIR/i3/scripts/" 2>/dev/null || true
        chmod +x "$CONFIG_DIR/i3/scripts/"* 2>/dev/null || true
        success "Deployed: i3 scripts"
    fi
    
    # Deploy i3blocks config
    if [[ -f "$DOTFILES_DIR/config/i3blocks/config" ]]; then
        cp "$DOTFILES_DIR/config/i3blocks/config" "$CONFIG_DIR/i3blocks/config"
        success "Deployed: i3blocks config"
    else
        warn "Missing: i3blocks config"
    fi
    
    # Deploy Alacritty config
    if [[ -f "$DOTFILES_DIR/config/alacritty/alacritty.toml" ]]; then
        cp "$DOTFILES_DIR/config/alacritty/alacritty.toml" "$CONFIG_DIR/alacritty/alacritty.toml"
        success "Deployed: Alacritty config"
    else
        warn "Missing: Alacritty config"
    fi
    
    # Deploy Picom config
    if [[ -f "$DOTFILES_DIR/config/picom/picom.conf" ]]; then
        cp "$DOTFILES_DIR/config/picom/picom.conf" "$CONFIG_DIR/picom/picom.conf"
        success "Deployed: Picom config"
    else
        warn "Missing: Picom config"
    fi
    
    # Deploy Neovim config
    if [[ -f "$DOTFILES_DIR/config/nvim/init.lua" ]]; then
        cp "$DOTFILES_DIR/config/nvim/init.lua" "$CONFIG_DIR/nvim/init.lua"
        success "Deployed: Neovim config"
    else
        warn "Missing: Neovim config"
    fi
    
    # Deploy lf config
    if [[ -d "$DOTFILES_DIR/config/lf" ]]; then
        cp "$DOTFILES_DIR/config/lf/"* "$CONFIG_DIR/lf/" 2>/dev/null || true
        chmod +x "$CONFIG_DIR/lf/preview.sh" 2>/dev/null || true
        success "Deployed: lf config"
    fi
    
    # Deploy Rofi config
    if [[ -f "$DOTFILES_DIR/config/rofi/config.rasi" ]]; then
        cp "$DOTFILES_DIR/config/rofi/config.rasi" "$CONFIG_DIR/rofi/config.rasi"
        success "Deployed: Rofi config"
    else
        warn "Missing: Rofi config"
    fi
    
    # Deploy Dunst config
    if [[ -f "$DOTFILES_DIR/config/dunst/dunstrc" ]]; then
        cp "$DOTFILES_DIR/config/dunst/dunstrc" "$CONFIG_DIR/dunst/dunstrc"
        success "Deployed: Dunst config"
    else
        warn "Missing: Dunst config"
    fi
    
    # Deploy Zathura config
    if [[ -f "$DOTFILES_DIR/config/zathura/zathurarc" ]]; then
        cp "$DOTFILES_DIR/config/zathura/zathurarc" "$CONFIG_DIR/zathura/zathurarc"
        success "Deployed: Zathura config"
    else
        warn "Missing: Zathura config"
    fi
    
    # Deploy GTK config
    if [[ -f "$DOTFILES_DIR/config/gtk-3.0/settings.ini" ]]; then
        cp "$DOTFILES_DIR/config/gtk-3.0/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
        success "Deployed: GTK config"
    else
        warn "Missing: GTK config"
    fi
    
    # Deploy wallpapers
    if [[ -d "$DOTFILES_DIR/wallpapers" ]] && [[ -n "$(ls -A "$DOTFILES_DIR/wallpapers" 2>/dev/null)" ]]; then
        cp "$DOTFILES_DIR/wallpapers/"* "$CONFIG_DIR/wallpapers/" 2>/dev/null || true
        success "Deployed: Wallpapers"
    fi
    
    # Symlink shell configs
    if [[ -f "$DOTFILES_DIR/shell/.zshrc" ]]; then
        ln -sf "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
        success "Symlinked: .zshrc"
    else
        warn "Missing: .zshrc"
    fi
    
    if [[ -f "$DOTFILES_DIR/shell/.zsh_aliases" ]]; then
        ln -sf "$DOTFILES_DIR/shell/.zsh_aliases" "$HOME/.zsh_aliases"
        success "Symlinked: .zsh_aliases"
    else
        warn "Missing: .zsh_aliases"
    fi
    
    # Create monitor.sh template if not exists
    if [[ ! -f "$HOME/.screenlayout/monitor.sh" ]]; then
        cat > "$HOME/.screenlayout/monitor.sh" << 'MONITOR_EOF'
#!/bin/bash
# Monitor layout script - customize with arandr
# Default: Single display (auto-detect)
xrandr --auto
MONITOR_EOF
        chmod +x "$HOME/.screenlayout/monitor.sh"
        success "Created: monitor.sh template"
    fi
    
    # Create .xinitrc if not exists
    if [[ ! -f "$HOME/.xinitrc" ]]; then
        cat > "$HOME/.xinitrc" << 'XINITRC_EOF'
#!/bin/sh
# Source system profile
[ -f /etc/profile ] && . /etc/profile
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# Set keyboard repeat rate
xset r rate 300 50 &

# Start i3
exec i3
XINITRC_EOF
        chmod +x "$HOME/.xinitrc"
        success "Created: .xinitrc"
    fi
    
    success "Configuration deployment complete"
}

# ============================================================================
# SHELL CONFIGURATION
# ============================================================================

configure_shell() {
    header "Configuring Shell"
    
    # Check if zsh exists
    if ! command -v zsh &> /dev/null; then
        warn "Zsh not found. Install packages first."
        return 1
    fi
    
    # Set Zsh as default shell
    if [[ "$SHELL" != "/bin/zsh" && "$SHELL" != "/usr/bin/zsh" ]]; then
        log "Setting Zsh as default shell..."
        if chsh -s "$(which zsh)"; then
            success "Zsh set as default shell (takes effect on next login)"
        else
            warn "Failed to change shell. You may need to run: chsh -s $(which zsh)"
        fi
    else
        log "Zsh is already the default shell"
    fi
}

# ============================================================================
# KEYBOARD SHORTCUTS REFERENCE
# ============================================================================

print_shortcuts() {
    header "Keyboard Shortcuts Reference"
    
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════╗
║                         KEYBOARD SHORTCUTS                                ║
╠══════════════════════════════════════════════════════════════════════════╣
║  CORE                                                                     ║
║  ────                                                                     ║
║  Mod+Return         Terminal (Alacritty)                                 ║
║  Mod+Shift+Return   Floating terminal                                    ║
║  Mod+c              Close window                                         ║
║  Mod+Shift+c        Reload i3 config                                     ║
║  Mod+Shift+r        Restart i3                                           ║
║  Mod+Shift+e        Power menu                                           ║
║  Mod+l              Lock screen                                          ║
║                                                                          ║
║  NAVIGATION                                                               ║
║  ──────────                                                               ║
║  Mod+j/k/b/o        Focus left/down/up/right                             ║
║  Mod+Shift+j/k/b/o  Move window left/down/up/right                       ║
║  Mod+arrows         Focus (arrow keys)                                   ║
║  Mod+Shift+arrows   Move window (arrow keys)                             ║
║  Mod+h              Split horizontal                                     ║
║  Mod+v              Split vertical                                       ║
║  Mod+f              Fullscreen                                           ║
║  Mod+s              Stack layout                                         ║
║  Mod+g              Tabbed layout                                        ║
║  Mod+e              Toggle split                                         ║
║  Mod+Space          Focus floating                                       ║
║  Mod+Shift+Space    Toggle floating                                      ║
║                                                                          ║
║  APPLICATIONS                                                             ║
║  ────────────                                                             ║
║  F9                 App launcher (Rofi)                                  ║
║  F10                Window switcher                                      ║
║  Mod+n              File manager (lf)                                    ║
║  Mod+Shift+f        File manager (Thunar)                                ║
║  Mod+Shift+m        System monitor (btop)                                ║
║  Mod+Shift+b        Browser (Firefox)                                    ║
║  Mod+p              Password manager (pass)                              ║
║  Mod+g              Projects folder                                      ║
║  Print              Screenshot                                           ║
║                                                                          ║
║  CONFIG EDITING                                                           ║
║  ──────────────                                                           ║
║  Mod+F1             Edit i3 config                                       ║
║  Mod+F2             Edit Alacritty config                                ║
║  Mod+F3             Edit .zshrc                                          ║
║                                                                          ║
║  WORKSPACES                                                               ║
║  ──────────                                                               ║
║  Mod+1-9,0          Switch to workspace                                  ║
║  Mod+Shift+1-9,0    Move window to workspace                             ║
║                                                                          ║
║  HARDWARE                                                                 ║
║  ────────                                                                 ║
║  XF86AudioRaiseVolume    Volume up                                       ║
║  XF86AudioLowerVolume    Volume down                                     ║
║  XF86AudioMute           Toggle mute                                     ║
║  XF86MonBrightnessUp     Brightness up                                   ║
║  XF86MonBrightnessDown   Brightness down                                 ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
}

# ============================================================================
# MAIN INSTALLATION
# ============================================================================

full_install() {
    header "Full Installation"
    
    check_os
    show_bios_warning
    backup_configs
    enable_repositories
    install_packages
    install_fonts
    configure_hardware
    deploy_configs
    configure_shell
    print_shortcuts
    
    header "Installation Complete!"
    
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Installation completed successfully!                         ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║  Next steps:                                                  ║${NC}"
    echo -e "${GREEN}║  1. Log out and log back in (for shell change)              ║${NC}"
    echo -e "${GREEN}║  2. Run 'startx' to start i3                                 ║${NC}"
    echo -e "${GREEN}║  3. Use Mod+Shift+c to reload config after changes          ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  Backup location: ${BACKUP_DIR}${NC}"
    echo -e "${GREEN}║  Log file: ${LOG_FILE}${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

main() {
    # Initialize log file
    touch "$LOG_FILE" 2>/dev/null || true
    
    check_root
    
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --backup)
            check_os
            backup_configs
            success "Backup complete: $BACKUP_DIR"
            ;;
        --configs-only)
            check_os
            backup_configs
            deploy_configs
            configure_shell
            print_shortcuts
            success "Configs deployed successfully!"
            ;;
        --packages-only)
            check_os
            enable_repositories
            install_packages
            install_fonts
            success "Packages installed successfully!"
            ;;
        --hardware)
            check_os
            configure_hardware
            success "Hardware configured successfully!"
            ;;
        "")
            full_install
            ;;
        *)
            error "Unknown option: $1. Use --help for usage information."
            ;;
    esac
}

main "$@"
