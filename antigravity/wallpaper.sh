#!/bin/bash
# Pick the Antigravity background video from the videos in ~/Movies.
#
#   wallpaper                 interactive picker (fzf if installed, otherwise a numbered menu)
#   wallpaper list            numbered list, current one marked
#   wallpaper set <n|name>    set by list number, filename substring, or full path
#   wallpaper current         show the current video
#
# How it works: the theme patch points the app at a fixed symlink (LINK below), so switching
# videos is just re-pointing the symlink. No re-patch, no app restart. If Antigravity is
# running, the video element is reloaded live over the app's debug port; otherwise press Cmd+R.
set -u

MOVIES="${WALLPAPER_DIR:-$HOME/Movies}"
LINK="$HOME/.gemini/antigravity/wallpaper.mp4"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

videos() { find "$MOVIES" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.m4v' \) | sort; }
current() { [ -L "$LINK" ] && readlink "$LINK"; }

describe() {  # path -> "name  (3840x2160, 69M)"
    local f="$1" w h sz
    w=$(mdls -raw -name kMDItemPixelWidth "$f" 2>/dev/null); h=$(mdls -raw -name kMDItemPixelHeight "$f" 2>/dev/null)
    sz=$(du -h "$f" | awk '{print $1}')
    [[ "$w" =~ ^[0-9]+$ ]] && echo "$(basename "$f")  (${w}x${h}, $sz)" || echo "$(basename "$f")  ($sz)"
}

list() {
    local cur n=0 f; cur="$(current)"
    while IFS= read -r f; do
        n=$((n+1))
        printf '%s %2d  %s\n' "$([ "$f" = "$cur" ] && echo '*' || echo ' ')" "$n" "$(describe "$f")"
    done < <(videos)
    [ "$n" -eq 0 ] && echo "No .mp4/.webm/.m4v files in $MOVIES" && return 1
    echo; echo "(* = current)"
}

reload_live() {
    command -v node >/dev/null || return 1
    local port=""
    for p in $(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk '/Antigravi/ {print $9}' | sed 's/.*://'); do
        curl -s -m 2 "http://localhost:$p/json" 2>/dev/null | grep -q webSocketDebuggerUrl && { port=$p; break; }
    done
    [ -z "$port" ] && return 1
    DBG_PORT="$port" node --input-type=module - <<'EOF' 2>/dev/null
const targets = await (await fetch(`http://localhost:${process.env.DBG_PORT}/json`)).json();
const t = targets.find(x => x.type === 'page' && x.url.startsWith('https://127.0.0.1'));
if (!t) process.exit(1);
const ws = new WebSocket(t.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id === 1) { ws.close(); process.exit(m.result?.result?.value === 'ok' ? 0 : 1); } };
// The query string defeats any URL-keyed media cache; file:// ignores it.
ws.send(JSON.stringify({ id: 1, method: 'Runtime.evaluate', params: { returnByValue: true, expression:
  `(()=>{const v=document.getElementById('antigravity-video-bg');if(!v)return 'novideo';const b=v.src.split('?')[0];v.src=b+'?'+Date.now();v.load();v.play().catch(()=>{});return 'ok'})()` } }));
setTimeout(() => process.exit(1), 5000);
EOF
}

set_video() {
    local arg="$1" f="" n=0 cand
    if [ -f "$arg" ]; then f="$arg"
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then f="$(videos | sed -n "${arg}p")"
    else
        while IFS= read -r cand; do
            case "$(basename "$cand" | tr '[:upper:]' '[:lower:]')" in *"$(echo "$arg" | tr '[:upper:]' '[:lower:]')"*) f="$cand"; n=$((n+1));; esac
        done < <(videos)
        [ "$n" -gt 1 ] && { echo "'$arg' matches $n videos; be more specific or use the number:"; list; return 1; }
    fi
    [ -n "$f" ] && [ -f "$f" ] || { echo "No video matches '$arg'"; list; return 1; }
    f="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"

    mkdir -p "$(dirname "$LINK")"
    ln -sfn "$f" "$LINK"
    echo "Wallpaper -> $(describe "$f")"
    if pgrep -x Antigravity >/dev/null; then
        if reload_live; then echo "Reloaded live in Antigravity."
        else echo "Antigravity is open: press Cmd+R in it to load the new video."; fi
    fi
}

pick() {
    local sel
    if command -v fzf >/dev/null; then
        sel=$(videos | while IFS= read -r f; do printf '%s\t%s\n' "$f" "$(describe "$f")"; done \
              | fzf --delimiter='\t' --with-nth=2 --prompt='wallpaper> ' --height=40% --reverse | cut -f1)
        [ -n "$sel" ] && set_video "$sel"
    else
        list || return 1
        local n; read -r -p "Pick a number (blank to cancel): " n
        [ -n "$n" ] && set_video "$n"
    fi
}

case "${1:-pick}" in
    pick)    pick ;;
    list)    list ;;
    current) c="$(current)"; [ -n "$c" ] && describe "$c" || echo "No wallpaper set" ;;
    set)     [ -n "${2:-}" ] || { echo "usage: wallpaper set <number|name|path>"; exit 2; }; shift; set_video "$*" ;;
    *)       set_video "$*" ;;
esac
