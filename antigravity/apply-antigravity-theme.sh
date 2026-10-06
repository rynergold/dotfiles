#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_DIR="$HOME/.gemini/antigravity/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_PATH="$BACKUP_DIR/app.asar.original"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)
VIDEO_PATH="/Users/ryner/Movies/animestudy.mp4"

echo "=== Antigravity Desktop Custom Theme Patcher (VIDEO EDITION) ==="

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Antigravity app not found at $APP_PATH"
  exit 1
fi

# If a legacy in-bundle pristine backup exists, migrate it to the safe backup directory
if [ -f "$RESOURCES_DIR/app.asar.original" ]; then
    if [ ! -f "$BACKUP_PATH" ]; then
        echo "Migrating legacy in-bundle backup to safe backup location: $BACKUP_PATH..."
        cp "$RESOURCES_DIR/app.asar.original" "$BACKUP_PATH"
    fi
    rm -f "$RESOURCES_DIR/app.asar.original"
fi
if [ -f "$RESOURCES_DIR/app.asar.bak" ]; then
    if [ ! -f "$BACKUP_PATH" ]; then
        echo "Migrating legacy in-bundle backup to safe backup location: $BACKUP_PATH..."
        cp "$RESOURCES_DIR/app.asar.bak" "$BACKUP_PATH"
    fi
    rm -f "$RESOURCES_DIR/app.asar.bak"
fi

echo "Checking ASAR state..."
CURRENT_VERSION=$(defaults read "$APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")

# Match both the current marker and the legacy "DOM Walker" one so old patches are still detected
if grep -qE "Antigravity (Custom Theme|DOM Walker)" "$ASAR_PATH"; then
    if [ ! -f "$BACKUP_PATH" ]; then
        echo "Error: Current app.asar is patched, but no backup exists to restore from!"
        exit 1
    fi
    echo "Current app.asar is already patched (version $CURRENT_VERSION). Restoring from pristine backup..."
    cp "$BACKUP_PATH" "$ASAR_PATH"
else
    echo "Current app.asar is pristine (version $CURRENT_VERSION). Creating backup at $BACKUP_PATH..."
    cp "$ASAR_PATH" "$BACKUP_PATH"
    echo "$CURRENT_VERSION" > "$BACKUP_DIR/version.txt"
fi

echo "Extracting app.asar..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

PRELOAD_JS="$TMP_DIR/app/dist/preload.js"
UTILS_JS="$TMP_DIR/app/dist/utils.js"

echo "Injecting theme CSS and Video Background into preload.js..."
cat << 'INNER_EOF' >> "$PRELOAD_JS"

