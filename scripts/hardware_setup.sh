#!/usr/bin/env bash
# Hardware setup for Asus Zenbook S 13 OLED (UM5302TA)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo "==========================================="
echo "  Zenbook S 13 OLED Hardware Setup"
echo "==========================================="

# Check if running as regular user
[[ $EUID -eq 0 ]] && error "Run as regular user, not root"

# Pipewire check
log "Checking Pipewire..."
if systemctl --user is-active pipewire &>/dev/null; then
    log "Pipewire is running"
else
    warn "Pipewire not running. Starting..."
    systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
fi

# Remove PulseAudio if present
if dpkg -l pulseaudio &>/dev/null 2>&1; then
    log "Removing PulseAudio..."
    sudo apt remove -y pulseaudio pulseaudio-utils || true
fi

# TLP
log "Configuring TLP..."
if command -v tlp &>/dev/null; then
    sudo systemctl enable tlp || true
    sudo systemctl start tlp || true
    log "TLP enabled"
else
    warn "TLP not installed"
fi

# Swappiness
log "Configuring swappiness..."
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf 2>/dev/null; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
fi

# Video group for brightness
if ! groups | grep -q video; then
    log "Adding user to video group..."
    sudo usermod -aG video "$USER"
    warn "Log out and back in for brightness control"
fi

# Audio test
log "Testing audio (2 second test)..."
if command -v speaker-test &>/dev/null; then
    timeout 2 speaker-test -c2 -t wav &>/dev/null || true
    log "Audio test complete"
fi

echo ""
echo "==========================================="
echo "  Hardware setup complete!"
echo "==========================================="
