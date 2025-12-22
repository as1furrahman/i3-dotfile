#!/bin/bash
# Rofi Bluetooth - Minimal & Universal
# Theme: Tokyo Night
# 
# Usage:
#   rofi-bluetooth.sh          - Open menu
#   rofi-bluetooth.sh autoconnect - Auto-connect trusted devices (for startup)

DIVIDER="───"

# Check bluetooth power
bt_on() { bluetoothctl show | grep -q "Powered: yes"; }

# Auto-sync HID device (disconnect/reconnect)
sync_device() {
    local mac="$1"
    bluetoothctl disconnect "$mac" &>/dev/null
    sleep 1
    bluetoothctl connect "$mac" &>/dev/null
}

# Auto-connect all trusted paired devices
autoconnect() {
    sleep 3
    bluetoothctl power on &>/dev/null
    while IFS= read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        [ -z "$mac" ] && continue
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        if echo "$info" | grep -q "Trusted: yes" && echo "$info" | grep -q "Paired: yes"; then
            bluetoothctl connect "$mac" &>/dev/null &
        fi
    done < <(bluetoothctl devices Paired 2>/dev/null)
    exit 0
}

# Handle autoconnect argument
[ "$1" = "autoconnect" ] && autoconnect

# Main menu
show_menu() {
    if bt_on; then
        echo "󰂯 ON"
        echo "$DIVIDER"
        echo "󰂲 Off"
        echo "󰂰 Scan"
        echo "$DIVIDER"
        
        while IFS= read -r line; do
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | cut -d' ' -f3-)
            [ -z "$mac" ] && continue
            
            if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
                echo " $name|$mac"
            elif bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
                echo " $name|$mac"
            else
                echo "○ $name|$mac"
            fi
        done < <(bluetoothctl devices 2>/dev/null)
    else
        echo "󰂲 OFF"
        echo "$DIVIDER"
        echo "󰂯 On"
    fi
}

# Device menu
device_menu() {
    local name="$1" mac="$2"
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    
    if echo "$info" | grep -q "Connected: yes"; then
        opts="󰂲 Disconnect\n Sync"
    elif echo "$info" | grep -q "Paired: yes"; then
        opts=" Connect"
    else
        opts="󰂱 Pair"
    fi
    
    if ! echo "$info" | grep -q "Trusted: yes"; then
        opts+="\n Trust"
    fi
    
    if echo "$info" | grep -q "Paired: yes"; then
        opts+="\n󰆴 Remove"
    fi
    
    action=$(echo -e "$opts" | rofi -dmenu -i -p "$name")
    
    case "$action" in
        " Connect")
            bluetoothctl trust "$mac" &>/dev/null
            bluetoothctl connect "$mac" &>/dev/null
            sleep 1
            sync_device "$mac"
            ;;
        "󰂲 Disconnect")
            bluetoothctl disconnect "$mac" &>/dev/null
            ;;
        " Sync")
            sync_device "$mac"
            ;;
        "󰂱 Pair")
            alacritty -e bash -c '
                echo "󰂱 Pairing: '"$name"'"
                echo ""
                bluetoothctl <<EOF
agent on
default-agent
pair '"$mac"'
trust '"$mac"'
connect '"$mac"'
quit
EOF
                sleep 2
                bluetoothctl disconnect "'"$mac"'" &>/dev/null
                sleep 1
                bluetoothctl connect "'"$mac"'" &>/dev/null
                echo ""
                echo "Done. Press Enter."
                read
            ' &
            ;;
        " Trust")
            bluetoothctl trust "$mac" &>/dev/null
            ;;
        "󰆴 Remove")
            bluetoothctl remove "$mac" &>/dev/null
            ;;
    esac
}

# Main
sel=$(show_menu | rofi -dmenu -i -p "󰂯")

case "$sel" in
    "󰂯 ON"|"󰂲 OFF"|"$DIVIDER") exec "$0" ;;
    "󰂯 On") bluetoothctl power on; sleep 0.5; exec "$0" ;;
    "󰂲 Off") bluetoothctl power off ;;
    "󰂰 Scan")
        bluetoothctl --timeout 5 scan on &>/dev/null &
        sleep 5
        exec "$0"
        ;;
    "") exit 0 ;;
    *)
        data="${sel#* }"
        data="${data#○ }"
        name="${data%|*}"
        mac="${data##*|}"
        [ -n "$mac" ] && device_menu "$name" "$mac"
        ;;
esac
