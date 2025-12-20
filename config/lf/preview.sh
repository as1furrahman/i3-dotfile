#!/bin/bash
# lf file preview script

file="$1"
w="$2"
h="$3"

case "$(file -Lb --mime-type "$file")" in
    text/*|application/json|application/javascript)
        head -n "$h" "$file"
        ;;
    image/*)
        echo "Image: $(file -b "$file")"
        ;;
    application/pdf)
        pdftotext -l 1 -nopgbrk "$file" - 2>/dev/null | head -n "$h"
        ;;
    application/zip)
        unzip -l "$file" | head -n "$h"
        ;;
    application/gzip|application/x-tar)
        tar -tf "$file" | head -n "$h"
        ;;
    *)
        file -b "$file"
        ;;
esac
