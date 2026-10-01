#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_PATH="$RESOURCES_DIR/app.asar.bak"
TMP_DIR=$(mktemp -d /tmp/antigravity_asar_patch.XXXXXX)

echo "=== Antigravity Desktop DevTools Enabler ==="

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Antigravity app not found at $APP_PATH"
  exit 1
fi

if [ ! -f "$ASAR_PATH" ]; then
  echo "Creating backup of app.asar -> app.asar.bak..."
  cp "$ASAR_PATH" "$ASAR_PATH"
fi

echo "Extracting app.asar from backup for a clean state..."
npx asar extract "$ASAR_PATH" "$TMP_DIR/app"

UTILS_JS="$TMP_DIR/app/dist/utils.js"

if [ ! -f "$UTILS_JS" ]; then
  echo "Error: utils.js not found in extracted asar"
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "Patching utils.js to permanently enable devTools..."
# Replace `devTools: !electron_1.app.isPackaged` with `devTools: true`
sed -i '' 's/devTools: !electron_1.app.isPackaged/devTools: true/g' "$UTILS_JS"

echo "Repacking app.asar..."
npx asar pack "$TMP_DIR/app" "$ASAR_PATH"

rm -rf "$TMP_DIR"

echo "Re-signing Antigravity.app bundle..."
codesign --force --deep --sign - "$APP_PATH"

echo "=== Patch complete! DevTools enabled. ==="
