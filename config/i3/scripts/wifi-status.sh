#!/bin/bash
# WiFi Status Script for i3blocks
# Handles all edge cases: no device, radio off, disconnected, connected
# Left click opens Rofi WiFi Menu

case $BLOCK_BUTTON in
    1) # Left click - Open Rofi WiFi Menu
        $HOME/.config/i3/scripts/rofi-wifi.sh >/dev/null 2>&1 &
        ;;
    3) # Right click - Toggle WiFi (Quick action)
        nmcli radio wifi toggle >/dev/null 2>&1 &
        ;;
esac

# Check WiFi radio status first
RADIO=$(nmcli radio wifi 2>/dev/null)
if [ "$RADIO" = "disabled" ]; then
    echo "Off"
    exit 0
fi

# Get WiFi device status using nmcli (no iw dependency)
WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi$" | cut -d: -f1 | head -1)

if [ -z "$WIFI_DEV" ]; then
    echo "No WiFi"
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

