#!/usr/bin/env bash
# Package installation script for Debian 13

set -e

PACKAGES=(
    xorg xinit i3-wm i3blocks i3lock suckless-tools
    alacritty picom feh xautolock maim xclip brightnessctl
    thunar lf btop htop neovim micro rofi dunst clipman
    zsh zsh-autosuggestions zsh-syntax-highlighting
    pass zathura firefox-esr evince
    pipewire pipewire-pulse wireplumber pavucontrol
    firmware-linux firmware-linux-nonfree firmware-amd-graphics
    firmware-sof-signed firmware-iwlwifi
    bluez network-manager tlp tlp-rdw powertop
    fonts-noto-color-emoji papirus-icon-theme arc-theme
    dex arandr imagemagick curl wget git unzip
)

echo "==========================================="
echo "  Installing packages..."
echo "==========================================="

# Update sources
sudo apt update

# Install packages
for pkg in "${PACKAGES[@]}"; do
    if dpkg -l "$pkg" &>/dev/null; then
        echo "[SKIP] $pkg already installed"
    else
        echo "[INSTALL] $pkg"
        sudo apt install -y "$pkg" || echo "[FAIL] $pkg"
    fi
done

echo ""
echo "Package installation complete!"
