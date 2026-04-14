#!/usr/bin/env bash
set -euo pipefail

PLIST_PATH="$HOME/Library/LaunchAgents/com.ojosaurio.timer.plist"
LABEL="com.ojosaurio.timer"
GUI_DOMAIN="gui/$(id -u)"

if [ -f "$PLIST_PATH" ]; then
  launchctl bootout "$GUI_DOMAIN/$LABEL" >/dev/null 2>&1 || true
  launchctl bootout "$GUI_DOMAIN" "$PLIST_PATH" >/dev/null 2>&1 || true
  rm -f "$PLIST_PATH"
fi

echo "Autostart disabled on macOS."
