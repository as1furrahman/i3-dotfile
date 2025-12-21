#!/bin/bash
# Bluetooth Status Script for i3blocks

# Handle click events
case $BLOCK_BUTTON in
    1) # Left click - open bluetooth manager
        if command -v blueman-manager >/dev/null 2>&1; then
            i3-msg -q "exec --no-startup-id blueman-manager"
        elif command -v kitty >/dev/null 2>&1; then
            i3-msg -q "exec --no-startup-id kitty -e bluetoothctl"
        elif command -v alacritty >/dev/null 2>&1; then
            i3-msg -q "exec --no-startup-id alacritty -e bluetoothctl"
        elif command -v xterm >/dev/null 2>&1; then
            i3-msg -q "exec --no-startup-id xterm -e bluetoothctl"
        fi
        ;;
    3) # Right click - toggle power
        if [ "$(bluetoothctl show | grep "Powered: yes")" ]; then
            bluetoothctl power off >/dev/null
        else
            bluetoothctl power on >/dev/null
        fi
        ;;
esac

# Check if bluetoothctl is available
if ! command -v bluetoothctl >/dev/null 2>&1; then
    echo "No bluetoothctl"
    exit 0
fi

# Check power status
POWER_STATUS=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$POWER_STATUS" ]; then
    echo " Off"
    echo " Off"
    echo "#565f89" # Dimmed color
    exit 0
fi

# Get connected devices
# This is a bit tricky with bluetoothctl, iterating devices and checking 'Connected: yes'
DEVICES=$(bluetoothctl devices | awk '{print $2}')
CONNECTED_DEVICES=""
COUNT=0

for dev in $DEVICES; do
    info=$(bluetoothctl info "$dev")
    if echo "$info" | grep -q "Connected: yes"; then
        alias=$(echo "$info" | grep "Alias" | cut -d ' ' -f 2-)
        if [ -z "$CONNECTED_DEVICES" ]; then
            CONNECTED_DEVICES="$alias"
        else
            CONNECTED_DEVICES="$CONNECTED_DEVICES, $alias"
        fi
        COUNT=$((COUNT+1))
    fi
done

if [ $COUNT -gt 0 ]; then
    # echo " $CONNECTED_DEVICES" # Full list might be too long
    # Use shorter format matching wifi, maybe just first device + count if > 1?
    # Or just count if many?
    # Let's try listing them, but maybe truncate?
    # For now: Just listing.
    if [ ${#CONNECTED_DEVICES} -gt 20 ]; then
         echo " ${CONNECTED_DEVICES:0:17}..."
    else
         echo " $CONNECTED_DEVICES"
    fi
    echo " $CONNECTED_DEVICES" # Short text
    echo "#7aa2f7" # Active color (blue)
else
    echo " On"
    echo " On"
    echo "#7aa2f7" # Active color (blue)
fi
