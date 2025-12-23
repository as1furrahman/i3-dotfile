#!/bin/sh

# ============================================================================
# .xinitrc - X Session Initialization
# Optimized for minimal Debian 13 + i3
# ============================================================================

# Merge X resources (POSIX compatible)
if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

# Load X keymap (if available)
if [ -f "$HOME/.Xmodmap" ]; then
    xmodmap "$HOME/.Xmodmap"
fi

# Start D-Bus session (CRITICAL for minimal Debian without display manager)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
    export DBUS_SESSION_BUS_ADDRESS
fi

# XDG Runtime Directory (required for Pipewire)
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    if [ ! -d "$XDG_RUNTIME_DIR" ]; then
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
    fi
fi

# HiDPI Scaling for 2.8K OLED (1.50x for better readability on 13.3" 2880x1800)
export GDK_SCALE=1
export GDK_DPI_SCALE=1.50
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1.50
export QT_FONT_DPI=144
export XCURSOR_SIZE=32
export XCURSOR_THEME=Adwaita

# Set cursor shape to default (fixes "loading" cursor issue)
xsetroot -cursor_name left_ptr

# ============================================================================
# Pipewire Audio Session
# Socket activation should handle this, but we ensure it starts for startx
# ============================================================================
if command -v pipewire >/dev/null 2>&1; then
    # Check if systemd user session is available
    if systemctl --user is-system-running >/dev/null 2>&1; then
        # Systemd user session active - use socket activation
        systemctl --user start pipewire.socket pipewire-pulse.socket 2>/dev/null
        systemctl --user start wireplumber.service 2>/dev/null
    else
        # No systemd user session (pure startx) - manual startup
        pipewire &
        sleep 0.2
        pipewire-pulse &
        sleep 0.2
        wireplumber &
    fi
fi

# Start i3 window manager
exec i3


