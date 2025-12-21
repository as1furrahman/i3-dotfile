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

# Initial empty history text
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
    # 1. Get User Input
    QUERY=$(rofi -dmenu -p "󰧑 Input" -theme "$SIDEBAR_THEME" -mesg "$HISTORY_TEXT" -lines 0)
    
    # Exit if empty
    [[ -z "$QUERY" ]] && break
    
    # 2. Show "Thinking..." state
    # Start rofi in background directly (no subshell) to get correct PID
    echo "" | rofi -dmenu -p "󰧑 Thinking" -theme "$SIDEBAR_THEME" \
        -mesg "$HISTORY_TEXT <span foreground='#7aa2f7'><i>(Thinking...)</i></span>" \
        -lines 0 >/dev/null 2>&1 &
    THINK_PID=$!
    
    # 3. Process API Request
    TEMP_HIST=$(mktemp)
    jq --arg content "$QUERY" '. + [{"role": "user", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    ANSWER=$(curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":$(cat "$HISTORY_FILE"),\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    TEMP_HIST=$(mktemp)
    jq --arg content "$ANSWER" '. + [{"role": "assistant", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Kill "Thinking..." window specifically
    kill "$THINK_PID" 2>/dev/null
    wait "$THINK_PID" 2>/dev/null
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Update History Display
    # Update History Display
    HISTORY_TEXT=""
    # Limit to last 10 messages to prevent too much lag
    MESSAGES=$(tail -n 10 <(jq -c '.[]' "$HISTORY_FILE"))
    
    while IFS= read -r line; do
        role=$(echo "$line" | jq -r .role)
        content=$(echo "$line" | jq -r .content)
        
        # Wrap content at 65 chars (approx for 600px width)
        wrapped=$(echo "$content" | fold -s -w 65 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
        
        if [[ "$role" == "user" ]]; then
            HISTORY_TEXT+="<span foreground=\"#9ece6a\"><b>User:</b></span>\n$wrapped\n\n"
        else
            HISTORY_TEXT+="<span foreground=\"#c0caf5\"><b>AI:</b></span>\n$wrapped\n\n"
        fi
    done <<< "$MESSAGES"

    # Safety delay to ensure previous rofi is fully gone before restarting loop
    sleep 0.1
done

rm -f "$HISTORY_FILE"
exit 0
