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

# Clean up any leftover in-bundle backup that breaks macOS code seal
rm -f "$RESOURCES_DIR/app.asar.original"

echo "Checking ASAR state..."
if grep -q "Antigravity DOM Walker" "$ASAR_PATH"; then
    if [ ! -f "$BACKUP_PATH" ]; then
        echo "Error: Current app.asar is patched, but no backup exists to restore from!"
        exit 1
    fi
    echo "Current app.asar is already patched. Restoring from pristine backup..."
    cp "$BACKUP_PATH" "$ASAR_PATH"
else
    echo "Current app.asar is pristine. Creating backup at $BACKUP_PATH..."
    cp "$ASAR_PATH" "$BACKUP_PATH"
fi

echo "Extracting app.asar..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

PRELOAD_JS="$TMP_DIR/app/dist/preload.js"
UTILS_JS="$TMP_DIR/app/dist/utils.js"

echo "Injecting DOM Walker and Video Background into preload.js..."
cat << 'INNER_EOF' >> "$PRELOAD_JS"

// ==========================================
// Antigravity DOM Walker & Video Injector
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

      /* Apply Mononoki globally across the entire app (Zero !important) */
      html body, html body p, html body span, html body div, html body a, html body button, html body code, html body pre, html body .monaco-editor, html body .xterm, html body .xterm-screen, html body textarea, html body input {
        font-family: 'Mononoki', monospace;
      }

      /* Base font size for rem-based Tailwind scaling */
      html {
        font-size: 18px;
      }

      /* =========================================
         CINEMATIC CHAT HIERARCHY
         Zero !important - High Specificity
         ========================================= */

      /* Global Readability: Text Shadow instead of bulky background boxes */
      html body div[role="article"] {
        text-shadow: 0px 2px 5px rgba(0,0,0, 0.9), 0px 0px 2px rgba(0,0,0, 0.8);
      }
      /* Keep code blocks crisp without shadows */
      html body pre, html body code, html body .monaco-editor, html body .xterm, html body .xterm-screen {
        text-shadow: none;
      }

      /* Layout Transparency - Zero !important - High Specificity */
      html, body, html body #root, html body #app {
        background-color: transparent;
        background-image: none;
      }
      
      html body #root > div:first-child,
      html body > div:first-child {
        background-color: transparent;
      }

      /* Transparent layout containers to let background video show through */
      html body #root div[class*="bg-background"],
      html body #root div[class*="bg-sidebar"],
      html body div[class*="bg-zinc-950"],
      html body div[class*="bg-zinc-900"],
      html body div[class*="bg-neutral-950"],
      html body div[class*="bg-neutral-900"],
      html body div[class*="bg-black"],
      html body div[class*="bg-background"],
      html body div[class*="bg-sidebar"],
      html body aside,
      html body main,
      html body [role="main"] {
        background-color: transparent;
      }

      /* Obliterate inline style scroll shadows */
      html body div.absolute.bottom-0.pointer-events-none[style*="linear-gradient"] {
        background: transparent;
      }

      /* Fix the 2.11.0 Separated File Reference Chips inside bubbles */
      html body span.context-scope-mention {
        background-color: transparent;
      }
      html body button:has(> span.context-scope-mention) {
        background-color: rgba(60, 60, 60, 0.4);
        border: 1px solid rgba(255, 255, 255, 0.1);
      }

      /* Make the Terminal Pane completely transparent */
      html body .xterm,
      html body .xterm-viewport,
      html body .xterm-scrollable-element,
      html body .xterm-screen {
        background-color: transparent;
        background: transparent;
      }

      /* Add dark translucent backing to File Viewer for code readability */
      html body [aria-label="File Viewer"],
      html body [aria-label="File Viewer"] > div {
        background-color: rgba(29, 32, 33, 0.85);
      }

      /* Hide the ghost loading spinner behind the terminal */
      html body [data-testid*="terminal"] > .absolute.inset-0.flex,
      html body [data-testid*="terminal"] .animate-spin {
        display: none;
      }

      /* Hover Animations for Cards (Pop-up effect) */
      /* Exclude sidebar items using :not(:has(...)) */
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
         SIDEBAR STATUS BAR HEADERS (STYLE B)
         Zero !important - High Specificity
         ========================================= */

      /* In Progress Header (Sunset Orange Left-Notch Bar) */
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

      /* Idle Header (Soft Pine Left-Notch Bar) */
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
         Zero !important - High Specificity
         ========================================= */

      /* Neutralize the sticky background, borders, and shadows */
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

      /* Eliminate top and bottom gradient fade bars */
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

  // ==========================================
  // Optimized Phase-Split DOM Walker (Claude Spec)
  // ==========================================
  const TARGET_ALPHA  = 0.85;
  const TARGET        = `rgba(29, 32, 33, ${TARGET_ALPHA})`;
  const AREA_RATIO    = 0.03;
  const OPACITY_FLOOR = 0.9;

  const SKIP_TAGS = new Set([
    'SPAN', 'P', 'IMG', 'VIDEO', 'CANVAS', 'INPUT',
    'TEXTAREA', 'SELECT', 'BR', 'HR', 'SCRIPT', 'STYLE',
  ]);
  const PROTECTED = '.xterm, .monaco-editor, [role="article"], [data-testid*="step"]';

  const applied = new WeakSet();

  function needsOverride(bg) {
    if (!bg || bg === 'transparent' || bg === 'rgba(0, 0, 0, 0)') return false;
    const srgbMatch = /^color\([^/]+(?:\/\s*([\d.]+))?\s*\)$/.exec(bg);
    if (srgbMatch) {
      const alpha = srgbMatch[1] === undefined ? 1 : parseFloat(srgbMatch[1]);
      return alpha > OPACITY_FLOOR;
    }
    const m = /^rgba?\(\s*[\d.]+[\s,]+[\d.]+[\s,]+[\d.]+(?:[\s,/]+([\d.]+))?\s*\)$/.exec(bg);
    if (!m) return false;
    const alpha = m[1] === undefined ? 1 : parseFloat(m[1]);
    return alpha > OPACITY_FLOOR;
  }

  // Phase 1 — Traversal only (No layout reads/writes)
  function collect(el, out) {
    if (!(el instanceof HTMLElement)) return;
    if (SKIP_TAGS.has(el.tagName)) return;
    if (el.matches(PROTECTED)) return;
    if (!applied.has(el)) out.push(el);
    for (let c = el.firstElementChild; c; c = c.nextElementSibling) collect(c, out);
  }

  function tagStatusHeaders() {
    const btns = document.querySelectorAll('button[data-project-card="true"]');
    for (let i = 0; i < btns.length; i++) {
      const b = btns[i];
      const text = b.textContent || '';
      if (text.includes('In Progress')) {
        if (b.getAttribute('data-status-header') !== 'in-progress') {
          b.setAttribute('data-status-header', 'in-progress');
        }
      } else if (text.includes('Idle')) {
        if (b.getAttribute('data-status-header') !== 'idle') {
          b.setAttribute('data-status-header', 'idle');
        }
      }
    }
  }

  function process(roots) {
    tagStatusHeaders();
    const candidates = [];
    for (const root of roots) {
      if (!(root instanceof HTMLElement) || !root.isConnected) continue;
      if (root.closest(PROTECTED)) continue;
      collect(root, candidates);
    }
    if (!candidates.length) return;

    // Phase 2 — Reads only (One single layout flush)
    const threshold = window.innerWidth * window.innerHeight * AREA_RATIO;
    const hits = [];
    for (const el of candidates) {
      const r = el.getBoundingClientRect();
      if (r.width * r.height < threshold) continue;
      if (needsOverride(getComputedStyle(el).backgroundColor)) hits.push(el);
    }
    if (!hits.length) return;

    // Phase 3 — Writes only (Zero !important)
    for (const el of hits) {
      el.style.setProperty('background-color', TARGET);
      el.style.setProperty('background-image', 'none');
      applied.add(el);
    }

    // Synchronously drain our own MutationObserver records triggered by Phase 3 writes
    observer.takeRecords();
  }

  const pending = new Set();
  let frame = 0;

  function schedule() {
    if (frame) return;
    frame = requestAnimationFrame(() => {
      frame = 0;
      const roots = new Set(pending);
      pending.clear();
      process(roots);
    });
  }

  const observer = new MutationObserver((records) => {
    for (const rec of records) {
      if (rec.type === 'attributes') {
        if (rec.target.nodeType !== 1) continue;
        applied.delete(rec.target);
        pending.add(rec.target);
      } else {
        for (const n of rec.addedNodes) if (n.nodeType === 1) pending.add(n);
      }
    }
    if (pending.size) schedule();
  });

  function init() {
    injectBaseCss();
    injectVideoBackground();
    
    observer.observe(document.body || document.documentElement, { 
      childList: true, subtree: true, 
      attributes: true, attributeFilter: ['class', 'style'] 
    });
    
    function fullPass() { pending.add(document.body || document.documentElement); schedule(); }
    fullPass();
    window.addEventListener('resize', fullPass, { passive: true });
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
