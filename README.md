# Dotfiles for Debian 13 (Trixie) + i3
> Optimized for Asus Zenbook S 13 OLED (UM5302TA)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready, modular dotfiles repository designed for a minimal, terminal-centric workflow.

## Quick Install

```bash
sudo apt install git -y
git clone https://github.com/as1furrahman/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

## Features

- **Window Manager**: i3-wm with smart borders and Tokyo Night theme.
- **Terminal**: Alacritty + Zsh + Tokyo Night styling.
- **Power Management**: TLP, Pipewire, and custom sleep/lock scripts.
- **Hardware Support**: Optimized for AMD Ryzen 6800U and OLED screens.
- **Workflow**: `lf` file manager, `nvim` editor, `rofi` launcher.

## Installation

Run `./install.sh` to see the interactive menu:

1. **Full Installation**: Recommended for fresh installs.
2. **Packages Only**: Installs `apt` packages, fonts, and dependencies.
3. **Configs Only**: Deploys dotfiles to `~/.config`.
4. **Hardware Setup**: Configures TLP, Pipewire, and system optimizations.
5. **Post-Install**: Sets up directories and Git.
6. **Backup**: Backs up current `~/.config` to `~/.config_backup_TIMESTAMP`.

### BIOS Settings (Critical)
- **VMD Controller**: DISABLED
- **Secure Boot**: DISABLED
- **Fast Boot**: DISABLED

## Keyboard Shortcuts

| Keybinding | Action |
|------------|--------|
| `Mod+Return` | Open Terminal (Alacritty) |
| `Mod+Shift+Return` | Open Floating Terminal |
| `Mod+Shift+e` | Power Menu (Lock/Suspend/Reboot/etc) |
| `Mod+l` | Lock Screen |
| `Mod+c` | Close Window |
| `Mod+Shift+c` | Reload i3 Config |
| `Mod+Shift+r` | Restart i3 |
| `Mod+j/k/b/o` | Focus Left/Down/Up/Right |
| `Mod+Shift+j/k/b/o` | Move Window |
| `F9` | App Launcher (Rofi) |
| `F10` | Window Switcher |
| `Mod+n` | File Manager (lf) |
| `Mod+Shift+f` | File Manager (Thunar) |
| `Mod+w` | Browser (Firefox) |
| `Mod+p` | Password Manager (pass) |
| `Print` | Screenshot |

## Customization

### Colors & Appearance
The system uses the **Tokyo Night** color scheme.
- **i3**: Edit `~/.config/i3/config` (Variables at the top).
- **Alacritty**: Edit `~/.config/alacritty/alacritty.toml`.
- **Wallpaper**: Place images in `~/wallpapers/` and edit `~/.config/i3/scripts/wallpaper_manager.sh`.

### Fonts
Primary font is **Cascadia Code**. Fallback is **Nerd Fonts**.
- Configured in `i3/config`, `alacritty.toml`, and `rofi/config.rasi`.

## Troubleshooting

- **Audio**: Missing? Run `systemctl --user restart pipewire pipewire-pulse wireplumber`.
- **Brightness**: Ensure your user is in the `video` group: `sudo usermod -aG video $USER`.
- **Monitors**: Run `arandr` to configure and save as `~/.screenlayout/monitor.sh`.

## License

MIT License. See [LICENSE](LICENSE) for details.
