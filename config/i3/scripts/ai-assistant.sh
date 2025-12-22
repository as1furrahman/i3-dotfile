#!/bin/bash

# AI Sidebar for i3 - Rofi-based with Tokyo Night theme
# API key stored in ~/.config/openai_api_key

KEY_FILE="$HOME/.config/openai_api_key"
SIDEBAR_THEME="$HOME/.config/rofi/ai-sidebar.rasi"
MODEL="gpt-4o-mini"
MAX_TOKENS=2000

# Function to ensure API key exists
ensure_api_key() {
    if [[ -f "$KEY_FILE" ]]; then
        API_KEY=$(cat "$KEY_FILE" | tr -d '\n')
    fi
    
    if [[ -z "$API_KEY" ]]; then
        API_KEY=$(rofi -dmenu -p " Setup" -theme "$SIDEBAR_THEME" -mesg "Input New API Key" -lines 0)
        [[ -z "$API_KEY" ]] && exit 0
        echo "$API_KEY" > "$KEY_FILE"
        chmod 600 "$KEY_FILE"
    fi
}

# Initial key load
ensure_api_key

# Chat history file
HISTORY_FILE="/tmp/ai_chat_history_$(date +%s).json"
echo "[]" > "$HISTORY_FILE"

# Function to strictly kill previous rofi instances (only on exit/cleanup)
cleanup_rofi() {
    pkill -f "rofi -dmenu.*ai-sidebar.rasi" 2>/dev/null
}
trap cleanup_rofi EXIT

# Chat loop
while true; do
    # 1. Prepare display list from history
    DISPLAY_LIST=""
    if [[ -f "$HISTORY_FILE" ]]; then
        while IFS= read -r line; do
            role=$(echo "$line" | jq -r .role)
            content=$(echo "$line" | jq -r .content)
            
            # Wrap content and escape Pango markup
            wrapped=$(echo "$content" | fold -s -w 65 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
            
            if [[ "$role" == "user" ]]; then
                DISPLAY_LIST+="<span foreground='#9ece6a'><b>User:</b></span>"$'\n'
            else
                DISPLAY_LIST+="<span foreground='#c0caf5'><b>AI:</b></span>"$'\n'
            fi
            
            while IFS= read -r wline; do
                DISPLAY_LIST+="$wline"$'\n'
            done <<< "$wrapped"
            DISPLAY_LIST+=$'\n'
        done < <(jq -c '.[]' "$HISTORY_FILE")
    fi

    # Calculate selection logic...
    if [[ -n "$DISPLAY_LIST" ]]; then
        LINE_COUNT=$(printf "%s" "$DISPLAY_LIST" | grep -c '^')
        LAST_ROW=$((LINE_COUNT - 1))
        [[ $LAST_ROW -lt 0 ]] && LAST_ROW=0
        ROFI_ARGS=(-markup-rows -selected-row "$LAST_ROW")
    else
        ROFI_ARGS=(-markup-rows)
    fi

    # 2. Get User Input
    QUERY=$(printf "%s" "$DISPLAY_LIST" | rofi -dmenu -p "󰧑 Input" -theme "$SIDEBAR_THEME" \
        -mesg "<i>Type to chat... (Up/Down to scroll history)</i>" \
        "${ROFI_ARGS[@]}")
    
    [[ -z "$QUERY" ]] && break
    
    # Check if user selected history line...
    if echo "$DISPLAY_LIST" | grep -Fqx "$QUERY"; then
        echo "$QUERY" | sed 's/<[^>]*>//g' | xclip -selection clipboard 2>/dev/null
        continue
    fi
    
    # 3. Show "Thinking..."
    notify-send -u low -t 3000 "AI Assistant" "Thinking..."
    
    # 4. Process API Request
    # Update history with user query
    TEMP_HIST=$(mktemp)
    if [[ -s "$HISTORY_FILE" ]]; then
        jq --arg content "$QUERY" '. + [{"role": "user", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST"
    else
        jq -n --arg content "$QUERY" '[{"role": "user", "content": $content}]' > "$TEMP_HIST"
    fi
    mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Perform Request with Status Check
    HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":$(cat "$HISTORY_FILE"),\"max_tokens\":$MAX_TOKENS}")
    
    HTTP_CODE=$(echo "$HTTP_RESPONSE" | tail -n1)
    JSON_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" == "401" ]]; then
        # INVALID KEY DETECTED
        # Silently reset and re-prompt
        rm -f "$KEY_FILE"
        API_KEY=""
        
        # Immediate prompt
        ensure_api_key
        continue
    fi
    
    # Parse Answer
    ANSWER=$(echo "$JSON_BODY" | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    # Update history with AI answer
    TEMP_HIST=$(mktemp)
    jq --arg content "$ANSWER" '. + [{"role": "assistant", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    sleep 0.1
done

rm -f "$HISTORY_FILE"
exit 0
