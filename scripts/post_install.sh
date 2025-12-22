#!/bin/bash
set -e

# ============================================================================
# Post-Install Setup
# ============================================================================

# Tokyo Night Color Palette
TN_BLUE='\033[38;5;111m'        # #7aa2f7 - Headers
TN_GREEN='\033[38;5;115m'       # #73daca - Success
DIM='\033[2m'                   # Dim text
NC='\033[0m'                    # Reset

log() { echo -e "${DIM}  → $1${NC}"; }
success() { echo -e "${TN_GREEN}  ✓ $1${NC}"; }

configure_system() {
    echo ""
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  System Configuration${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    
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
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${TN_BLUE}  Post-Install Checklist${NC}"
    echo -e "${TN_BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo "1. Reboot your system to apply all changes."
    echo "2. Log in and run 'startx' to launch i3."
    echo "3. Press Mod+Shift+?, check docs, or read README for help."
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_system
    post_install_checklist
fi
