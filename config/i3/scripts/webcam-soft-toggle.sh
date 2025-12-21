#!/bin/bash
# Webcam Instant Toggle - Uses USB 'authorized' attribute
# Simulates physical unplug/replug for instant effect
# VID:PID = 13d3:5463

VID="13d3"
PID="5463"
FOUND=0

# Find the main USB device
for dir in /sys/bus/usb/devices/*; do
    if [ -e "$dir/idVendor" ] && [ -e "$dir/idProduct" ]; then
        v=$(cat "$dir/idVendor")
        p=$(cat "$dir/idProduct")
        if [ "$v" == "$VID" ] && [ "$p" == "$PID" ]; then
            DEVICE_DIR="$dir"
            FOUND=1
            break
        fi
    fi
done

if [ "$FOUND" -eq 0 ]; then
    notify-send "Webcam" "Hardware not found via USB scan!" -u critical 2>/dev/null
    exit 1
fi

AUTH_FILE="$DEVICE_DIR/authorized"
CURRENT=$(cat "$AUTH_FILE")

# Helper to exec privileged command: try sudo -n first, then sudo -A (rofi), then pkexec
elevate_cmd() {
    local cmd="$1"
    
    # 1. Try silent sudo (if NOPASSWD is set)
    if sudo -n bash -c "$cmd" 2>/dev/null; then
        return 0
    fi

    # 2. Try Rofi AskPass (Minimal UI)
    export SUDO_ASKPASS="$HOME/repo/i3-dotfile/scripts/rofi-askpass.sh"
    if sudo -A bash -c "$cmd" 2>/dev/null; then
        return 0
    fi
    
    # 3. Fallback to standard pkexec (GUI)
    pkexec bash -c "$cmd"
}

if [ "$CURRENT" == "1" ]; then
    # DISABLE (Simulate unplug)
    if elevate_cmd "echo 0 > '$AUTH_FILE'"; then
        notify-send "Webcam" " Off"
    else
        notify-send "Webcam" "Failed to block"
    fi
else
    # ENABLE (Simulate plug)
    if elevate_cmd "echo 1 > '$AUTH_FILE'"; then
        notify-send "Webcam" " On"
    else
        notify-send "Webcam" "Failed to unblock"
    fi
fi
