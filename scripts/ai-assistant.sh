#!/bin/bash

# AI Assistant for i3 using OpenAI GPT API
# Triggered via rofi, displays response in rofi popup
# 
# Setup: Set your API key as environment variable:
#   export OPENAI_API_KEY="your-api-key"
#   Add to ~/.zshrc or ~/.bashrc

# Configuration
API_KEY="${OPENAI_API_KEY:-}"
MODEL="gpt-4o-mini"  # Fast and cheap, change to "gpt-4o" for better quality
MAX_TOKENS=500

# Check for API key
if [[ -z "$API_KEY" ]]; then
    echo "OPENAI_API_KEY not set! Add to ~/.zshrc" | rofi -dmenu -p "󰀩 Error" -theme-str 'window {width: 50%;}'
    exit 1
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
    ANSWER="Error: Failed to get response from API"
fi

# Display response in rofi (scrollable)
echo "$ANSWER" | rofi -dmenu -p "󰧑 AI" -theme-str 'window {width: 60%;} listview {lines: 15;}'

# Also copy to clipboard
echo "$ANSWER" | xclip -selection clipboard 2>/dev/null || echo "$ANSWER" | wl-copy 2>/dev/null
