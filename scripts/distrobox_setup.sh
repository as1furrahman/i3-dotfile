#!/bin/bash
set -e

# ============================================================================
# Distrobox Container Setup
# ============================================================================

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

create_containers() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Creating Distrobox Containers${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    if ! command -v distrobox &> /dev/null; then
        echo "Distrobox not found. Please install it first."
        exit 1
    fi

    # Container 1: Thesis (Ubuntu 24.04)
    log "Creating 'thesis' container (Ubuntu 24.04)..."
    distrobox create --name thesis --image ubuntu:24.04 --yes || true
    success "Created 'thesis'"

    # Container 2: MLAI (Arch Linux)
    log "Creating 'mlai' container (Arch Linux)..."
    distrobox create --name mlai --image archlinux:latest --yes || true
    success "Created 'mlai'"

    # Container 3: MATLAB (Ubuntu 22.04)
    log "Creating 'matlab' container (Ubuntu 22.04)..."
    distrobox create --name matlab --image ubuntu:22.04 --yes || true
    success "Created 'matlab'"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_containers
fi
