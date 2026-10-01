#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_PATH="$RESOURCES_DIR/app.asar.bak"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)

echo "=== Antigravity Desktop Custom CSS Patcher (The Final Polish) ==="

# 1. Restore the pristine backup
echo "Restoring pristine app.asar (4.5MB)..."
cp "$BACKUP_PATH" "$ASAR_PATH"

# 2. Extract it
echo "Extracting app.asar..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

PRELOAD_JS="$TMP_DIR/app/dist/preload.js"
UTILS_JS="$TMP_DIR/app/dist/utils.js"

# 3. Patch preload.js
echo "Encoding Totoro wallpaper to Base64..."
WALLPAPER_B64=$(base64 -i "/Users/ryner/.config/ghostty/totoro_custom_v2.jpg" | tr -d '\n')

echo "Injecting Optimized Pure JS DOM Walker into preload.js..."
cat << EOF >> "$PRELOAD_JS"

// ==========================================
// Antigravity DOM Walker & CSS Injector (Final)
// ==========================================
;(function() {
  function injectBaseCss() {
    let style = document.getElementById('antigravity-custom-css');
    if (!style) {
      style = document.createElement('style');
      style.id = 'antigravity-custom-css';
      (document.head || document.documentElement).appendChild(style);
    }
    
    style.textContent = \`
      html, body, #root, #app {
        background-image: url('data:image/jpeg;base64,$WALLPAPER_B64') !important;
        background-size: cover !important;
        background-position: center !important;
        background-attachment: fixed !important;
        background-color: transparent !important;
      }
      
      #root > div:first-child,
      body > div:first-child {
        background-color: transparent !important;
      }

      /* Obliterate the inline style scroll shadow! */
      div.absolute.bottom-0.pointer-events-none[style*="linear-gradient"] {
        background: transparent !important;
      }
    \`;
  }

  function applyTranslucentBackgrounds(root = document.body) {
    if (!root) return;
    const vw = window.innerWidth, vh = window.innerHeight;

    function isLikelyLayoutContainer(el) {
      const r = el.getBoundingClientRect();
      const areaRatio = (r.width * r.height) / (vw * vh);
      if (areaRatio < 0.05) return false;
      const tag = el.tagName.toLowerCase();
      if (['button','input','textarea','select','svg','path','img','video','canvas', 'code', 'pre'].includes(tag)) return false;
      if (el.getAttribute('role') === 'button') return false;
      if (el.closest('button, [role="button"], input, textarea, select')) return false;
      return true;
    }

    function walk(el) {
      if (!(el instanceof HTMLElement)) return;
      const cs = window.getComputedStyle(el);
      const bg = cs.backgroundColor;
      
      const isOpaque = bg && bg !== 'transparent' && !bg.startsWith('rgba(0, 0, 0, 0)') &&
                   !(bg.startsWith('rgba') && bg.endsWith(', 0)')) &&
                   !bg.startsWith('rgba(29, 32, 33, 0.85)');
      
      if (isOpaque && isLikelyLayoutContainer(el) && cs.backdropFilter === 'none') {
        el.style.setProperty('background-color', 'rgba(29, 32, 33, 0.85)', 'important');
        el.style.setProperty('background-image', 'none', 'important');
      }
      for (const child of el.children) walk(child);
    }
    walk(root);
  }

  function init() {
    injectBaseCss();
    applyTranslucentBackgrounds();
    
    let walkPending = false;
    const observer = new MutationObserver(() => {
      if (!walkPending) {
        walkPending = true;
        requestAnimationFrame(() => {
          applyTranslucentBackgrounds();
          walkPending = false;
        });
      }
    });
    
    observer.observe(document.body || document.documentElement, { 
      childList: true, 
      subtree: true, 
      attributes: true, 
      attributeFilter: ['class', 'style'] 
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
// ==========================================
EOF

echo "Patching utils.js to permanently enable devTools..."
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"

# 4. Pack it CORRECTLY with --unpack-dir
echo "Repacking app.asar with correct --unpack-dir..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH" --unpack-dir "node_modules/chrome-devtools-mcp"

rm -rf "$TMP_DIR"

echo "Re-signing Antigravity.app bundle..."
codesign --force --deep --sign - "$APP_PATH"

echo "=== Final Patch complete! ==="
ls -lh "$ASAR_PATH"
