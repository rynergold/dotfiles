#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_APP="/Applications/Antigravity.app"
TMP_DIR=$(mktemp -d /tmp/antigravity_update.XXXXXX)

echo "=== Antigravity Updater & Theme Re-applier ==="

ZIP_PATH=""
if [ -f "$HOME/Library/Caches/com.google.antigravity/pending/Antigravity.zip" ]; then
    ZIP_PATH="$HOME/Library/Caches/com.google.antigravity/pending/Antigravity.zip"
elif [ -f "$HOME/Library/Caches/com.google.antigravity/update.zip" ]; then
    ZIP_PATH="$HOME/Library/Caches/com.google.antigravity/update.zip"
fi

if [ -z "$ZIP_PATH" ] || [ ! -f "$ZIP_PATH" ]; then
    echo "Error: Downloaded update zip not found in com.google.antigravity caches"
    exit 1
fi

echo "Using update package: $ZIP_PATH"

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

echo "4. Removing obsolete in-bundle backups..."
rm -f "$TARGET_APP/Contents/Resources/app.asar.original"
rm -f "$TARGET_APP/Contents/Resources/app.asar.bak"

echo "5. Re-applying custom theme, background video, and Mononoki font..."
"$DIR/apply-antigravity-theme.sh"

echo "6. Launching updated Antigravity..."
open "$TARGET_APP"

echo "=== Successfully updated with custom theme! ==="
