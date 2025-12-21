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

# Chat loop
while true; do
    # Get question
    QUERY=$(rofi -dmenu -p "󰧑 Ask AI" -theme "$SIDEBAR_THEME" -lines 0)
    [[ -z "$QUERY" ]] && exit 0
    
    # Show "Thinking..." in terminal briefly
    echo "Thinking..." | rofi -dmenu -p "󰧑" -theme "$SIDEBAR_THEME" -lines 1 &
    THINK_PID=$!
    
    # Call API
    ANSWER=$(curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$QUERY" | jq -Rs '.')}],\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    # Kill thinking prompt
    kill $THINK_PID 2>/dev/null
    wait $THINK_PID 2>/dev/null
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Format response: wrap lines at 70 chars for readability
    FORMATTED=$(echo "$ANSWER" | fold -s -w 70)
    
    # Show full response (each line as rofi entry)
    echo -e "$FORMATTED" | rofi -dmenu -p "󰧑 AI (Enter=new, Esc=close)" -theme "$SIDEBAR_THEME"
    
    [[ $? -ne 0 ]] && exit 0
done
