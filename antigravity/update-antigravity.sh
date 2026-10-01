#!/bin/bash
set -e

ZIP_PATH="/Users/ryner/Library/Caches/com.google.antigravity/pending/Antigravity.zip"
TARGET_APP="/Applications/Antigravity.app"
TMP_DIR=$(mktemp -d /tmp/antigravity_update.XXXXXX)

echo "=== Antigravity Updater & Theme Re-applier ==="

if [ ! -f "$ZIP_PATH" ]; then
    echo "Error: Downloaded update zip not found at $ZIP_PATH"
    exit 1
fi

echo "1. Closing Antigravity if running..."
osascript -e 'quit app "Antigravity"' 2>/dev/null || true
sleep 2

echo "2. Unpacking downloaded update bundle..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR"

echo "3. Replacing /Applications/Antigravity.app..."
rm -rf "$TARGET_APP"
cp -R "$TMP_DIR/Antigravity.app" "$TARGET_APP"
rm -rf "$TMP_DIR"
xattr -cr "$TARGET_APP"

echo "4. Removing obsolete backup from old version..."
rm -f "$TARGET_APP/Contents/Resources/app.asar.original"

echo "5. Re-applying custom theme, background video, and Mononoki font..."
/Users/ryner/.gemini/antigravity/apply-antigravity-theme.sh

echo "6. Launching updated Antigravity..."
open "$TARGET_APP"

echo "=== Successfully updated with custom theme! ==="
