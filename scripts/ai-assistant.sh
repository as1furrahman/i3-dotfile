#!/bin/bash

# AI Sidebar for i3 - Rofi-based with Tokyo Night theme
# API key stored in ~/.config/openai_api_key

KEY_FILE="$HOME/.config/openai_api_key"
SIDEBAR_THEME="$HOME/.config/rofi/ai-sidebar.rasi"
MODEL="gpt-4o-mini"
MAX_TOKENS=2000

# Load API key
[[ -f "$KEY_FILE" ]] && API_KEY=$(cat "$KEY_FILE" | tr -d '\n')

if [[ -z "$API_KEY" ]]; then
    API_KEY=$(rofi -dmenu -p "󰌆 API Key" -password -theme "$SIDEBAR_THEME" -lines 0)
    [[ -z "$API_KEY" ]] && exit 0
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Chat history file
HISTORY_FILE="/tmp/ai_chat_history_$(date +%s).json"
echo "[]" > "$HISTORY_FILE"

# Initial history text
HISTORY_TEXT="<span foreground='#565f89'><i>Type to chat... (Esc to close)</i></span>"

# Function to strictly kill previous rofi instances
cleanup_rofi() {
    if [[ -n "$THINK_PID" ]]; then
        kill "$THINK_PID" 2>/dev/null
        wait "$THINK_PID" 2>/dev/null
    fi
    # Failsafe: kill any rofi running with our theme to prevent lockups
    pkill -f "rofi -dmenu.*ai-sidebar.rasi" 2>/dev/null
}

trap cleanup_rofi EXIT

# Chat loop
while true; do
    # 1. Update History Display (Construct text for -mesg)
    NEW_HISTORY_TEXT=""
    # We use jq to parse, then fold to wrap lines
    while IFS= read -r line; do
        role=$(echo "$line" | jq -r .role)
        content=$(echo "$line" | jq -r .content)
        
        # Wrap content at 65 chars and escape Pango
        wrapped=$(echo "$content" | fold -s -w 65 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
        
        if [[ "$role" == "user" ]]; then
            NEW_HISTORY_TEXT+="<span foreground=\"#9ece6a\"><b>User:</b></span>"$'\n'"$wrapped"$'\n\n'
        else
            NEW_HISTORY_TEXT+="<span foreground=\"#c0caf5\"><b>AI:</b></span>"$'\n'"$wrapped"$'\n\n'
        fi
    done < <(jq -c '.[]' "$HISTORY_FILE")

    # If history is empty, show default prompt
    if [[ -z "$NEW_HISTORY_TEXT" ]]; then
        HISTORY_TEXT="<span foreground='#565f89'><i>Type to chat... (Esc to close)</i></span>"
    else
        HISTORY_TEXT="$NEW_HISTORY_TEXT"
    fi

    # 2. Get User Input
    # Pipe empty string to ensure rofi has stdin
    QUERY=$(echo -n "" | rofi -dmenu -p "󰧑 Input" -theme "$SIDEBAR_THEME" -mesg "$HISTORY_TEXT" -lines 0)
    
    # Exit if empty
    [[ -z "$QUERY" ]] && break
    
    # 3. Show "Thinking..." notification (avoids focus stealing crash)
    notify-send -u low -t 3000 "AI Assistant" "Thinking..."
    
    # 4. Process API Request
    TEMP_HIST=$(mktemp)
    jq --arg content "$QUERY" '. + [{"role": "user", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    ANSWER=$(curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":$(cat "$HISTORY_FILE"),\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    TEMP_HIST=$(mktemp)
    jq --arg content "$ANSWER" '. + [{"role": "assistant", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Safety delay
    sleep 0.5
done

rm -f "$HISTORY_FILE"
exit 0
