#!/usr/bin/env bash
# Monitor layout script template
# Customize with arandr or xrandr commands

# Default: Use auto-detected settings
xrandr --auto

# Example configurations (uncomment as needed):

# Single monitor at native resolution
# xrandr --output eDP-1 --primary --mode 2880x1800 --rate 90

# Laptop + external monitor (right)
# xrandr --output eDP-1 --primary --mode 2880x1800 --pos 0x0 \
#        --output HDMI-1 --mode 1920x1080 --pos 2880x0

# Laptop + external monitor (left)
# xrandr --output HDMI-1 --mode 1920x1080 --pos 0x0 \
#        --output eDP-1 --primary --mode 2880x1800 --pos 1920x0

# External only (laptop closed)
# xrandr --output eDP-1 --off --output HDMI-1 --primary --mode 1920x1080
