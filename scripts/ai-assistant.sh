#!/bin/bash

# AI Sidebar for i3 using OpenAI GPT API
# Appears as sidebar panel on right side of screen
# 
# API key is stored in ~/.config/openai_api_key

# Configuration
KEY_FILE="$HOME/.config/openai_api_key"
SIDEBAR_THEME="$HOME/.config/rofi/ai-sidebar.rasi"
MODEL="gpt-4o-mini"  # Fast and cheap, change to "gpt-4o" for better quality
MAX_TOKENS=1000

# Load API key from file or environment
if [[ -f "$KEY_FILE" ]]; then
    API_KEY=$(cat "$KEY_FILE" | tr -d '\n')
else
    API_KEY="${OPENAI_API_KEY:-}"
fi

# If no API key, prompt user to enter one
if [[ -z "$API_KEY" ]]; then
    API_KEY=$(rofi -dmenu -p "󰌆 API Key" -password -theme "$SIDEBAR_THEME")
    
    if [[ -z "$API_KEY" ]]; then
        exit 0  # User cancelled
    fi
    
    # Save API key for future use
    mkdir -p "$(dirname "$KEY_FILE")"
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Get user input via rofi sidebar
QUERY=$(rofi -dmenu -p "󰧑 AI" -theme "$SIDEBAR_THEME")

# Exit if no input
[[ -z "$QUERY" ]] && exit 0

# Call OpenAI API
ESCAPED_QUERY=$(echo "$QUERY" | jq -Rs '.')

RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{
            \"role\": \"system\",
            \"content\": \"You are a helpful AI assistant. Be concise but thorough. Format responses with clear structure when appropriate.\"
        },{
            \"role\": \"user\",
            \"content\": $ESCAPED_QUERY
        }],
        \"max_tokens\": $MAX_TOKENS,
        \"temperature\": 0.7
    }" 2>/dev/null)

# Extract response text
ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // .error.message // "Error: No response"' 2>/dev/null)

if [[ -z "$ANSWER" || "$ANSWER" == "null" ]]; then
    ANSWER="Error: API call failed. Your key may be invalid."
    rm -f "$KEY_FILE"
fi

# Display response in sidebar (line by line for scrolling)
echo -e "$ANSWER" | rofi -dmenu -p "󰧑 Response" -theme "$SIDEBAR_THEME"

# Copy to clipboard
echo "$ANSWER" | xclip -selection clipboard 2>/dev/null || echo "$ANSWER" | wl-copy 2>/dev/null
