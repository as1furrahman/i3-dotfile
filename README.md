# Dotfiles - Debian 13 + i3 (Zenbook S 13 OLED)

Minimal, production-ready dotfiles for Debian 13 (Trixie) with i3 window manager, optimized for Asus Zenbook S 13 OLED (UM5302TA) with a terminal-centric workflow.

## Quick Start

```bash
git clone https://github.com/as1furrahman/i3-dotfile.git
cd i3-dotfile
chmod +x install.sh
./install.sh
# Log out, log back in
startx
```

## Hardware Requirements

### Asus Zenbook S 13 OLED (UM5302TA)
- **CPU**: AMD Ryzen 7 6800U (8-core)
- **Display**: 2.8K OLED (2880x1800)
- **Audio**: Cirrus Logic CS35L41 (requires Pipewire)
- **RAM**: 16-32GB

### BIOS Settings (Required)
| Setting | Value | Reason |
|---------|-------|--------|
| Secure Boot | **DISABLED** | Third-party drivers |

## Features

- **Zero bloat**: ~400MB RAM idle, <5GB disk
- **OLED-optimized**: Battery-friendly compositor, burn-in protection via auto-lock
- **Terminal-first**: Alacritty + Zsh + Neovim stack
- **Tokyo Night theme**: Consistent across all applications
- **Pipewire audio**: Proper CS35L41 support
- **TLP battery optimization**: Ryzen 6800U profiles

## Installation Options

```bash
./install.sh                 # Full installation
./install.sh --backup        # Backup configs only
./install.sh --configs-only  # Deploy configs (no packages)
./install.sh --packages-only # Install packages only
./install.sh --hardware      # Hardware config only
```

## Keyboard Shortcuts

### Core
| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal |
| `Mod+Shift+Return` | Floating terminal |
| `Mod+c` | Close window |
| `Mod+Shift+c` | Reload config |
| `Mod+Shift+r` | Restart i3 |
| `Mod+Shift+e` | Power menu |
| `Mod+l` | Lock screen |

### Navigation
| Key | Action |
|-----|--------|
| `Mod+j/k/b/o` | Focus left/down/up/right |
| `Mod+Shift+j/k/b/o` | Move window |
| `Mod+arrows` | Focus (arrow keys) |
| `Mod+h` | Split horizontal |
| `Mod+v` | Split vertical |
| `Mod+f` | Fullscreen |
| `Mod+s` | Stack layout |
| `Mod+g` | Tabbed layout |
| `Mod+e` | Toggle split |
| `Mod+Space` | Focus floating |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+r` | Resize mode |

### Applications
| Key | Action |
|-----|--------|
| `F9` | App launcher (Rofi) |
| `F10` | Window switcher |
| `Mod+n` | File manager (lf) |
| `Mod+Shift+f` | File manager (Thunar) |
| `Mod+Shift+m` | System monitor (btop) |
| `Mod+Shift+b` | Browser (Firefox) |
| `Mod+p` | Password manager |
| `Mod+g` | Projects folder |
| `Print` | Screenshot |

### Config Editing
| Key | Action |
|-----|--------|
| `Mod+F1` | Edit i3 config |
| `Mod+F2` | Edit Alacritty config |
| `Mod+F3` | Edit .zshrc |

### Workspaces
| Key | Action |
|-----|--------|
| `Mod+1-9,0` | Switch workspace |
| `Mod+Shift+1-9,0` | Move to workspace |

### Hardware (Fn Keys)
| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

## Customization

### Colors (Tokyo Night)
Edit `~/.config/i3/config`:
```bash
set $bg         #1a1b26
set $fg         #c0caf5
set $accent     #7aa2f7
set $red        #f7768e
set $green      #9ece6a
set $yellow     #e0af68
```

### Fonts
Edit font settings in:
- `~/.config/i3/config`
- `~/.config/alacritty/alacritty.toml`
- `~/.config/rofi/config.rasi`

### Gaps
Edit `~/.config/i3/config`:
```bash
gaps inner 5
gaps outer 5
```

## Troubleshooting

### Audio (Pipewire/CS35L41)
```bash
# Check Pipewire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart Pipewire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Test audio
speaker-test -c2
```

### Brightness Keys Not Working
```bash
# Add user to video group
sudo usermod -aG video $USER
# Log out and back in
```

### Battery Drain
```bash
# Check TLP status
sudo tlp-stat -s

# Run powertop
sudo powertop --auto-tune
```

### Font Issues
```bash
# Rebuild font cache
fc-cache -fv

# List fonts
fc-list | grep -i cascadia
```

## Directory Structure

```
dotfiles/
├── install.sh              # Main installer
├── README.md
├── config/
│   ├── i3/config           # i3 window manager
│   ├── i3/scripts/         # Power menu, lock, screenshot
│   ├── i3blocks/config     # Status bar
│   ├── alacritty/          # Terminal
│   ├── picom/              # Compositor
│   ├── nvim/               # Neovim
│   ├── lf/                 # File manager
│   ├── rofi/               # Launcher
│   ├── dunst/              # Notifications
│   ├── zathura/            # PDF viewer
│   └── gtk-3.0/            # GTK theme
├── shell/
│   ├── .zshrc
│   └── .zsh_aliases
├── scripts/
│   ├── hardware_setup.sh
│   ├── package_install.sh
│   ├── backup.sh
│   └── monitor.sh
├── fonts/install_fonts.sh
└── wallpapers/
```

## System Statistics

| Metric | Value |
|--------|-------|
| RAM (idle) | ~400MB |
| Disk usage | <5GB |
| Boot time | ~15s |

## License

MIT License - see [LICENSE](LICENSE)
