#!/usr/bin/env python3
import os
import json
import requests
from dotenv import load_dotenv
from mcstatus import JavaServer

load_dotenv()

MC_ADDRESS = os.getenv("SERVER_IP")
WEBHOOK_URL = os.getenv("WEBHOOK_URL")
STATE_FILE = os.getenv("STATE_FILE", "/tmp/mc_status.json")

if not WEBHOOK_URL:
    raise SystemExit("Please set WEBHOOK_URL environment variable")

def check_status():
    try:
        server = JavaServer.lookup(MC_ADDRESS)
        status = server.status()
        return {
            "up": True,
            "players": status.players.online,
            "motd": str(status.description),
        }
    except Exception as e:
        return {
            "up": False,
            "error": str(e),
        }

def load_state():
    if not os.path.exists(STATE_FILE):
        return None
    try:
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    except Exception:
        return None

def save_state(state):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except Exception:
        pass

def send_discord(msg):
    try:
        requests.post(WEBHOOK_URL, json={"content": msg}, timeout=5)
    except Exception as e:
        print(f"Failed to send Discord webhook: {e}")

def main():
    new_state = check_status()
    old_state = load_state()

    if old_state is None or new_state["up"] != old_state.get("up"):
        if new_state["up"]:
            msg = f"✅ **UP** — `{MC_ADDRESS}` | {new_state['players']} players online\nMOTD: {new_state['motd']}"
        else:
            msg = f"❌ **DOWN** — `{MC_ADDRESS}` ({new_state.get('error')})"
        send_discord(msg)

    save_state(new_state)

if __name__ == "__main__":
    main()
