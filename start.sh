#!/bin/sh

FILES=$(find /usr/share/nginx/html -type f)
for VAR in $(printenv | grep "^$PREFIX" | awk -F "=" '{print $1}'); do
  TO_REPLACE=$(echo "$VAR" | sed "s/^$PREFIX//")
  BY_VALUE=$(printenv "$VAR")
  echo "Replacing $TO_REPLACE by $BY_VALUE"
  for FILE in $FILES; do
    COUNT=$(grep -c "$TO_REPLACE" "$FILE")
    if [ "$COUNT" -eq 0 ]; then continue; fi
    echo "==> Replacing $COUNT in $FILE"
    sed -i "s|$TO_REPLACE|$BY_VALUE|g" "$FILE"
  done
done

nginx -g "daemon off;"
