# Dotfiles for Debian 13 (Trixie) + i3
> Optimized for Asus Zenbook S 13 OLED (UM5302TA)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready, modular dotfiles repository designed for a minimal, terminal-centric workflow.

## Quick Install

```bash
sudo apt install git -y
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

## Features

- **Window Manager**: i3-gaps with smart borders and Tokyo Night theme.
- **Terminal**: Alacritty (GPU-accelerated) + Zsh + Powerlevel10k styling.
- **Power Management**: TLP, Pipewire, and custom sleep/lock scripts.
- **Hardware Support**: Optimized for AMD Ryzen 6800U and OLED screens (burn-in protection).
- **Workflow**: `lf` file manager, `nvim` editor, `rofi` launcher.
- **Containers**: Distrobox setup for Thesis (Ubuntu), ML/AI (Arch), and Legacy (Ubuntu 22.04).

## Structure

- `install.sh`: Interactive menu-driven installer.
- `config/`: Configuration files (symlinked to `~/.config`).
- `scripts/`: Modular setup scripts.
- `docs/`: Detailed documentation.

## Documentation

- [Installation Guide](docs/INSTALL.md)
- [Keyboard Shortcuts](docs/KEYBINDINGS.md)
- [Customization](docs/CUSTOMIZATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Icons Reference](docs/ICONS.md)

## Screenshots

*(Add screenshots here)*

## License

MIT License. See [LICENSE](LICENSE) for details.
