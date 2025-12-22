#!/bin/bash
set -e

# ============================================================================
# Package Installer
# ============================================================================

# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Packages to install
readonly PACKAGES=(
    # X11 and i3
    xorg xinit i3-wm i3blocks i3lock-fancy picom
    # X11 Session (CRITICAL for minimal Debian - provides dbus, cursor, utils)
    dbus-x11 x11-xserver-utils x11-utils xdg-utils
    xdg-desktop-portal-gtk xcursor-themes xfonts-base
    adwaita-icon-theme
    # Terminal and tools
    zsh zsh-autosuggestions zsh-syntax-highlighting
    # File managers
    thunar lf
    # System monitors
    btop
    # Editors
    neovim micro
    # Launcher and notifications
    rofi dunst clipman
    # Applications
    pass zathura evince mpv
    # Notifications
    libnotify-bin
    # Audio (Pipewire)
    pipewire pipewire-pulse wireplumber pavucontrol pulseaudio-utils
    # Firmware and drivers
    firmware-linux firmware-linux-nonfree firmware-amd-graphics amd64-microcode
    firmware-sof-signed firmware-iwlwifi
    # System
    bluez network-manager tlp tlp-rdw powertop
    # Fonts and themes
    fonts-cascadia-code fonts-jetbrains-mono fonts-firacode
    fonts-noto-core fonts-noto-color-emoji
    fonts-liberation2 fonts-dejavu-core
    fonts-font-awesome papirus-icon-theme arc-theme
    # Utilities
    dex arandr imagemagick curl wget git unzip fontconfig p7zip-full unrar
    xss-lock maim xclip brightnessctl xinput playerctl pkexec lxpolkit
    acpi cheese jq feh fzf atool trash-cli flatpak

    bat ripgrep fd-find eza build-essential gfortran cmake
)

enable_repositories() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Enabling Repositories${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # Update sources.list to include non-free components
    if ! grep -q "non-free-firmware" /etc/apt/sources.list; then
        log "Adding contrib, non-free, and non-free-firmware to sources.list..."
        sudo sed -i -r 's/main( contrib)?( non-free)?/main contrib non-free non-free-firmware/' /etc/apt/sources.list
        success "Repositories updated"
    else
        log "Non-free repositories already enabled."
    fi
}

install_packages() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Installing Packages${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    log "Updating package lists..."
    sudo apt update
    
    log "Installing packages..."
    local failed_packages=()
    
    for pkg in "${PACKAGES[@]}"; do
        if dpkg -l "$pkg" &> /dev/null 2>&1; then
            log "Already installed: $pkg"
        else
            if output=$(sudo apt install -y "$pkg" 2>&1); then
                echo "$output" >> "$LOG_FILE"
                success "Installed: $pkg"
            else
                echo "$output" >> "$LOG_FILE"
                warn "Failed to install: $pkg"
                echo -e "${RED}Error details for $pkg:${NC}"
                echo "$output" | tail -n 5 | sed 's/^/  /'
                failed_packages+=("$pkg")
            fi
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        warn "Some packages failed to install: ${failed_packages[*]}"
    else
        success "All packages installed successfully"
    fi
}

setup_flatpak() {
    # Helper to setup flatpak repo
    if ! flatpak remote-list | grep -q flathub; then
        log "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        success "Flathub repository added"
    else
        log "Flathub repository already configured"
    fi
}

install_alacritty() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Installing Alacritty Terminal${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"

    if dpkg -l "alacritty" &> /dev/null 2>&1; then
        success "Alacritty is already installed (native)"
        return 0
    fi

    log "Attempting to install Alacritty via apt..."
    if sudo apt install -y alacritty >> "$LOG_FILE" 2>&1; then
        success "Alacritty installed via apt"
    else
        warn "Failed to install Alacritty via apt. Trying Flatpak fallback..."
        
        setup_flatpak
        
        log "Installing Alacritty from Flathub..."
        if flatpak install -y flathub org.alacritty.Alacritty 2>&1 | tee -a "$LOG_FILE"; then
            success "Alacritty installed via Flatpak"
            
            # Create wrapper script
            log "Creating alacritty command wrapper..."
            sudo bash -c 'echo "#!/bin/bash" > /usr/local/bin/alacritty && echo "flatpak run org.alacritty.Alacritty \"\$@\"" >> /usr/local/bin/alacritty && chmod +x /usr/local/bin/alacritty'
            success "alacritty command created"
            
            # Ensure proper icon/desktop file if needed (optional, but good for menus)
            # Flatpak handles desktop files generally, but the wrapper ensures 'i3-sensible-terminal' or 'alacritty' command calls work.
        else
            error "Failed to install Alacritty via Flatpak as well."
            return 1
        fi
    fi
}


install_fonts() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Installing Additional Fonts${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # Manual install for latest Cascadia Code if desired, but package is often sufficient.
    # We will verify if the package version is good enough, but for "latest" from GitHub:
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Check if Cascadia is installed via apt or manually
    if ! fc-list | grep -qi "Cascadia Code"; then
         log "Downloading latest Cascadia Code from GitHub..."
         local cascadia_url="https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip"
         local cascadia_zip="/tmp/CascadiaCode.zip"
         
         if curl -fsSL -o "$cascadia_zip" "$cascadia_url"; then
             unzip -q -o "$cascadia_zip" -d /tmp/CascadiaCode
             cp /tmp/CascadiaCode/ttf/*.ttf "$fonts_dir/" 2>/dev/null || true
             cp /tmp/CascadiaCode/otf/static/*.otf "$fonts_dir/" 2>/dev/null || true
             rm -rf /tmp/CascadiaCode "$cascadia_zip"
             success "Cascadia Code installed manually"
         else
             warn "Failed to download Cascadia Code. Using apt version if available."
         fi
    else
         log "Cascadia Code is already installed."
    fi
    
    log "Refreshing font cache..."
    fc-cache -fv >> "$LOG_FILE" 2>&1 || true
    success "Font cache updated"
}

install_zen_browser() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Installing Zen Browser (via Flatpak)${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    setup_flatpak
    
    # Install Zen Browser
    log "Installing Zen Browser from Flathub..."
    if flatpak install -y flathub io.github.zen_browser.zen 2>&1 | tee -a "$LOG_FILE"; then
        success "Zen Browser installed"
        
        # Create desktop symlink for easier launching
        log "Creating zen-browser command alias..."
        sudo bash -c 'echo "#!/bin/bash" > /usr/local/bin/zen-browser && echo "flatpak run io.github.zen_browser.zen \"\$@\"" >> /usr/local/bin/zen-browser && chmod +x /usr/local/bin/zen-browser'
        success "zen-browser command created"
    else
        warn "Failed to install Zen Browser"
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enable_repositories
    install_packages
    setup_flatpak      # Setup Flatpak BEFORE Alacritty (for fallback)
    install_alacritty
    install_fonts
    install_zen_browser
fi

