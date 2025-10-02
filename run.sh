#!/bin/sh

set -eu

ENV_FILE="/opt/mcstatus/.env"
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

if [ -z "$WEBHOOK_URL" ]; then
  echo "WEBHOOK_URL is required (set it in /opt/mcstatus/.env)" >&2
  exit 1
fi

export PATH="$HOME/.local/bin:$PATH"

while true; do
  uv run python mcstatus.py
  sleep "$INTERVAL"
done
