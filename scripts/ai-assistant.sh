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
HISTORY_TEXT="<b>Possible Commands:</b>\n- Type your question and press Enter\n- Press Esc to close\n- History is saved for this session"

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
    HISTORY_TEXT=$(jq -r '
        map(
            if .role == "user" then
                "<span foreground=\"#9ece6a\"><b>User:</b></span> " + (.content | gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;"))
            else
                "<span foreground=\"#c0caf5\"><b>AI:</b></span> " + (.content | gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;"))
            end
        ) | join("\n\n")
    ' "$HISTORY_FILE")

    # Safety delay to ensure previous rofi is fully gone before restarting loop
    sleep 0.1
done

rm -f "$HISTORY_FILE"
exit 0
