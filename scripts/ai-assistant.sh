#!/bin/bash

# AI Sidebar for i3 using OpenAI GPT API
# Appears as sidebar panel on left side of screen
# 
# API key is stored in ~/.config/openai_api_key

# Configuration
KEY_FILE="$HOME/.config/openai_api_key"
SIDEBAR_THEME="$HOME/.config/rofi/ai-sidebar.rasi"
MODEL="gpt-4o-mini"
MAX_TOKENS=1000

# Load API key from file or environment
if [[ -f "$KEY_FILE" ]]; then
    API_KEY=$(cat "$KEY_FILE" | tr -d '\n')
else
    API_KEY="${OPENAI_API_KEY:-}"
fi

# If no API key, prompt user to enter one
if [[ -z "$API_KEY" ]]; then
    API_KEY=$(rofi -dmenu -p "󰌆 Enter API Key" -password -theme "$SIDEBAR_THEME" -lines 0)
    
    if [[ -z "$API_KEY" ]]; then
        exit 0
    fi
    
    mkdir -p "$(dirname "$KEY_FILE")"
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Main chat loop
while true; do
    # Get user input
    QUERY=$(rofi -dmenu -p "󰧑 Ask AI" -theme "$SIDEBAR_THEME" -lines 0)
    
    # Exit if no input or user cancelled
    [[ -z "$QUERY" ]] && exit 0
    
    # Show loading
    (sleep 0.1 && echo "Thinking..." | rofi -dmenu -p "󰧑 AI" -theme "$SIDEBAR_THEME" -lines 1 &) &
    LOADING_PID=$!
    
    # Call OpenAI API
    ESCAPED_QUERY=$(echo "$QUERY" | jq -Rs '.')
    
    RESPONSE=$(curl -s --max-time 30 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [{
                \"role\": \"system\",
                \"content\": \"Be concise and helpful. Use markdown formatting when useful.\"
            },{
                \"role\": \"user\",
                \"content\": $ESCAPED_QUERY
            }],
            \"max_tokens\": $MAX_TOKENS
        }" 2>/dev/null)
    
    # Kill loading if still running
    pkill -P $LOADING_PID 2>/dev/null
    
    # Extract response
    ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
    ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty' 2>/dev/null)
    
    if [[ -n "$ERROR" ]]; then
        ANSWER="Error: $ERROR"
        rm -f "$KEY_FILE"
    elif [[ -z "$ANSWER" ]]; then
        ANSWER="Error: No response from API"
    fi
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Display response (each line as rofi entry)
    CHOICE=$(echo "$ANSWER" | rofi -dmenu -p "󰧑 Response (Enter=new question, Esc=close)" -theme "$SIDEBAR_THEME")
    
    # If user pressed Escape (empty selection), exit
    [[ -z "$CHOICE" ]] && exit 0
done
