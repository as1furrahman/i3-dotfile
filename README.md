# Polished Dotfiles for Debian 13 (Trixie) + i3
> **Minimal. Rock Solid. Fully Tokyo Night.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-ready, highly polished dotfiles repository designed for a strictly minimal, keyboard-centric workflow. 
Optimized for **Debian 13 (Trixie)** with specific tweaks for the **Asus Zenbook S 13 OLED** (but works on any generic hardware).

## ✨ Features

- **🎨 Fully Themed**: Consistent **Tokyo Night** theme across i3, GTK, Icons, Neovim, Rofi, and Alacritty.
- **💎 Polished UX**: `picom` with dual-kawase blur, rounded corners, and smooth fading.
- **🛠️ Rock Solid Stability**: Includes `amd64-microcode` and safe defaults to prevent freezes on Ryzen systems.
- **🚀 Minimal & Fast**: zero bloat. No `snap`, `flatpak`, or redundant apps.
    - **Editor**: Neovim (with `lazy.nvim` + `tokyonight.nvim`).
    - **Files**: `lf` (terminal) + `thunar` (GUI).
    - **Terminal**: Alacritty + Zsh (custom prompt).
- **🔋 Zenbook Optimized**: Hardware scripts for OLED brightness, keyboard backlight, and power management (TLP).

## 📥 Quick Install

1. **Clone & Run**:
   ```bash
   sudo apt install git -y
   git clone https://github.com/as1furrahman/i3-dotfile.git
   cd i3-dotfile
   chmod +x install.sh
   ./install.sh
   ```

2. **Select "Full Installation"**: This will automatically:
   - Install core packages (removing bloat).
   - Fetch and install the Tokyo Night GTK/Icon themes.
   - Symlink all configurations.
   - Set up hardware optimizations.

3. **Reboot**: Enjoy your new system.

## ⌨️ keybindings

| Keybinding | Action |
|------------|--------|
| `Mod+Return` | Open Terminal (Alacritty) |
| `Mod+Shift+Return` | Open Floating Terminal |
| `Mod+d` | App Launcher (Rofi) |
| `Mod+w` | Browser (Firefox) |
| `Mod+n` | File Manager (lf in terminal) |
| `Mod+Shift+f` | File Manager (Thunar) |
| `Mod+Shift+q` | Close Window |
| `Mod+Shift+e` | Power Menu |
| `Mod+Shift+r` | Restart i3 |
| `F12` | AI Assistant |

## 🛠️ Customization

- **Theme**: Assets are in `~/.local/share/themes` and `~/.local/share/icons`.
- **Wallpaper**: `~/.config/i3/scripts/wallpaper_manager.sh` handles backgrounds.
- **Neovim**: `~/.config/nvim/init.lua` uses `lazy.nvim`. It installs plugins on first run.

## 📦 What's Included?

- **Core**: `i3-wm`, `picom` (glx/blur), `dunst`, `rofi`.
- **Tools**: `neovim`, `thunar`, `lf`, `btop`, `ripgrep`, `eza`.
- **System**: `pipewire`, `wireplumber`, `tlp`, `amd64-microcode`.

## 📜 License

MIT License. See [LICENSE](LICENSE) for details.
