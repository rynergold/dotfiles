#!/bin/bash
# Live video wallpaper for the desktop (shows through a transparent Ghostty).
#
#   desktop-video.sh install     compile the player and start it now + at every login
#   desktop-video.sh uninstall   stop it and remove everything it installed
#   desktop-video.sh stop        stop it and keep it off (also at login) until you run start
#   desktop-video.sh start       turn it back on
#   desktop-video.sh restart     recompile and restart (after editing the Swift file)
#   desktop-video.sh status      is it running, and how much is it using
#
# Which video plays is chosen with agy-wallpaper (same selection as Antigravity); changes apply live.
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DIR/agy-desktop-video.swift"
BIN_DIR="$HOME/.local/share/agy-desktop-video"
BIN="$BIN_DIR/agy-desktop-video"
LABEL="com.ryner.agy-desktop-video"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

build() {
    mkdir -p "$BIN_DIR"
    swiftc -O "$SRC" -o "$BIN" || { echo "Compile failed"; exit 1; }
}

write_plist() {
    mkdir -p "$HOME/Library/LaunchAgents"
    cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key><array><string>$BIN</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>ThrottleInterval</key><integer>10</integer>
    <key>LimitLoadToSessionType</key><string>Aqua</string>
    <key>ProcessType</key><string>Background</string>
    <key>StandardErrorPath</key><string>$HOME/.gemini/antigravity/desktop-video.log</string>
</dict>
</plist>
PLISTEOF
}

stop() { launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true; }
start() { launchctl enable "$DOMAIN/$LABEL" 2>/dev/null || true; launchctl bootstrap "$DOMAIN" "$PLIST"; }

case "${1:-status}" in
install)
    [ -L "$HOME/.gemini/antigravity/wallpaper.mp4" ] || echo "Note: no wallpaper set yet. Pick one with: agy-wallpaper"
    build; write_plist; stop; start
    echo "Installed and running. Make Ghostty see-through to show it (background-opacity in ghostty/config)."
    ;;
restart)
    stop; build; start; echo "Restarted."
    ;;
off|stop)
    stop; launchctl disable "$DOMAIN/$LABEL" 2>/dev/null || true
    echo "Stopped and disabled (it will not start at login). Turn it back on with: desktop-video.sh start"
    ;;
on|start)
    [ -x "$BIN" ] || { echo "Not installed; run: desktop-video.sh install"; exit 1; }
    start; echo "Started."
    ;;
uninstall)
    stop; rm -f "$PLIST"; rm -rf "$BIN_DIR"
    echo "Removed $LABEL and its binary. (Your video files and the Ghostty config are untouched.)"
    ;;
status)
    if pgrep -f "$BIN" >/dev/null; then
        pid="$(pgrep -f "$BIN" | head -1)"
        echo "running (pid $pid): $(ps -p "$pid" -o %cpu=,rss= | awk '{printf "%.1f%% cpu, %d MB", $1, $2/1024}')"
        echo "video: $(readlink "$HOME/.gemini/antigravity/wallpaper.mp4" 2>/dev/null || echo none)"
    else
        echo "not running"
    fi
    ;;
*) echo "usage: $0 install|uninstall|start|stop|restart|status"; exit 2 ;;
esac
