#!/bin/bash
set -e

# ============================================================================
# Hardware Configuration (Asus Zenbook S 13 OLED - UM5302TA)
# AMD Ryzen 7 6800U + Radeon 680M + Samsung 990 Pro
# ============================================================================

# Tokyo Night Color Palette
TN_BLUE='\033[38;5;111m'        # #7aa2f7 - Headers
TN_GREEN='\033[38;5;115m'       # #73daca - Success
TN_YELLOW='\033[38;5;179m'      # #e0af68 - Warnings
DIM='\033[2m'                   # Dim text
NC='\033[0m'                    # Reset

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${DIM}  → $1${NC}"; }
success() { echo -e "${TN_GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${TN_YELLOW}  ⚠ $1${NC}"; }

install_sysctl_config() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Installing Sysctl Performance Config${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    local sysctl_src="$DOTFILES_DIR/system/performance.conf"
    local sysctl_dest="/etc/sysctl.d/99-performance.conf"
    
    if [[ -f "$sysctl_src" ]]; then
        log "Copying performance.conf to /etc/sysctl.d/..."
        sudo cp "$sysctl_src" "$sysctl_dest"
        sudo sysctl -p "$sysctl_dest" >> "$LOG_FILE" 2>&1 || true
        success "Sysctl config installed"
    else
        warn "performance.conf not found at $sysctl_src"
    fi
}

configure_tlp() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Configuring TLP Power Management (AMD Ryzen 7 6800U)${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # Mask power-profiles-daemon to prevent conflicts
    if systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
        log "Stopping and masking power-profiles-daemon (conflicts with TLP)..."
        sudo systemctl stop power-profiles-daemon >> "$LOG_FILE" 2>&1 || true
        sudo systemctl mask power-profiles-daemon >> "$LOG_FILE" 2>&1 || true
        success "power-profiles-daemon masked"
    fi
    
    # Install TLP config
    local tlp_src="$DOTFILES_DIR/system/tlp.conf"
    local tlp_dest="/etc/tlp.d/00-zenbook.conf"
    
    if [[ -f "$tlp_src" ]]; then
        log "Installing custom TLP config for Zenbook..."
        sudo mkdir -p /etc/tlp.d
        sudo cp "$tlp_src" "$tlp_dest"
        success "TLP config installed to $tlp_dest"
    else
        warn "tlp.conf not found at $tlp_src"
    fi
    
    # Enable TLP
    if command -v tlp &> /dev/null; then
        log "Enabling TLP service..."
        sudo systemctl enable --now tlp >> "$LOG_FILE" 2>&1 || true
        sudo tlp start >> "$LOG_FILE" 2>&1 || true
        success "TLP enabled"
    fi
    
    # Add amd_pstate=passive to GRUB if not present
    local grub_file="/etc/default/grub"
    if [[ -f "$grub_file" ]]; then
        if ! grep -q "amd_pstate=passive" "$grub_file"; then
            log "Adding amd_pstate=passive to GRUB for lower idle power..."
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 amd_pstate=passive"/' "$grub_file"
            sudo update-grub >> "$LOG_FILE" 2>&1 || true
            success "GRUB updated with amd_pstate=passive (reboot required)"
        else
            log "amd_pstate=passive already in GRUB config"
        fi
    fi
}

configure_pipewire() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Configuring Pipewire Audio${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    log "Checking Pipewire status..."
    if ! command -v pipewire &> /dev/null; then
        warn "Pipewire not installed. Skipping."
        return 1
    fi
    
    # Ensure user is in audio group
    if ! groups "$USER" | grep -q audio; then
        log "Adding user to audio group..."
        sudo usermod -aG audio "$USER"
        success "User added to audio group (re-login required for full effect)"
    fi
    
    # Remove PulseAudio if present (conflicts with Pipewire)
    if dpkg -l pulseaudio 2>/dev/null | grep -q "^ii"; then
        log "Removing PulseAudio to prevent conflicts..."
        sudo apt purge -y pulseaudio >> "$LOG_FILE" 2>&1 || true
    fi
    
    # Install critical audio packages (pipewire-alsa is essential!)
    log "Installing audio bridge packages..."
    sudo apt install -y pipewire-alsa libspa-0.2-bluetooth alsa-utils >> "$LOG_FILE" 2>&1 || true
    
    # Enable Pipewire socket activation (starts automatically with user session)
    # This is what makes audio work with startx on minimal Debian
    log "Enabling Pipewire socket activation..."
    systemctl --user enable pipewire.socket pipewire-pulse.socket 2>/dev/null || true
    systemctl --user enable wireplumber.service 2>/dev/null || true
    
    # Start services now
    log "Starting Pipewire services..."
    systemctl --user start pipewire.socket pipewire-pulse.socket 2>/dev/null || true
    systemctl --user start wireplumber.service 2>/dev/null || true
    
    # Wait for wireplumber to discover devices
    log "Waiting for audio devices..."
    sleep 2
    
    # Restart wireplumber to pick up ALSA devices
    systemctl --user restart wireplumber.service 2>/dev/null || true
    sleep 1
    
    # Check if we have real audio devices (not just Dummy)
    local SINK_COUNT
    SINK_COUNT=$(wpctl status 2>/dev/null | grep -c "vol:" || echo "0")
    
    if [ "$SINK_COUNT" -gt 0 ]; then
        # Set default volume and unmute
        log "Setting default audio levels..."
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null || true
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.6 2>/dev/null || true
        
        # Show detected devices
        local DEFAULT_SINK
        DEFAULT_SINK=$(wpctl status 2>/dev/null | grep -A5 "Sinks:" | grep "\*" | sed 's/.*\. //' | cut -d'[' -f1 | xargs)
        success "Audio configured: $DEFAULT_SINK"
    else
        warn "No audio sinks detected. You may need to reboot."
    fi
    
    success "Pipewire configured for startx autostart"
}

hardware_report() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Hardware Status Report${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    local audio_server="Unknown"
    if command -v pactl &>/dev/null; then
        audio_server=$(pactl info 2>/dev/null | grep "Server Name" | cut -d: -f2 | xargs || echo "Unknown")
    elif command -v wpctl &>/dev/null; then
        audio_server=$(wpctl status | grep "PipeWire" | head -n1 | xargs || echo "PipeWire (wpctl)")
    fi
    echo "Audio Server: $audio_server"
    echo "Power Mgmt:   $(systemctl is-active tlp 2>/dev/null || echo 'unknown')"
    echo "Swappiness:   $(cat /proc/sys/vm/swappiness 2>/dev/null || echo 'unknown')"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_sysctl_config
    configure_tlp
    configure_pipewire
    hardware_report
fi

