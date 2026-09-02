#!/bin/sh
set -eu

HTML_DIR="/usr/share/nginx/html"
PREFIX="${PREFIX:-_}"

# Find text and web-related files to avoid touching binary assets (images, fonts, etc.)
FILES=""
if [ -d "$HTML_DIR" ]; then
  FILES=$(find "$HTML_DIR" -type f \( \
    -name "*.html" -o -name "*.htm" -o \
    -name "*.js"   -o -name "*.mjs" -o \
    -name "*.css"  -o -name "*.json" -o \
    -name "*.svg"  -o -name "*.txt" \
  \) 2>/dev/null || true)
fi

if [ -n "$FILES" ]; then
  # Extract environment variable names starting with PREFIX
  VARS=$(env | grep -E "^${PREFIX}[a-zA-Z0-9_]*=" | sed -E "s/^(${PREFIX}[a-zA-Z0-9_]*)=.*/\1/" || true)

  for VAR in $VARS; do
    TO_REPLACE="${VAR#$PREFIX}"
    [ -z "$TO_REPLACE" ] && continue

    # Retrieve the exact value for the variable
    BY_VALUE=$(eval "printf '%s' \"\${$VAR}\"")

    echo "Replacing $TO_REPLACE by $BY_VALUE"

    # Escape special regex characters in TO_REPLACE for awk literal matching
    ESCAPED_TARGET=$(printf '%s' "$TO_REPLACE" | sed -e 's/[][\/.^$*]/\\&/g')

    # Escape backslashes and ampersands in replacement string for awk gsub
    ESCAPED_REPL=$(printf '%s' "$BY_VALUE" | sed -e 's/[\\&]/\\&/g')

    for FILE in $FILES; do
      if grep -Fq "$TO_REPLACE" "$FILE" 2>/dev/null; then
        echo "==> Replacing in $FILE"
        awk -v s="$ESCAPED_TARGET" -v r="$ESCAPED_REPL" '{gsub(s, r); print}' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
      fi
    done
  done
fi

exec nginx
