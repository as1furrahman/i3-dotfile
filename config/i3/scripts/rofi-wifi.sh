#!/bin/bash
# WiFi Menu for i3 (Rofi-based)
# Dependencies: nmcli, rofi, notify-send, awk

THEME="$HOME/.config/rofi/tokyonight.rasi"
export LC_ALL=C

notify() { notify-send "WiFi" "$1"; }

# 1. Check Status
STATE=$(nmcli -fields WIFI g)
# Check specific device state for unavailable
DEV_STATE=$(nmcli -t -f TYPE,STATE dev | grep "wifi" | cut -d: -f2 | head -n1)

# Check rfkill to differentiate HW block vs SW error
RFKILL=$(rfkill list wifi | grep "Soft blocked: yes")

CURRENT=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [[ "$STATE" =~ "disabled" ]] || [[ "$STATE" =~ "off" ]]; then
    TOGGLE="直 Enable WiFi"
    STATUS="Disabled"
elif [[ "$DEV_STATE" == "unavailable" ]]; then
    if [[ -n "$RFKILL" ]]; then
        TOGGLE="直 Enable WiFi (Force)"
        STATUS="RFKill Blocked"
    else
        TOGGLE="直 Reset Networking"
        STATUS="Interface Down/Error"
    fi
else
    TOGGLE="睊 Disable WiFi"
    STATUS="Enabled"
    [[ -n "$CURRENT" ]] && STATUS="Connected: $CURRENT"
fi

# 2. Build Menu Options
OPTIONS="$TOGGLE\n Rescan"

if [[ "$STATUS" != "Disabled" && "$STATUS" != "RFKill Blocked" && "$STATUS" != "Interface Down/Error" ]]; then
    # List Networks
    LIST=$(nmcli --fields SSID,BARS,SECURITY device wifi list | sed 1d | \
        awk -F'  +' '{printf "%-20s  %s  %s\n", $1, $2, $3}')
    
    if [[ -z "$LIST" ]]; then
        MENU="$OPTIONS\n----------------------------------------\n(No Networks Found)"
    else
        MENU="$OPTIONS\n----------------------------------------\n$LIST"
    fi
else
    # Diagnostics
    if [[ "$STATUS" == "RFKill Blocked" ]]; then
        MENU="$OPTIONS\n----------------------------------------\n⚠️ RFKill Blocked.\nTry 'Enable WiFi (Force)' or check F12 key."
    elif [[ "$STATUS" == "Interface Down/Error" ]]; then
        MENU="$OPTIONS\n----------------------------------------\n⚠️ Interface Unavailable (No Block).\nTry 'Reset Networking' option above."
    else
        MENU="$OPTIONS"
    fi
fi

# 3. Show Rofi
SELECTED=$(echo -e "$MENU" | rofi -dmenu -p "WiFi" -theme "$THEME" -mesg "Status: $STATUS" -lines 15)

# 4. Handle Selection
case "$SELECTED" in
    "") exit 0 ;;
    "直 Enable WiFi") nmcli radio wifi on; notify "Enabling WiFi..." ;;
    "直 Enable WiFi (Force)") nmcli radio wifi off; sleep 1; nmcli radio wifi on; notify "Forcing WiFi Enable..." ;;
    "直 Reset Networking") 
        notify "Resetting Network Manager..."
        nmcli networking off
        sleep 2
        nmcli networking on
        notify "Networking Restarted. Please rescan." 
        ;;
    "睊 Disable WiFi") nmcli radio wifi off; notify "Disabling WiFi..." ;;
    " Rescan") nmcli device wifi rescan; notify "Scanning..." ;;
    *)
        # It's a network. Parse SSID.
        # Assumption: SSID is everything before the double-space separator we made in awk? 
        # Or simply: The SSID is the start of the line.
        # But awk printf "%-20s" pads it.
        # Let's clean it.
        
        # Remove divider line
        [[ "$SELECTED" =~ "---" ]] && exit 0
        
        # Extract SSID (Take substring or use awk)
        # Using the column width knowledge: first 20 chars are SSID (padded)
        RAW_SSID=$(echo "$SELECTED" | awk '{print $1}') 
        # Wait, awk defaults to space split. SSID "My Wifi" becomes $1="My". Wrong.
        
        # Better: use the original nmcli output format matching?
        # Let's retrieve the SSID by matching the selected line against a fresh scan? No, race condition.
        
        # Robust parsing:
        # The selected string is "SSID_PADDED  BARS  SEC"
        # We can extract up to the first occurrence of "  ▂" (Bars)? No, bars vary.
        # We can extract up to the last 2 columns?
        
        # Let's try: "SSID" is everything before the "  " (2 spaces) separator usage in awk.
        # sed 's/  .*//' might work if we forced double spaces.
        SSID=$(echo "$SELECTED" | sed 's/  .*//' | sed 's/ *$//')
        
        if [[ -z "$SSID" ]]; then exit 0; fi

        # Check if saved connection exists
        if nmcli connection show "$SSID" >/dev/null 2>&1; then
            notify "Connecting to $SSID..."
            nmcli connection up "$SSID"
        else
            # New connection: Prompt for password
            # Check security type from selection to see if password needed
            if [[ "$SELECTED" =~ "--" ]]; then
                # Open network
                notify "Connecting to $SSID (Open)..."
                nmcli device wifi connect "$SSID"
            else
                # WPA/WEP
                PASS=$(rofi -dmenu -p " Password" -password -theme "$THEME" -mesg "Enter password for $SSID" -lines 0)
                if [[ -n "$PASS" ]]; then
                    notify "Connecting to $SSID..."
                    nmcli device wifi connect "$SSID" password "$PASS"
                fi
            fi
        fi
        ;;
esac
exit 0
