# Installation Guide

## Quick Start from Fresh Debian Install

1. **Install Debian 13 (Trixie)** minimal text-only install.
2. Login as regular user.
3. Clone and install:
   ```bash
   sudo apt install git -y
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   chmod +x install.sh
   ./install.sh
   ```

## Installation Options

Run `./install.sh` to see the interactive menu:

1. **Full Installation**: Recommended for fresh installs. Doing everything.
2. **Packages Only**: Installs `apt` packages, fonts, and dependencies.
3. **Configs Only**: Symlinks/copies dotfiles to `~/.config`.
4. **Hardware Setup**: Configures TLP, Pipewire, and Zenbook specifics.
5. **Post-Install**: Sets up directories and Git.
6. **Backup**: Backs up current `~/.config` to `~/.config_backup_TIMESTAMP`.

## Requirements

- **OS**: Debian 13 (Trixie) or Sid.
- **Hardware**: Optimized for Asus Zenbook S 13 OLED (UM5302TA).
- **User**: Non-root user with `sudo` privileges.
- **Internet**: Required for package downloads.

## BIOS Settings (Critical)

- **VMD Controller**: DISABLED
- **Secure Boot**: DISABLED
- **Fast Boot**: DISABLED
