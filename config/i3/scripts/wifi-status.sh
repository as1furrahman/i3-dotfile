#!/bin/bash
# WiFi Status Script for i3blocks
# Handles all edge cases: no device, radio off, disconnected, connected
# Left click opens nmtui for network management

case $BLOCK_BUTTON in
    1) # Left click - Open Rofi WiFi Menu
        $HOME/.config/i3/scripts/rofi-wifi.sh >/dev/null 2>&1 &
        ;;
    3) # Right click - Toggle WiFi (Quick action)
        nmcli radio wifi toggle >/dev/null 2>&1 &
        ;;
esac

# Get WiFi interface
WIFI_IF=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')

if [ -z "$WIFI_IF" ]; then
    echo "No WiFi"
    exit 0
fi

# Check WiFi radio status
if [ "$(nmcli radio wifi)" = "disabled" ]; then
    echo "WiFi Off"
    exit 0
fi

# Get connection info
WIFI_INFO=$(nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes')
if [ -n "$WIFI_INFO" ]; then
    SSID=$(echo "$WIFI_INFO" | cut -d: -f2)
    SIGNAL=$(echo "$WIFI_INFO" | cut -d: -f3)
    echo "$SSID $SIGNAL%"
else
    echo "Disconnected"
fi
