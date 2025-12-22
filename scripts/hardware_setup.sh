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
    if command -v pipewire &> /dev/null; then
        # Remove PulseAudio if present
        if dpkg -l pulseaudio &> /dev/null 2>&1; then
            log "Removing PulseAudio to prevent conflicts..."
            sudo apt purge -y pulseaudio >> "$LOG_FILE" 2>&1 || true
        fi
        
        # Install utils
        log "Installing audio utilities..."
        sudo apt install -y pulseaudio-utils alsa-utils wireplumber pipewire-pulse >> "$LOG_FILE" 2>&1 || true

        # Enable Pipewire services
        log "Enabling Pipewire services..."
        systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
        
        # Ensure audio is unmuted and has volume
        log "Setting default volume..."
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null || true
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.6 2>/dev/null || true
        
        success "Pipewire configured"
    else
        warn "Pipewire not installed. Skipping."
    fi
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

