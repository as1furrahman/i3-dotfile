#!/bin/bash

# AI Sidebar for i3 - Persistent window version
# Uses zenity for persistent dialog that stays open

KEY_FILE="$HOME/.config/openai_api_key"
MODEL="gpt-4o-mini"
MAX_TOKENS=2000

# Load or prompt for API key
[[ -f "$KEY_FILE" ]] && API_KEY=$(cat "$KEY_FILE" | tr -d '\n')

if [[ -z "$API_KEY" ]]; then
    API_KEY=$(zenity --entry --title="AI Setup" --text="Enter OpenAI API Key:" --hide-text --width=400 2>/dev/null)
    [[ -z "$API_KEY" ]] && exit 0
    echo "$API_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

# Main function
ask_ai() {
    local query="$1"
    curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":$(echo "$query" | jq -Rs '.')}],\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"'
}

# Chat loop
while true; do
    # Get question
    QUERY=$(zenity --entry --title="󰧑 AI Assistant" --text="Ask anything:" --width=500 2>/dev/null)
    [[ -z "$QUERY" ]] && exit 0
    
    # Show loading (background process)
    zenity --info --title="AI" --text="Thinking... Please wait." --width=300 --timeout=2 2>/dev/null &
    LOADING_PID=$!
    
    # Get response
    ANSWER=$(ask_ai "$QUERY")
    
    # Kill loading if still running
    kill $LOADING_PID 2>/dev/null
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # Show response in scrollable window with buttons
    zenity --text-info --title="󰧑 AI Response (copied to clipboard)" --width=600 --height=500 \
        --ok-label="New Question" --cancel-label="Close" --font="Cascadia Code" 2>/dev/null <<< "$ANSWER"
    
    # Exit if user clicked Close (exit code 1)
    [[ $? -ne 0 ]] && exit 0
done
