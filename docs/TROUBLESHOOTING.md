# Troubleshooting

## Audio Issues (Pipewire)
If audio is missing:
1. Check status: `systemctl --user status pipewire`
2. Restart: `systemctl --user restart pipewire pipewire-pulse wireplumber`
3. Check mixer: `pavucontrol`
4. Ensure user is in `audio` group (though Pipewire handles this differently now).

## Brightness Keys Not Working
Ensure you are in the `video` group:
```bash
sudo usermod -aG video $USER
```
Re-login is required.

## Lock Screen Not Working
If `Mod+l` fails:
1. Ensure `maim` and `i3lock` are installed.
2. Run `~/.config/i3/scripts/blur-lock.sh` manually in terminal to see errors.

## Distrobox Issues
If containers fail to create:
1. Ensure `podman` is installed.
2. Check `podman info`.
3. Try regular `distrobox create` command to see output.

## Monitors/Displays
If external monitor is not detected:
1. Run `arandr` to configure graphically.
2. Save layout as `~/.screenlayout/monitor.sh`.
