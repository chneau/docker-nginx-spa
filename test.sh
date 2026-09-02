#!/bin/sh
set -eu

IMAGE_NAME="${1:-test-nginx-spa}"
CONTAINER_NAME="nginx-spa-test-run"
PORT="8080"

# Cleanup on exit
trap 'docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true' EXIT

echo "Starting container from image: $IMAGE_NAME..."
docker run -d --name "$CONTAINER_NAME" \
  -e _nginx="HACKED" \
  -p "$PORT":8080 "$IMAGE_NAME"

echo "Waiting for container to start..."
sleep 2

echo "Fetching page..."
BODY=$(curl -s "http://127.0.0.1:$PORT/")

if echo "$BODY" | grep -q "HACKED"; then
  echo "✅ Verification successful: 'nginx' replaced by 'HACKED' in output!"
else
  echo "❌ Verification failed: 'HACKED' not found in response:"
  echo "$BODY"
  exit 1
fi
