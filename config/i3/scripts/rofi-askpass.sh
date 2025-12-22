#!/bin/bash
# Rofi AskPass - Minimal password prompt for sudo
# Usage: export SUDO_ASKPASS=this_script; sudo -A command

rofi -dmenu \
     -password \
     -i \
     -no-fixed-num-lines \
     -p "🔒 Password" \
     -theme-str 'window {width: 25%;} listview {lines: 0;} entry {placeholder: "Enter sudo password...";}'
