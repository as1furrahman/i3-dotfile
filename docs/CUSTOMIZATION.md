# Customization Guide

## Appearance

### Colors
The system uses the **Tokyo Night** color scheme.
- **i3**: Edit `~/.config/i3/config` (Variables at the top).
- **Alacritty**: Edit `~/.config/alacritty/alacritty.toml`.
- **Rofi**: Edit `~/.config/rofi/config.rasi` and `powermenu.rasi`.
- **GTK**: Edit `~/.config/gtk-3.0/settings.ini`.

### Wallpaper
To change the wallpaper:
1. Place image in `~/wallpapers/`.
2. Edit `~/.config/i3/scripts/wallpaper_manager.sh` and change `DEFAULT_WALL`.
3. Or simply overwrite `~/wallpapers/default.png`.

### Fonts
Primary font is **Cascadia Code**.
Fallback is **JetBrains Mono** or **Nerd Fonts**.
To change:
- Edit `~/.config/i3/config` (`font pango:...`)
- Edit `~/.config/alacritty/alacritty.toml`
- Edit `~/.config/rofi/config.rasi`

## Gaps and Borders
Edit `~/.config/i3/config`:
```i3
gaps inner 5
gaps outer 5
bindsym $mod+z gaps outer current plus 5
bindsym $mod+Shift+z gaps outer current minus 5
```

## Adding Autostart Apps
Add to `~/.config/i3/config`:
```i3
exec --no-startup-id my-application
```
