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

# Chat loop
while true; do
    # 1. Get User Input (Display History in Message Box)
    # We use -markup-rows and -mesg to show the conversation history
    # The input box is active for the new question
    QUERY=$(rofi -dmenu -p "󰧑 Input" -theme "$SIDEBAR_THEME" -mesg "$HISTORY_TEXT" -lines 0)
    
    # Exit if empty (Esc or empty enter)
    [[ -z "$QUERY" ]] && break
    
    # 2. Show "Thinking..." state
    # We re-open rofi immediately with the same history + "Thinking..." status
    # This creates a "steady" feel by replacing the window with a look-alike
    (
        echo "" | rofi -dmenu -p "󰧑 Thinking" -theme "$SIDEBAR_THEME" \
        -mesg "$HISTORY_TEXT <span foreground='#7aa2f7'><i>(Thinking...)</i></span>" \
        -lines 0 >/dev/null 2>&1
    ) &
    THINK_PID=$!
    
    # 3. Process Input
    # Update JSON history
    TEMP_HIST=$(mktemp)
    jq --arg content "$QUERY" '. + [{"role": "user", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Call API
    ANSWER=$(curl -s --max-time 60 https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"messages\":$(cat "$HISTORY_FILE"),\"max_tokens\":$MAX_TOKENS}" \
        | jq -r '.choices[0].message.content // .error.message // "Error: No response"')
    
    # Update history with answer
    TEMP_HIST=$(mktemp)
    jq --arg content "$ANSWER" '. + [{"role": "assistant", "content": $content}]' "$HISTORY_FILE" > "$TEMP_HIST" && mv "$TEMP_HIST" "$HISTORY_FILE"
    
    # Kill "Thinking..." window
    kill $THINK_PID 2>/dev/null
    
    # Copy to clipboard
    echo "$ANSWER" | xclip -selection clipboard 2>/dev/null
    
    # 4. Update History Display Text
    # We format the JSON into a readable Pango markup string for rofi -mesg
    # Limit to last ~2000 chars to prevent overflow if needed, or rely on rofi scrolling (rofi message box handles some scrolling)
    
    # Generate pretty history string
    HISTORY_TEXT=$(jq -r '
        map(
            if .role == "user" then
                "<span foreground=\"#9ece6a\"><b>User:</b></span> " + (.content | gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;"))
            else
                "<span foreground=\"#c0caf5\"><b>AI:</b></span> " + (.content | gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;"))
            end
        ) | join("\n\n")
    ' "$HISTORY_FILE")

    # The loop continues, immediately showing the new history and prompt
done

# Cleanup
rm -f "$HISTORY_FILE"
exit 0
