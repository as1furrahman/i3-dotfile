#!/bin/bash

# AI Assistant for i3 using OpenAI GPT API
# Triggered via rofi, displays response in rofi popup
# 
# API key is stored in ~/.config/openai_api_key

# Configuration
KEY_FILE="$HOME/.config/openai_api_key"
MODEL="gpt-4o-mini"  # Fast and cheap, change to "gpt-4o" for better quality
MAX_TOKENS=500

# Load API key from file or environment
if [[ -f "$KEY_FILE" ]]; then
    API_KEY=$(cat "$KEY_FILE" | tr -d '\n')
else
    API_KEY="${OPENAI_API_KEY:-}"
fi

# If no API key, prompt user to enter one
if [[ -z "$API_KEY" ]]; then
    API_KEY=$(rofi -dmenu -p "󰌆 Enter OpenAI API Key" -password -theme-str 'window {width: 50%;} listview {lines: 0;}')
    
    if [[ -z "$API_KEY" ]]; then
        exit 0  # User cancelled
    fi
    
    # Save API key for future use
    mkdir -p "$(dirname "$KEY_FILE")"
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Get user input via rofi
QUERY=$(rofi -dmenu -p "󰧑 Ask AI" -theme-str 'window {width: 50%;} listview {lines: 0;}')

# Exit if no input
[[ -z "$QUERY" ]] && exit 0

# Escape query for JSON
ESCAPED_QUERY=$(echo "$QUERY" | jq -Rs '.')

# Call OpenAI API
RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": $ESCAPED_QUERY}],
        \"max_tokens\": $MAX_TOKENS,
        \"temperature\": 0.7
    }" 2>/dev/null)

# Extract response text
ANSWER=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // .error.message // "Error: No response"' 2>/dev/null)

if [[ -z "$ANSWER" || "$ANSWER" == "null" ]]; then
    ANSWER="Error: Failed to get response. Check your API key."
    # Remove saved key if it failed
    rm -f "$KEY_FILE"
fi

# Display response in rofi (scrollable)
echo "$ANSWER" | rofi -dmenu -p "󰧑 AI" -theme-str 'window {width: 60%;} listview {lines: 15;}'

# Also copy to clipboard
echo "$ANSWER" | xclip -selection clipboard 2>/dev/null || echo "$ANSWER" | wl-copy 2>/dev/null
