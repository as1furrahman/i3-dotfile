#!/bin/bash

# AI Sidebar for i3 using OpenAI GPT API
# API key is stored in ~/.config/openai_api_key

KEY_FILE="$HOME/.config/openai_api_key"
SIDEBAR_THEME="$HOME/.config/rofi/ai-sidebar.rasi"
MODEL="gpt-4o-mini"
MAX_TOKENS=1000

# Load API key
if [[ -f "$KEY_FILE" ]]; then
    API_KEY=$(cat "$KEY_FILE" | tr -d '\n')
fi

# Prompt for API key if not set
if [[ -z "$API_KEY" ]]; then
    API_KEY=$(rofi -dmenu -p "󰌆 Enter API Key" -password -theme "$SIDEBAR_THEME" -lines 0)
    [[ -z "$API_KEY" ]] && exit 0
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Chat loop
while true; do
    QUERY=$(rofi -dmenu -p "󰧑 Ask AI" -theme "$SIDEBAR_THEME" -lines 0)
    [[ -z "$QUERY" ]] && exit 0
    
    # Call API
    RESPONSE=$(curl -s --max-time 30 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$QUERY" | jq -Rs '.')}],\"max_tokens\":$MAX_TOKENS}")
    
    ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // .error.message // "Error"')
    
    [[ "$ANSWER" == "null" || -z "$ANSWER" ]] && ANSWER="API Error - check your key"
    
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    CHOICE=$(echo "$ANSWER" | rofi -dmenu -p "󰧑 AI (Enter=new, Esc=close)" -theme "$SIDEBAR_THEME")
    [[ -z "$CHOICE" ]] && exit 0
done
