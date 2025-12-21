#!/bin/bash

# Rofi Power Menu
# Dependencies: rofi, i3lock (or blur-lock.sh)

# Options
lock="󰒳 Lock"
suspend="󰒲 Suspend"
hibernate="󰜗 Hibernate"
logout="󰍃 Logout"
reboot="󱐋 Reboot"
shutdown="󰐥 Shutdown"

# Rofi command
rofi_cmd() {
	rofi -dmenu \
		-i \
		-p "Power" \
		-theme-str 'window {width: 250px;} listview {lines: 6;}'
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$hibernate\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute command
run_cmd() {
	if [[ "$1" == "--opt1" ]]; then
		"$HOME/.config/i3/scripts/blur-lock.sh"
	elif [[ "$1" == "--opt2" ]]; then
		systemctl suspend
	elif [[ "$1" == "--opt3" ]]; then
        systemctl hibernate
	elif [[ "$1" == "--opt4" ]]; then
		i3-msg exit
	elif [[ "$1" == "--opt5" ]]; then
		systemctl reboot
	elif [[ "$1" == "--opt6" ]]; then
		systemctl poweroff
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $lock)
		run_cmd --opt1
        ;;
    $suspend)
		run_cmd --opt2
        ;;
    $hibernate)
        run_cmd --opt3
        ;;
    $logout)
		run_cmd --opt4
        ;;
    $reboot)
		run_cmd --opt5
        ;;
    $shutdown)
		run_cmd --opt6
        ;;
esac
