#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_PATH="$RESOURCES_DIR/app.asar.original"

echo "=== Antigravity Theme Reverter ==="

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Antigravity app not found at $APP_PATH"
    exit 1
fi

if [ -f "$BACKUP_PATH" ]; then
    echo "Found pristine backup. Restoring original app.asar..."
    cp "$BACKUP_PATH" "$ASAR_PATH"
    
    echo "Re-signing Antigravity.app bundle..."
    codesign --force --deep --sign - "$APP_PATH"
    
    echo "=== Revert Complete! ==="
    echo "Please completely restart Antigravity (Cmd+Q) to see the original."
else
    echo "Error: No backup found at $BACKUP_PATH. Cannot revert."
    exit 1
fi
