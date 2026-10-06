#!/bin/bash
# Re-applies the Antigravity theme after the app updates, and tells you how it went.
#
#   auto-reapply.sh install     register the LaunchAgent (runs this script when /Applications changes)
#   auto-reapply.sh uninstall   remove it
#   auto-reapply.sh run         what launchd runs: check, patch if an update wiped the theme, notify
#
# There is no resident process: launchd starts this only when /Applications (or the app's
# Resources folder) changes, or at login. Most runs exit within milliseconds.
#
# Safety rule: it only quits Antigravity to patch it if the app was opened in the last
# MAX_APP_AGE seconds (which is what an update-triggered relaunch looks like). A long-running
# session is never interrupted; you just get a notification instead.
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="/Applications/Antigravity.app"
ASAR="$APP/Contents/Resources/app.asar"
STATE_DIR="$HOME/.gemini/antigravity"
LOG="$STATE_DIR/auto-reapply.log"
LABEL="com.ryner.antigravity-theme"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
MAX_APP_AGE="${MAX_APP_AGE:-180}"
LOCK_DIR="$STATE_DIR/backups/.theme.lock"

case "${1:-run}" in
install)
    mkdir -p "$HOME/Library/LaunchAgents" "$STATE_DIR"
    cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key>
    <array><string>/bin/bash</string><string>$DIR/auto-reapply.sh</string><string>run</string></array>
    <key>WatchPaths</key>
    <array><string>/Applications</string><string>$APP/Contents/Resources</string></array>
    <key>RunAtLoad</key><true/>
    <key>ThrottleInterval</key><integer>30</integer>
    <key>EnvironmentVariables</key>
    <dict><key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string></dict>
    <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLISTEOF
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$PLIST"
    echo "Installed $LABEL. Log: $LOG"
    exit 0
    ;;
uninstall)
    launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    echo "Removed $LABEL."
    exit 0
    ;;
run) ;;
*) echo "usage: $0 install|uninstall|run"; exit 2 ;;
esac

# ---------- run ----------
mkdir -p "$STATE_DIR"
[ -f "$LOG" ] && [ "$(stat -f%z "$LOG")" -gt 200000 ] && : > "$LOG"
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }
notify() { osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 || true; }

PATCHED_RE="Antigravity (Custom Theme|DOM Walker)"
is_patched() { grep -qE "$PATCHED_RE" "$ASAR" 2>/dev/null; }

[ -f "$STATE_DIR/.theme-disabled" ] && exit 0   # set by revert-antigravity-theme.sh
[ -f "$ASAR" ] || exit 0
is_patched && exit 0                             # the common case: nothing to do

# Wait for the file to stop changing (an update may still be writing it)
last=""
for _ in $(seq 1 30); do
    now="$(stat -f '%z-%m' "$ASAR" 2>/dev/null)"
    [ "$now" = "$last" ] && break
    last="$now"
    sleep 5
done

# Take the same lock as the patcher / update script, then re-check
for _ in $(seq 1 180); do
    mkdir "$LOCK_DIR" 2>/dev/null && break
    [ -n "$(find "$LOCK_DIR" -maxdepth 0 -mmin +10 2>/dev/null)" ] && rm -rf "$LOCK_DIR"
    sleep 1
done
[ -d "$LOCK_DIR" ] || { log "could not take lock"; exit 1; }
trap 'rm -rf "$LOCK_DIR"' EXIT
export AG_LOCK_HELD=1
is_patched && exit 0                             # a manual update finished while we waited

VERSION="$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo unknown)"
log "theme missing on Antigravity $VERSION, re-applying"

WAS_RUNNING=0
PID="$(pgrep -x Antigravity | head -1)"
if [ -n "$PID" ]; then
    WAS_RUNNING=1
    # ps etime format: [[dd-]hh:]mm:ss
    age="$(ps -p "$PID" -o etime= | tr -d ' ' | awk -F'[-:]' '{n=NF; s=$n+$(n-1)*60; if(n>=3)s+=$(n-2)*3600; if(n>=4)s+=$(n-3)*86400; print s}')"
    if [ "${age:-0}" -gt "$MAX_APP_AGE" ]; then
        log "app has been open ${age}s, not interrupting"
        notify "Antigravity updated to $VERSION" "Theme was reset. Not restarting your open session: run update-antigravity.sh when ready."
        exit 0
    fi
    osascript -e 'quit app "Antigravity"' 2>/dev/null || true
    for _ in $(seq 1 15); do pgrep -x Antigravity >/dev/null || break; sleep 1; done
    pkill -f "Antigravity Helper" 2>/dev/null || true
    sleep 1
fi

if "$DIR/apply-antigravity-theme.sh" >> "$LOG" 2>&1; then
    log "theme re-applied on $VERSION"
    [ "$WAS_RUNNING" = 1 ] && open -a Antigravity
    notify "Antigravity updated to $VERSION" "Theme re-applied successfully."
else
    log "PATCH FAILED on $VERSION (see output above)"
    [ "$WAS_RUNNING" = 1 ] && open -a Antigravity
    notify "Antigravity updated to $VERSION" "Theme patch FAILED. The app is unchanged. Ask Claude to diagnose (log: auto-reapply.log)."
    exit 1
fi
