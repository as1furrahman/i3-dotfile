#!/bin/bash
# Rofi WiFi - Minimal & Universal
# Theme: Tokyo Night (matches rofi-bluetooth.sh style)
# 
# Usage:
#   rofi-wifi.sh              - Open menu
#   rofi-wifi.sh autoconnect  - Auto-connect to known networks (for startup)

DIVIDER="───"

# Notification helper
notify() {
    $HOME/.config/i3/scripts/notify-osd.sh "network-wireless" "$1" 1008
}

# Check if WiFi is enabled
wifi_on() { [[ "$(nmcli radio wifi)" == "enabled" ]]; }

# Get current connection
get_current() { nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2; }

# Auto-connect to known networks (for startup)
autoconnect() {
    sleep 3
    nmcli radio wifi on 2>/dev/null
    exit 0
}

[ "$1" = "autoconnect" ] && autoconnect

# Main menu
show_menu() {
    local current=$(get_current)
    
    if wifi_on; then
        if [[ -n "$current" ]]; then
            echo "󰤨 $current"
        else
            echo "󰤭 Not Connected"
        fi
        echo "$DIVIDER"
        echo "󰤮 WiFi Off"
        echo "󰑓 Scan"
        echo "$DIVIDER"
        
        # List available networks
        nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list 2>/dev/null | \
        while IFS=: read -r ssid signal security inuse; do
            [[ -z "$ssid" ]] && continue
            
            # Signal icon
            if [[ "$signal" -ge 75 ]]; then icon="󰤨"
            elif [[ "$signal" -ge 50 ]]; then icon="󰤥"
            elif [[ "$signal" -ge 25 ]]; then icon="󰤢"
            else icon="󰤟"
            fi
            
            # Security lock
            [[ -n "$security" && "$security" != "--" ]] && lock="󰌾" || lock=""
            
            # Connected indicator
            if [[ "$inuse" == "*" ]]; then
                echo " $ssid $lock|$ssid"
            else
                echo "$icon $ssid $lock|$ssid"
            fi
        done | awk -F'|' '!seen[$2]++' # Remove duplicates by SSID
    else
        echo "󰤮 WiFi OFF"
        echo "$DIVIDER"
        echo "󰤨 WiFi On"
    fi
}

# Connect to a network
connect_network() {
    local ssid="$1"
    
    # Get security type for this network
    local security=$(nmcli -t -f SSID,SECURITY device wifi list 2>/dev/null | awk -F: -v ssid="$ssid" '$1 == ssid {print $2; exit}')
    
    if [[ -z "$security" || "$security" == "--" || "$security" == "" ]]; then
        # Open network - connect directly (no password needed)
        notify "Connecting to $ssid..."
        nmcli device wifi connect "$ssid" &>/dev/null
    else
        # Secured network - ALWAYS ask for password
        local pass=$(rofi -dmenu -password -p "󰌾 Password" -mesg "Enter password for: $ssid")
        [[ -z "$pass" ]] && return
        
        # Delete any existing saved connection to use the new password
        nmcli connection delete "$ssid" &>/dev/null 2>&1
        
        notify "Connecting to $ssid..."
        # This will save the connection for future auto-connect
        nmcli device wifi connect "$ssid" password "$pass" &>/dev/null
    fi
    
    # Check result
    sleep 2
    if [[ "$(get_current)" == "$ssid" ]]; then
        notify "Connected: $ssid"
    else
        notify "Failed: $ssid"
    fi
}

# Network submenu
network_menu() {
    local ssid="$1"
    local current=$(get_current)
    
    # If this is the current network, show disconnect option
    if [[ "$ssid" == "$current" ]]; then
        local action=$(echo -e "󰤮 Disconnect\n󰆴 Forget" | rofi -dmenu -i -p "$ssid")
        case "$action" in
            "󰤮 Disconnect")
                nmcli connection down "$ssid" &>/dev/null
                notify "Disconnected"
                ;;
            "󰆴 Forget")
                nmcli connection delete "$ssid" &>/dev/null
                notify "Removed: $ssid"
                ;;
        esac
    else
        # Not connected - directly connect (will ask for password if secured)
        connect_network "$ssid"
    fi
}

# Main
sel=$(show_menu | rofi -dmenu -i -p "󰤨 WiFi")

case "$sel" in
    " Not Connected"|"󰤮 WiFi OFF"|"$DIVIDER") exec "$0" ;;
    "󰤨 WiFi On") nmcli radio wifi on; sleep 1; exec "$0" ;;
    "󰤮 WiFi Off") nmcli radio wifi off; notify "WiFi Off" ;;
    "󰑓 Scan")
        notify "Scanning..."
        nmcli device wifi rescan &>/dev/null
        sleep 2
        exec "$0"
        ;;
    "") exit 0 ;;
    *)
        # Extract SSID (format: "icon SSID lock|SSID")
        if [[ "$sel" == *"|"* ]]; then
            ssid="${sel##*|}"
            [[ -n "$ssid" ]] && network_menu "$ssid"
        else
            # Header line (current connection) - refresh
            exec "$0"
        fi
        ;;
esac
