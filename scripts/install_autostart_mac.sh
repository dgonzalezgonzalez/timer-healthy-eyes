#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$PLIST_DIR/com.ojosaurio.timer.plist"
LABEL="com.ojosaurio.timer"
APP_BIN="$REPO_ROOT/.venv/bin/twenty20-beeper"
GUI_DOMAIN="gui/$(id -u)"

mkdir -p "$PLIST_DIR"

if [ ! -x "$APP_BIN" ]; then
  if [ ! -d "$REPO_ROOT/.venv" ]; then
    python3 -m venv "$REPO_ROOT/.venv"
  fi
  "$REPO_ROOT/.venv/bin/pip" install -e "$REPO_ROOT"
fi

cat >"$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$APP_BIN</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$REPO_ROOT</string>
  <key>RunAtLoad</key>
  <true/>
  <key>LimitLoadToSessionType</key>
  <array>
    <string>Aqua</string>
  </array>
  <key>KeepAlive</key>
  <false/>
  <key>StandardOutPath</key>
  <string>/tmp/ojosaurio.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/ojosaurio.err.log</string>
</dict>
</plist>
EOF

launchctl bootout "$GUI_DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootout "$GUI_DOMAIN" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "$GUI_DOMAIN" "$PLIST_PATH"
launchctl enable "$GUI_DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl kickstart -k "$GUI_DOMAIN/$LABEL"

echo "Autostart enabled on macOS."
echo "Check status with: launchctl print $GUI_DOMAIN/$LABEL | head -n 20"
