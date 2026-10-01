#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_PATH="$RESOURCES_DIR/app.asar.bak"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)

echo "=== Antigravity Desktop DevTools Enabler ==="

echo "Extracting app.asar..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

UTILS_JS="$TMP_DIR/app/dist/utils.js"

echo "Patching utils.js to permanently enable devTools..."
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"

echo "Repacking app.asar with correct --unpack-dir..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH" --unpack-dir "node_modules/chrome-devtools-mcp"

rm -rf "$TMP_DIR"

echo "Re-signing Antigravity.app bundle..."
codesign --force --deep --sign - "$APP_PATH"

echo "=== DevTools restored! ==="
