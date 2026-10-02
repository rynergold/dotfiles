#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_DIR="$HOME/.gemini/antigravity/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_PATH="$BACKUP_DIR/app.asar.original"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)

echo "=== Antigravity Desktop DevTools Enabler ==="

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Antigravity app not found at $APP_PATH"
  exit 1
fi

echo "Extracting app.asar..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

UTILS_JS="$TMP_DIR/app/dist/utils.js"

if [ ! -f "$UTILS_JS" ]; then
  echo "Error: utils.js not found in extracted asar"
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "Patching utils.js to permanently enable devTools and local file access..."
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"
sed -i '' 's/webPreferences: {/webPreferences: { webSecurity: false,/g' "$UTILS_JS"

echo "Repacking app.asar with native modules properly excluded..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH" --unpack-dir "node_modules/chrome-devtools-mcp"

rm -rf "$TMP_DIR"

echo "Clearing quarantine attributes and re-signing Antigravity.app bundle..."
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
xattr -cr "$APP_PATH"

echo "=== DevTools restored! ==="
