#!/bin/bash
set -e

# ============================================================================
# Package Installer
# ============================================================================

# Tokyo Night Color Palette (minimal, OLED-friendly)
TN_BLUE='\033[38;5;111m'        # #7aa2f7 - Headers
TN_MAGENTA='\033[38;5;141m'     # #bb9af7 - Section titles
TN_GREEN='\033[38;5;115m'       # #73daca - Success
TN_YELLOW='\033[38;5;179m'      # #e0af68 - Warnings
TN_RED='\033[38;5;204m'         # #f7768e - Errors
DIM='\033[2m'                   # Dim text
NC='\033[0m'                    # Reset

LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Helper Functions
log() { echo -e "${DIM}  → $1${NC}"; }
success() { echo -e "${TN_GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${TN_YELLOW}  ⚠ $1${NC}"; }
error() { echo -e "${TN_RED}  ✗ $1${NC}"; }

section_header() {
    echo ""
    echo -e "${TN_MAGENTA}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${TN_MAGENTA}│  $1${NC}"
    echo -e "${TN_MAGENTA}└─────────────────────────────────────────────────────────┘${NC}"
}

main_header() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  $1${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Package Categories (organized for progress visibility)
readonly PKG_X11_CORE=(xorg xinit dbus-x11 x11-xserver-utils x11-utils xdg-utils)
readonly PKG_X11_SESSION=(xdg-desktop-portal-gtk xcursor-themes xfonts-base adwaita-icon-theme)
readonly PKG_I3=(i3-wm i3blocks i3lock picom xss-lock)
readonly PKG_SHELL=(zsh zsh-autosuggestions zsh-syntax-highlighting)
readonly PKG_FILE_MANAGERS=(thunar thunar-archive-plugin thunar-media-tags-plugin gvfs gvfs-backends lf)
readonly PKG_EDITORS=(neovim micro geany mousepad)
readonly PKG_MONITORS=(btop)
readonly PKG_LAUNCHER=(rofi dunst libnotify-bin)
readonly PKG_APPS=(pass zathura evince mpv feh)
readonly PKG_AUDIO=(pipewire pipewire-alsa pipewire-pulse wireplumber libspa-0.2-bluetooth pavucontrol pulseaudio-utils alsa-utils)
readonly PKG_FIRMWARE=(firmware-linux firmware-linux-nonfree firmware-amd-graphics amd64-microcode firmware-sof-signed firmware-iwlwifi)
readonly PKG_SYSTEM=(bluez network-manager tlp tlp-rdw powertop)
readonly PKG_FONTS=(fonts-cascadia-code fonts-jetbrains-mono fonts-firacode fonts-noto-core fonts-noto-color-emoji fonts-liberation2 fonts-dejavu-core fonts-font-awesome)
readonly PKG_THEMES=(papirus-icon-theme arc-theme)
readonly PKG_UTILS=(dex arandr imagemagick curl wget git unzip fontconfig p7zip-full unrar maim xclip brightnessctl xinput playerctl polkitd pkexec lxpolkit acpi cheese jq fzf atool trash-cli iw)
readonly PKG_DEV=(bat ripgrep fd-find eza build-essential gfortran cmake)

enable_repositories() {
    main_header "Enabling Repositories"
    
    # Update sources.list to include non-free components
    if ! grep -q "non-free-firmware" /etc/apt/sources.list; then
        log "Adding contrib, non-free, and non-free-firmware to sources.list..."
        sudo sed -i -r 's/main( contrib)?( non-free)?/main contrib non-free non-free-firmware/' /etc/apt/sources.list
        success "Repositories updated"
    else
        log "Non-free repositories already enabled."
    fi
}

# Install a category of packages with visible progress
# Usage: install_category "Category Name" package1 package2 ...
install_category() {
    local category_name="$1"
    shift
    local packages=("$@")
    local failed=()
    local installed=0
    local skipped=0
    local total=${#packages[@]}
    
    section_header "$category_name"
    
    for pkg in "${packages[@]}"; do
        printf "${DIM}  [%d/%d]${NC} " "$((installed + skipped + 1))" "$total"
        
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "${DIM}$pkg (already installed)${NC}"
            ((skipped++))
        else
            echo -e "Installing ${TN_GREEN}$pkg${NC}..."
            if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                success "Installed $pkg"
                ((installed++))
            else
                warn "Failed: $pkg"
                failed+=("$pkg")
            fi
        fi
    done
    
    # Summary for this category
    echo ""
    if [[ ${#failed[@]} -eq 0 ]]; then
        success "$category_name complete ($installed new, $skipped existing)"
    else
        warn "$category_name: ${#failed[@]} failed - ${failed[*]}"
    fi
    
    # Return failed packages for global tracking
    echo "${failed[*]}"
}

install_packages() {
    main_header "Installing System Packages"
    
    # Store all failures
    local all_failed=()
    
    log "Updating package lists..."
    sudo apt-get update -qq >> "$LOG_FILE" 2>&1
    success "Package lists updated"
    echo ""
    
    # Install each category with visible progress
    section_header "X11 Core Components"
    for pkg in "${PKG_X11_CORE[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "X11 Session Support"
    for pkg in "${PKG_X11_SESSION[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "i3 Window Manager"
    for pkg in "${PKG_I3[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Shell Environment"
    for pkg in "${PKG_SHELL[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "File Managers"
    for pkg in "${PKG_FILE_MANAGERS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Text Editors"
    for pkg in "${PKG_EDITORS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "System Monitors"
    for pkg in "${PKG_MONITORS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Application Launcher & Notifications"
    for pkg in "${PKG_LAUNCHER[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Desktop Applications"
    for pkg in "${PKG_APPS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Audio (Pipewire)"
    for pkg in "${PKG_AUDIO[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Firmware & Drivers"
    for pkg in "${PKG_FIRMWARE[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "System Services"
    for pkg in "${PKG_SYSTEM[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Fonts"
    for pkg in "${PKG_FONTS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Icon & GTK Themes"
    for pkg in "${PKG_THEMES[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "System Utilities"
    for pkg in "${PKG_UTILS[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    section_header "Development Tools"
    for pkg in "${PKG_DEV[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log "Installing $pkg..."
            if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                warn "Failed: $pkg"; all_failed+=("$pkg")
            else
                success "$pkg"
            fi
        else
            log "$pkg (already installed)"
        fi
    done
    
    # Final summary
    echo ""
    main_header "Package Installation Summary"
    if [[ ${#all_failed[@]} -eq 0 ]]; then
        success "All packages installed successfully!"
    else
        warn "Some packages failed to install:"
        for pkg in "${all_failed[@]}"; do
            error "  • $pkg"
        done
        echo ""
        log "Check $LOG_FILE for details"
    fi
}

install_alacritty() {
    section_header "Alacritty Terminal"

    if dpkg -l "alacritty" 2>/dev/null | grep -q "^ii"; then
        success "Alacritty is already installed"
        return 0
    fi

    log "Installing Alacritty via apt..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq alacritty >> "$LOG_FILE" 2>&1; then
        success "Alacritty installed"
    else
        error "Failed to install Alacritty. Please install manually."
        return 1
    fi
}

install_fonts() {
    section_header "Additional Fonts (Cascadia Code)"
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    if ! fc-list | grep -qi "Cascadia Code"; then
         log "Downloading latest Cascadia Code from GitHub..."
         local cascadia_url="https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip"
         local cascadia_zip="/tmp/CascadiaCode.zip"
         
         if curl -fsSL -o "$cascadia_zip" "$cascadia_url"; then
             unzip -q -o "$cascadia_zip" -d /tmp/CascadiaCode
             cp /tmp/CascadiaCode/ttf/*.ttf "$fonts_dir/" 2>/dev/null || true
             cp /tmp/CascadiaCode/otf/static/*.otf "$fonts_dir/" 2>/dev/null || true
             rm -rf /tmp/CascadiaCode "$cascadia_zip"
             success "Cascadia Code installed"
         else
             warn "Download failed. Using apt version if available."
         fi
    else
         log "Cascadia Code is already installed."
    fi
    
    log "Refreshing font cache..."
    fc-cache -fv >> "$LOG_FILE" 2>&1 || true
    success "Font cache updated"
}

install_zen_browser() {
    section_header "Zen Browser (Official AppImage)"
    
    # Check if already installed
    if command -v zen-browser &>/dev/null; then
        success "Zen Browser is already installed"
        zen-browser --version 2>/dev/null || true
        return 0
    fi
    
    # Check for zsync (required for updates)
    if ! command -v zsync &>/dev/null; then
        log "Installing zsync (required for Zen Browser updates)..."
        sudo apt-get install -y zsync >> "$LOG_FILE" 2>&1 || warn "zsync not installed (updates may not work)"
    fi
    
    log "Installing Zen Browser using official AppImage script..."
    log "Source: https://github.com/zen-browser/desktop"
    echo ""
    
    # Run official installation script
    # This script handles: download, AppImage setup, desktop integration, and PATH setup
    if bash <(curl -s https://updates.zen-browser.app/appimage.sh); then
        success "Zen Browser installed successfully!"
        echo ""
        log "The official installer has set up:"
        log "  • AppImage in ~/.local/share/appimages/"
        log "  • Desktop entry for application menu"
        log "  • Automatic updates via zsync"
        echo ""
        
        # Verify installation
        if command -v zen-browser &>/dev/null; then
            success "zen-browser command is available"
        else
            # Create symlink if not in PATH
            local ZEN_APPIMAGE
            ZEN_APPIMAGE=$(find "$HOME/.local" -name "zen*.AppImage" -type f 2>/dev/null | head -1)
            if [[ -n "$ZEN_APPIMAGE" && -f "$ZEN_APPIMAGE" ]]; then
                mkdir -p "$HOME/.local/bin"
                ln -sf "$ZEN_APPIMAGE" "$HOME/.local/bin/zen-browser"
                chmod +x "$HOME/.local/bin/zen-browser"
                success "Created zen-browser symlink in ~/.local/bin/"
                log "Make sure ~/.local/bin is in your PATH"
            fi
        fi
    else
        error "Official installer failed. Trying manual installation..."
        
        # Fallback: Manual tarball installation
        local ZEN_DIR="$HOME/.local/share/zen-browser"
        local ZEN_BIN="$HOME/.local/bin/zen-browser"
        
        mkdir -p "$ZEN_DIR" "$HOME/.local/bin"
        
        log "Downloading from GitHub releases..."
        local ZEN_URL="https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz"
        local ZEN_ARCHIVE="/tmp/zen-browser.tar.xz"
        
        if curl -fsSL -o "$ZEN_ARCHIVE" "$ZEN_URL"; then
            log "Extracting..."
            tar -xJf "$ZEN_ARCHIVE" -C "$ZEN_DIR" --strip-components=1 2>/dev/null || \
            tar -xJf "$ZEN_ARCHIVE" -C "$ZEN_DIR" 2>/dev/null
            rm -f "$ZEN_ARCHIVE"
            
            # Find and link executable
            local ZEN_EXEC="$ZEN_DIR/zen"
            [[ ! -f "$ZEN_EXEC" ]] && ZEN_EXEC=$(find "$ZEN_DIR" -maxdepth 2 -name "zen*" -type f -executable | head -1)
            
            if [[ -f "$ZEN_EXEC" ]]; then
                chmod +x "$ZEN_EXEC"
                ln -sf "$ZEN_EXEC" "$ZEN_BIN"
                success "Zen Browser installed (manual fallback)"
            else
                error "Installation failed"
                return 1
            fi
        else
            error "Download failed"
            return 1
        fi
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Support calling specific functions via command line
    if [[ "$1" == "install_zen_browser" ]]; then
        install_zen_browser
        exit $?
    fi
    
    main_header "Dotfiles Package Installer"
    echo -e "${DIM}  Log file: $LOG_FILE${NC}"
    echo ""
    
    enable_repositories
    install_packages
    install_alacritty
    install_fonts
    
    echo ""
    main_header "Installation Complete"
    success "All package installation steps finished!"
    echo ""
    echo -e "${DIM}  Note: Run './install.sh' and select option 9 to install Zen Browser${NC}"
    echo ""
fi


