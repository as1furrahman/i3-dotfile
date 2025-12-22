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

# HiDPI Scaling for 2.8K OLED (2x)
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=32
export XCURSOR_THEME=Adwaita

# Set cursor shape to default (fixes "loading" cursor issue)
xsetroot -cursor_name left_ptr

# Start i3 window manager
exec i3

