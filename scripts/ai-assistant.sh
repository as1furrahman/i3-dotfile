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

# Chat loop
while true; do
    # Get question
    QUERY=$(rofi -dmenu -p "󰧑 Ask AI" -theme "$SIDEBAR_THEME" -lines 0)
    [[ -z "$QUERY" ]] && break
    
    # Show "Thinking..."
    echo "Thinking..." | rofi -dmenu -p "󰧑" -theme "$SIDEBAR_THEME" -lines 1 &
    THINK_PID=$!
    
    # Add user message to history
    TEMP_HIST=$(mktemp)
    jq --arg content "$QUERY" '. + [{"role": "user", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Call API with full history
    ANSWER=$(curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":$(cat "$HISTORY_FILE"),\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    # Kill thinking prompt
    kill $THINK_PID 2>/dev/null
    wait $THINK_PID 2>/dev/null
    
    # Add assistant response to history
    TEMP_HIST=$(mktemp)
    jq --arg content "$ANSWER" '. + [{"role": "assistant", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Prepare display: standard wrapping
    FORMATTED=$(echo "$ANSWER" | fold -s -w 70)
    
    # Show full response
    echo -e "$FORMATTED\n\n─────────────────────────────────────\n[Enter = New Question | Esc = Close]" \
        | rofi -dmenu -p "󰧑 AI" -theme "$SIDEBAR_THEME" -markup-rows
    
    [[ $? -ne 0 ]] && break
done

# Cleanup history on exit
rm -f "$HISTORY_FILE"
exit 0
