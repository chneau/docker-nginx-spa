#!/bin/sh
# The env var $SUBST is a list of environment variables to substitute
# in the form "VAR1,VAR2,VAR3"

# Split the $SUBST env var into an array
SPLIT=$(echo "$SUBST" | tr "," "\n")

# List all files in /usr/share/nginx/html and all its subdirectories
# and replace the environment variables in each file
# For loops over find output are fragile. Use find -exec or a while read loop.
FILES=$(find /usr/share/nginx/html -type f)
for FILE in $FILES; do
  for VAR in $SPLIT; do
    COUNT=$(grep -c "$VAR" "$FILE")
    if [ "$COUNT" -eq 0 ]; then
      echo "No occurrences of ${VAR} in $FILE"
      continue
    fi
    echo "Replacing $COUNT $VAR by $(printenv "$VAR") in $FILE"
    sed -i "s|$VAR|$(printenv "$VAR")|g" "$FILE"
  done
done

# Start the nginx server
nginx -g "daemon off;"
