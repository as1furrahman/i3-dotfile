#!/bin/sh

# ============================================================================
# .xinitrc - X Session Initialization
# ============================================================================

# Merge X resources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Load X keymap (if available)
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap

# Start DBus if not already started (Debian usually handles this, but safety first)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# HiDPI Scaling for 2.8K OLED (2x)
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_SCALE_FACTOR=2
export XCURSOR_SIZE=32

# Set cursor shape to default (fixes "loading" cursor issue)
xsetroot -cursor_name left_ptr

# Start system components
# (Most of these are better handled in i3 config exec, but xinitrc is good for env setup)

# Start i3
exec i3
