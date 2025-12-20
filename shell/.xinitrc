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

# Set cursor shape to default (fixes "loading" cursor issue)
xsetroot -cursor_name left_ptr

# Start system components
# (Most of these are better handled in i3 config exec, but xinitrc is good for env setup)

# Start i3
exec i3
