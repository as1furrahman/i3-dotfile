#!/usr/bin/env bash
# Backup existing configurations

set -e

BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

CONFIGS=(
    "$HOME/.config/i3"
    "$HOME/.config/i3blocks"
    "$HOME/.config/alacritty"
    "$HOME/.config/picom"
    "$HOME/.config/nvim"
    "$HOME/.config/lf"
    "$HOME/.config/rofi"
    "$HOME/.config/dunst"
    "$HOME/.config/zathura"
    "$HOME/.config/gtk-3.0"
    "$HOME/.zshrc"
    "$HOME/.zsh_aliases"
)

echo "==========================================="
echo "  Backing up configurations"
echo "  Destination: $BACKUP_DIR"
echo "==========================================="

mkdir -p "$BACKUP_DIR"

count=0
for config in "${CONFIGS[@]}"; do
    if [[ -e "$config" ]]; then
        cp -r "$config" "$BACKUP_DIR/"
        echo "[OK] $(basename "$config")"
        ((count++))
    fi
done

echo ""
echo "Backed up $count configuration(s) to $BACKUP_DIR"