// ==========================================
// Antigravity Custom Theme (video background + readable panels)
// ==========================================
;(function() {
  function injectBaseCss() {
    let style = document.getElementById('antigravity-custom-css');
    if (!style) {
      style = document.createElement('style');
      style.id = 'antigravity-custom-css';
      (document.head || document.documentElement).appendChild(style);
    }

    style.textContent = `
      /* =========================================
         Custom Font: Mononoki
         ========================================= */
      @font-face {
        font-family: 'Mononoki';
        src: url('file:///Users/ryner/Documents/fonts/mononoki_extracted/mononoki-Regular.ttf') format('truetype');
        font-weight: normal;
        font-style: normal;
      }
      @font-face {
        font-family: 'Mononoki';
        src: url('file:///Users/ryner/Documents/fonts/mononoki_extracted/mononoki-Bold.ttf') format('truetype');
        font-weight: bold;
        font-style: normal;
      }
      @font-face {
        font-family: 'Mononoki';
        src: url('file:///Users/ryner/Documents/fonts/mononoki_extracted/mononoki-Italic.ttf') format('truetype');
        font-weight: normal;
        font-style: italic;
      }
      html body, html body p, html body span, html body div, html body a, html body button, html body code, html body pre, html body .monaco-editor, html body .xterm, html body .xterm-screen, html body textarea, html body input {
        font-family: 'Mononoki', monospace;
      }

      /* =========================================
         THEME TOKENS
         The app is Tailwind v4 driven by ~14 CSS variables (bg-background = var(--background),
         bg-sidebar = var(--sidebar), ...). Overriding the variables re-themes everything,
         including gradient fades, with no per-element selectors and no DOM walking.
         Custom properties set !important here beat the app's own :root block.
         Tune the whole look with the two --ag-* values.
         ========================================= */
      html:root {
        --ag-tint:  rgba(18, 18, 18, 0.93);  /* sidebars, right pane, top bars */
        --ag-panel: rgba(18, 18, 18, 0.60);  /* chat column */

        --background: transparent !important;                  /* video shows through the main area */
        --sidebar: var(--ag-tint) !important;
        --sidebar-secondary: rgba(45, 45, 45, 0.85) !important;
        --sidebar-muted: rgba(255, 255, 255, 0.08) !important; /* row hover */
        --card: rgba(24, 24, 24, 0.92) !important;             /* input box, tooltips, menus */
        --card-border: rgba(34, 34, 34, 0.92) !important;
        --muted: rgba(21, 21, 21, 0.85) !important;
      }

      html, body, html body #root, html body #app {
        background-color: transparent;
        background-image: none;
      }

      /* Chat column: one calm tint instead of per-message boxes */
      html body [data-testid="conversation-view"] {
        background-color: var(--ag-panel);
      }

      /* Regions that used bg-background (now transparent) but need a backing:
         the two top bars and the whole right pane (header + body). */
      html body div[class*="select-none"][class*="justify-between"][class*="overflow-hidden"]:has([data-testid="install-editor"]),
      html body div:has(> div[class*="border-b"][class*="pr-[72px]"]) {
        background-color: var(--ag-tint);
      }

      /* Section headers carry the .bg-sidebar token; scope the variable so they don't double-tint */
      html body div[class*="section-header"] {
        --sidebar: transparent !important;
      }

      /* Sidebar row hover actions: small dark pill instead of an opaque gradient fade */
      html body [data-testid="conversation-row-sidebar"] div[class*="group-hover:opacity-100"] {
        background-image: none;
        background-color: var(--ag-tint);
        border-radius: 8px;
      }

      /* xterm sets an inline opaque background-color, so this one needs !important */
      html body .xterm-scrollable-element,
      html body .xterm-viewport {
        background-color: var(--ag-tint) !important;
      }

      /* =========================================
         Readability, chips, misc
         ========================================= */
      html body div[role="article"] {
        text-shadow: 0px 2px 5px rgba(0,0,0, 0.9), 0px 0px 2px rgba(0,0,0, 0.8);
      }
      html body pre, html body code, html body .monaco-editor, html body .xterm, html body .xterm-screen {
        text-shadow: none;
      }

      html body span.context-scope-mention {
        background-color: transparent;
      }
      html body button:has(> span.context-scope-mention) {
        background-color: rgba(60, 60, 60, 0.4);
        border: 1px solid rgba(255, 255, 255, 0.1);
      }

      html body [aria-label="File Viewer"],
      html body [aria-label="File Viewer"] > div {
        background-color: var(--ag-tint);
      }

      /* Hide the ghost loading spinner behind the terminal */
      html body [data-testid*="terminal"] > .absolute.inset-0.flex,
      html body [data-testid*="terminal"] .animate-spin {
        display: none;
      }

      /* Hover pop-up for cards (sidebar items excluded) */
      html body [data-testid="lifted-context-menu-trigger"]:not(:has([data-testid*="sidebar"])),
      html body .bg-card-border:not(:has([data-testid*="sidebar"])) {
        transition: transform 0.2s cubic-bezier(0.2, 0.8, 0.2, 1), box-shadow 0.2s cubic-bezier(0.2, 0.8, 0.2, 1);
      }
      html body [data-testid="lifted-context-menu-trigger"]:not(:has([data-testid*="sidebar"])):hover,
      html body .bg-card-border:not(:has([data-testid*="sidebar"])):hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
        z-index: 50;
      }

      /* =========================================
         SIDEBAR STATUS BAR HEADERS (tagged by tagStatusHeaders below)
         ========================================= */
      button[data-project-card="true"][data-status-header="in-progress"] {
        background-color: rgba(255, 255, 255, 0.04);
        border-left: 4px solid #fe8019;
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        color: #fe8019;
        padding-left: 10px;
      }
      button[data-project-card="true"][data-status-header="in-progress"] span,
      button[data-project-card="true"][data-status-header="in-progress"] svg {
        color: #fe8019;
      }
      button[data-project-card="true"][data-status-header="in-progress"]:hover {
        background-color: rgba(254, 128, 25, 0.10);
        color: #fe8019;
      }
      button[data-project-card="true"][data-status-header="idle"] {
        background-color: rgba(255, 255, 255, 0.02);
        border-left: 4px solid rgba(131, 165, 152, 0.6);
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
        border-top-right-radius: 8px;
        border-bottom-right-radius: 8px;
        color: #83a598;
        padding-left: 10px;
      }
      button[data-project-card="true"][data-status-header="idle"] span,
      button[data-project-card="true"][data-status-header="idle"] svg {
        color: #83a598;
      }
      button[data-project-card="true"][data-status-header="idle"]:hover {
        background-color: rgba(131, 165, 152, 0.08);
        color: #83a598;
      }

      /* =========================================
         SENT MESSAGES & STICKY WRAPPER
         ========================================= */
      html body div[role="article"],
      html body div[role="article"] > div,
      html body div[role="article"] div[class*="sticky"],
      html body div[role="article"] div[class*="sticky-message"],
      html body div[role="article"] div:has(> div > [data-testid="user-input-step"]),
      html body div[role="article"] div:has(> [data-testid="user-input-step"]),
      html body div[role="article"] [data-testid="user-input-step"],
      html body div[role="article"] div[class*="user-input-step"] {
        position: relative;
        background: transparent;
        background-color: transparent;
        background-image: none;
        backdrop-filter: none;
        box-shadow: none;
        border: none;
      }
      html body div[role="article"]::before,
      html body div[role="article"]::after,
      html body div[role="article"] > div::before,
      html body div[role="article"] > div::after,
      html body div[role="article"] div[class*="sticky"]::before,
      html body div[role="article"] div[class*="sticky"]::after,
      html body div[role="article"] div[class*="sticky-message"]::before,
      html body div[role="article"] div[class*="sticky-message"]::after,
      html body div[role="article"] [data-testid="user-input-step"]::before,
      html body div[role="article"] [data-testid="user-input-step"]::after,
      html body div[role="article"] div[class*="user-input-step"]::before,
      html body div[role="article"] div[class*="user-input-step"]::after {
        display: none;
        content: none;
        background: none;
        background-image: none;
        height: 0;
      }
    `;
  }

  function injectVideoBackground() {
    let video = document.getElementById('antigravity-video-bg');
    if (!video) {
      video = document.createElement('video');
      video.id = 'antigravity-video-bg';
      video.src = encodeURI('file://' + '__VIDEO_PATH__');
      video.autoplay = true;
      video.loop = true;
      video.muted = true;
      video.playsInline = true;
      video.style.cssText = 'position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; object-fit: cover; z-index: -9999; pointer-events: none;';
      (document.body || document.documentElement).appendChild(video);
    }
    const ensurePlay = () => {
      if (video && video.paused) {
        video.play().catch(() => {});
      }
    };
    ensurePlay();
    window.addEventListener('focus', ensurePlay);
    document.addEventListener('visibilitychange', () => {
      if (!document.hidden) ensurePlay();
    });
  }

  // Tag project status headers so the CSS above can style them (the only DOM work left)
  function tagStatusHeaders() {
    const btns = document.querySelectorAll('button[data-project-card="true"]');
    for (let i = 0; i < btns.length; i++) {
      const b = btns[i];
      const text = b.textContent || '';
      const status = text.includes('In Progress') ? 'in-progress' : text.includes('Idle') ? 'idle' : null;
      if (status && b.getAttribute('data-status-header') !== status) {
        b.setAttribute('data-status-header', status);
      }
    }
  }

  let frame = 0;
  const observer = new MutationObserver(() => {
    if (frame) return;
    frame = requestAnimationFrame(() => { frame = 0; tagStatusHeaders(); });
  });

  function init() {
    injectBaseCss();
    injectVideoBackground();
    tagStatusHeaders();
    observer.observe(document.body || document.documentElement, { childList: true, subtree: true });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
// ==========================================
INNER_EOF

export VIDEO_PATH
node -e 'const fs = require("fs"); let c = fs.readFileSync(process.argv[1], "utf8"); c = c.replace("__VIDEO_PATH__", process.env.VIDEO_PATH); fs.writeFileSync(process.argv[1], c);' "$PRELOAD_JS"

echo "Patching utils.js to permanently enable devTools and disable webSecurity for local videos..."
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"
sed -i '' 's/webPreferences: {/webPreferences: { webSecurity: false,/g' "$UTILS_JS"

echo "Repacking app.asar with native modules properly excluded..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH" --unpack-dir "node_modules/chrome-devtools-mcp"

rm -rf "$TMP_DIR"

echo "Clearing quarantine attributes and re-signing Antigravity.app bundle..."
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
xattr -cr "$APP_PATH"

echo "=== Theme Installation Complete! ==="
