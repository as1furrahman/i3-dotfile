#!/bin/bash
set -e

# ============================================================================
# Post-Install Setup
# ============================================================================

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

configure_system() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  System Configuration${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # Create directories
    log "Creating user directories..."
    mkdir -p "$HOME/projects"
    mkdir -p "$HOME/wallpapers"
    mkdir -p "$HOME/.screenlayout"
    mkdir -p "$HOME/.local/bin"
    success "Directories created"
    
    # Git Configuration
    if command -v git &> /dev/null; then
        if [[ -z $(git config --global user.name) ]]; then
            echo ""
            echo "Configure Git:"
            read -r -p "  Enter Git Name: " git_name
            read -r -p "  Enter Git Email: " git_email
            
            if [[ -n "$git_name" && -n "$git_email" ]]; then
                git config --global user.name "$git_name"
                git config --global user.email "$git_email"
                git config --global core.editor "nvim"
                success "Git configured"
            fi
        else
            log "Git already configured"
        fi
    fi
    
    # Zsh default
    if [[ "$SHELL" != "/bin/zsh" && -x /bin/zsh ]]; then
        log "Changing default shell to Zsh..."
        sudo chsh -s /bin/zsh "$USER" || true
        success "Shell changed (requires re-login)"
    fi
}

post_install_checklist() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Post-Install Checklist${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo "1. Reboot your system to apply all changes."
    echo "2. Log in and run 'startx' to launch i3."
    echo "3. Press Mod+Shift+?, check docs, or read KEYBINDINGS.md for help."
    echo "4. Run 'distrobox_setup.sh' if you haven't already."
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_system
    post_install_checklist
fi
