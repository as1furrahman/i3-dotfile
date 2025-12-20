#!/usr/bin/env bash
# Font installation script

set -e

FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

echo "Installing fonts..."

# Cascadia Code
if [[ ! -f "$FONTS_DIR/CascadiaCode-Regular.otf" ]]; then
    echo "Downloading Cascadia Code..."
    curl -L -o /tmp/CascadiaCode.zip \
        "https://github.com/microsoft/cascadia-code/releases/download/v2404.23/CascadiaCode-2404.23.zip"
    unzip -q -o /tmp/CascadiaCode.zip -d /tmp/CascadiaCode
    cp /tmp/CascadiaCode/ttf/*.ttf "$FONTS_DIR/" 2>/dev/null || true
    cp /tmp/CascadiaCode/otf/static/*.otf "$FONTS_DIR/" 2>/dev/null || true
    rm -rf /tmp/CascadiaCode /tmp/CascadiaCode.zip
    echo "Cascadia Code installed"
else
    echo "Cascadia Code already installed"
fi

# JetBrains Mono
if [[ ! -f "$FONTS_DIR/JetBrainsMono-Regular.ttf" ]]; then
    echo "Downloading JetBrains Mono..."
    curl -L -o /tmp/JetBrainsMono.zip \
        "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
    unzip -q -o /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono
    cp /tmp/JetBrainsMono/fonts/ttf/*.ttf "$FONTS_DIR/" 2>/dev/null || true
    rm -rf /tmp/JetBrainsMono /tmp/JetBrainsMono.zip
    echo "JetBrains Mono installed"
else
    echo "JetBrains Mono already installed"
fi

# Refresh font cache
fc-cache -fv

echo "Font installation complete!"
