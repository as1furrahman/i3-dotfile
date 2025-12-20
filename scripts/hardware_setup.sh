#!/bin/bash
set -e

# ============================================================================
# Hardware Configuration (Asus Zenbook S 13 OLED)
# ============================================================================

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

configure_pipewire() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Configuring Pipewire Audio${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    log "Checking Pipewire status..."
    if command -v pipewire &> /dev/null; then
        # Remove PulseAudio if present
        if dpkg -l pulseaudio &> /dev/null 2>&1; then
            log " removing PulseAudio to prevent conflicts (purging)..."
            sudo apt purge -y pulseaudio >> "$LOG_FILE" 2>&1 || true
        fi
        
        # Enable Pipewire services
        log "Enabling Pipewire services..."
        systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
        success "Pipewire configured"
    else
        warn "Pipewire not installed. Skipping."
    fi
}

configure_power() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Configuring Power Management${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # TLP
    if command -v tlp &> /dev/null; then
        log "Enabling TLP..."
        sudo systemctl enable --now tlp >> "$LOG_FILE" 2>&1 || true
        success "TLP enabled"
    fi
    
    # Swappiness
    log "Configuring swappiness..."
    if ! grep -q "vm.swappiness=10" /etc/sysctl.conf 2>/dev/null; then
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
        sudo sysctl -p >> "$LOG_FILE" 2>&1 || true
        success "Swappiness set to 10"
    else
        log "Swappiness already configured"
    fi
}

hardware_report() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Hardware Status Report${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    echo "Audio Server: $(pactl info 2>/dev/null | grep "Server Name" || echo "Unknown")"
    echo "Power Mgmt:   $(systemctl is-active tlp)"
    echo "Swappiness:   $(cat /proc/sys/vm/swappiness)"
    echo ""
    log "Testing audio (5s white noise)..."
    if timeout 5s speaker-test -c2 -t pink >/dev/null 2>&1; then
        success "Audio test completed (Pink noise)"
    else
        warn "Audio test skipped or failed"
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_pipewire
    configure_power
    hardware_report
fi
