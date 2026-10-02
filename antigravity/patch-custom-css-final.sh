#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_DIR="$HOME/.gemini/antigravity/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_PATH="$BACKUP_DIR/app.asar.original"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)
WALLPAPER_PATH="/Users/ryner/.config/ghostty/totoro_custom_v2.jpg"

echo "=== Antigravity Desktop Custom CSS Patcher (Totoro Edition) ==="

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Antigravity app not found at $APP_PATH"
  exit 1
fi

if [ ! -f "$WALLPAPER_PATH" ]; then
  echo "Error: Wallpaper not found at $WALLPAPER_PATH"
  exit 1
fi

# Clean up any leftover in-bundle backup that breaks macOS code seal
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

if grep -q "Antigravity DOM Walker" "$ASAR_PATH"; then
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

echo "Encoding Totoro wallpaper to Base64..."
WALLPAPER_B64=$(base64 -i "$WALLPAPER_PATH" | tr -d '\n')

echo "Injecting DOM Walker into preload.js..."
cat << 'INNER_EOF' >> "$PRELOAD_JS"

// ==========================================
// Antigravity DOM Walker & CSS Injector (Totoro)
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
      /* Custom Wallpaper Background - Zero !important - High Specificity */
      html, body, html body #root, html body #app {
        background-image: url('data:image/jpeg;base64,__WALLPAPER_B64__');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
        background-color: transparent;
      }
      
      html body #root > div:first-child,
      html body > div:first-child {
        background-color: transparent;
      }

      /* Layout transparency rules */
      html body #root div[class*="bg-background"],
      html body #root div[class*="bg-sidebar"],
      html body div[class*="bg-zinc-950"],
      html body div[class*="bg-zinc-900"],
      html body div[class*="bg-neutral-950"],
      html body div[class*="bg-neutral-900"],
      html body div[class*="bg-black"],
      html body aside,
      html body main,
      html body [role="main"] {
        background-color: transparent;
      }

      /* Obliterate inline style scroll shadow */
      html body div.absolute.bottom-0.pointer-events-none[style*="linear-gradient"] {
        background: transparent;
      }

      /* Sent Messages & Sticky Wrapper */
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
    const colorMatch = /^(?:color\([^/]+|oklch\([^/]+|oklab\([^/]+|lab\([^/]+|lch\([^/]+)(?:\/\s*([\d.]+%?))?\s*\)$/.exec(bg);
    if (colorMatch) {
      if (colorMatch[1] === undefined) return true;
      const aStr = colorMatch[1];
      const alpha = aStr.endsWith('%') ? parseFloat(aStr)/100 : parseFloat(aStr);
      return alpha > OPACITY_FLOOR;
    }
    const m = /^rgba?\(\s*[\d.]+%?[\s,]+[\d.]+%?[\s,]+[\d.]+%?(?:[\s,/]+([\d.]+%?))?\s*\)$/.exec(bg);
    if (!m) return false;
    if (m[1] === undefined) return true;
    const alpha = m[1].endsWith('%') ? parseFloat(m[1])/100 : parseFloat(m[1]);
    return alpha > OPACITY_FLOOR;
  }

  function collect(el, out) {
    if (!(el instanceof HTMLElement)) return;
    if (SKIP_TAGS.has(el.tagName)) return;
    if (el.matches(PROTECTED)) return;
    if (!applied.has(el)) out.push(el);
    for (let c = el.firstElementChild; c; c = c.nextElementSibling) collect(c, out);
  }

  function process(roots) {
    const candidates = [];
    for (const root of roots) {
      if (!(root instanceof HTMLElement) || !root.isConnected) continue;
      if (root.closest(PROTECTED)) continue;
      collect(root, candidates);
    }
    if (!candidates.length) return;

    const threshold = window.innerWidth * window.innerHeight * AREA_RATIO;
    const hits = [];
    for (const el of candidates) {
      const r = el.getBoundingClientRect();
      if (r.width * r.height < threshold) continue;
      if (needsOverride(getComputedStyle(el).backgroundColor)) hits.push(el);
    }
    if (!hits.length) return;

    for (const el of hits) {
      el.style.setProperty('background-color', TARGET);
      el.style.setProperty('background-image', 'none');
      applied.add(el);
    }

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

export WALLPAPER_B64
node -e 'const fs = require("fs"); let c = fs.readFileSync(process.argv[1], "utf8"); c = c.replace("__WALLPAPER_B64__", process.env.WALLPAPER_B64); fs.writeFileSync(process.argv[1], c);' "$PRELOAD_JS"

echo "Patching utils.js to permanently enable devTools..."
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"

echo "Repacking app.asar with native modules properly excluded..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH" --unpack-dir "node_modules/chrome-devtools-mcp"

rm -rf "$TMP_DIR"

echo "Clearing quarantine attributes and re-signing Antigravity.app bundle..."
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
xattr -cr "$APP_PATH"

echo "=== Final Patch complete! ==="
ls -lh "$ASAR_PATH"
