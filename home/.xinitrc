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

# HiDPI Scaling for 2.8K OLED (1.50x for better readability on 13.3" 2880x1800)
# GDK_SCALE must be integer, so we use 1 with DPI_SCALE for fractional
export GDK_SCALE=1
export GDK_DPI_SCALE=1.50
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1.50
export QT_FONT_DPI=144
export XCURSOR_SIZE=32
export XCURSOR_THEME=Adwaita

# Set cursor shape to default (fixes "loading" cursor issue)
xsetroot -cursor_name left_ptr

# Start Pipewire audio session
pipewire &
pipewire-pulse &
wireplumber &

# Start i3 window manager
exec i3

