#!/bin/sh
set -eu

LOG="/opt/mcstatus/mcstatus.log"
touch "$LOG" 2>/dev/null || true
chmod 664 "$LOG" 2>/dev/null || true

if [ -f /opt/mcstatus/.env ]; then
  set -a
  . /opt/mcstatus/.env
  set +a
else
  echo "$(date -Is) ERROR: /opt/mcstatus/.env missing" >> "$LOG"
  exit 1
fi

export PATH="$HOME/.local/bin:$PATH"

: "${SERVER_IP:=}"
: "${WEBHOOK_URL:=}"
: "${INTERVAL:=300}"

if [ -z "$WEBHOOK_URL" ]; then
  echo "$(date -Is) ERROR: WEBHOOK_URL is required" >> "$LOG"
  exit 1
fi
if [ -z "$SERVER_IP" ]; then
  echo "$(date -Is) ERROR: SERVER_IP is required" >> "$LOG"
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "$(date -Is) ERROR: uv not found in PATH ($PATH)" >> "$LOG"
  exit 1
fi

echo "$(date -Is) run.sh starting; interval=$INTERVAL; addr=$SERVER_IP; user=$(id -un)" >> "$LOG"

while true; do
  echo "$(date -Is) running mc_cron_notify.py" >> "$LOG"
  ( cd /opt/mcstatus && uv run python mc_cron_notify.py ) >> "$LOG" 2>&1 || {
    echo "$(date -Is) ERROR: mc_cron_notify.py exited non-zero" >> "$LOG"
  }
  sleep "$INTERVAL"
done
