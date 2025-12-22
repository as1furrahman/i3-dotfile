#!/bin/bash
# Rofi AskPass - Minimal Tokyo Night password prompt
# Usage: export SUDO_ASKPASS=this_script; sudo -A command

rofi -dmenu \
     -password \
     -i \
     -no-fixed-num-lines \
     -p "󰌾" \
     -mesg "" \
     -theme-str '
        * { font: "Cascadia Code NF 12"; }
        window {
            width: 300px;
            location: center;
            border: 2px solid;
            border-color: #7aa2f7;
            border-radius: 12px;
            background-color: #1a1b26;
            padding: 0;
        }
        mainbox { padding: 20px; background-color: transparent; }
        inputbar {
            children: [prompt, entry];
            background-color: #24283b;
            border-radius: 8px;
            padding: 12px 16px;
        }
        prompt {
            font: "Cascadia Code NF Bold 14";
            text-color: #7aa2f7;
            background-color: transparent;
            margin: 0 8px 0 0;
        }
        entry {
            text-color: #c0caf5;
            background-color: transparent;
            placeholder: "Password";
            placeholder-color: #565f89;
        }
        listview { enabled: false; }
        message { enabled: false; }
     '
