#!/bin/bash
# lf file previewer script
# Usage: preview.sh <file>

file="$1"
w="$2"
h="$3"
x="$4"
y="$5"

# Handle file extensions first
case "$file" in
    *.tar*) tar tf "$file";;
    *.zip) unzip -l "$file";;
    *.rar) unrar l "$file";;
    *.7z) 7z l "$file";;
    *.pdf)
        pdftotext "$file" - 2>/dev/null | head -100
        ;;
    *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.webp|*.ico)
        echo "Image: $(file -b "$file")"
        echo ""
        identify "$file" 2>/dev/null || file -b "$file"
        ;;
    *.svg)
        echo "SVG Image"
        head -20 "$file"
        ;;
    *.mp3|*.flac|*.wav|*.ogg|*.m4a)
        mediainfo "$file" 2>/dev/null || file -b "$file"
        ;;
    *.mp4|*.mkv|*.avi|*.webm|*.mov)
        mediainfo "$file" 2>/dev/null || file -b "$file"
        ;;
    *.md|*.markdown)
        glow -s dark "$file" 2>/dev/null || cat "$file"
        ;;
    *.json)
        jq -C '.' "$file" 2>/dev/null || cat "$file"
        ;;
    *.csv)
        head -50 "$file" | column -t -s','
        ;;
    *.html|*.htm)
        w3m -dump "$file" 2>/dev/null || cat "$file"
        ;;
    *)
        # Default: use file type detection
        mime=$(file --mime-type -b "$file")
        case "$mime" in
            text/*|application/json|application/xml|application/javascript)
                bat --theme="TwoDark" --style=numbers,changes --color=always "$file" 2>/dev/null || cat "$file"
                ;;
            application/pdf)
                pdftotext "$file" - 2>/dev/null | head -100
                ;;
            image/*)
                echo "Image: $(file -b "$file")"
                identify "$file" 2>/dev/null || file -b "$file"
                ;;
            inode/directory)
                ls -la --color=always "$file"
                ;;
            *)
                file -b "$file"
                echo ""
                echo "Binary file - no preview available"
                ;;
        esac
        ;;
esac
