#!/bin/bash
set -e

APP_PATH="/Applications/Antigravity.app"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
ASAR_PATH="$RESOURCES_DIR/app.asar"
BACKUP_DIR="$HOME/.gemini/antigravity/backups"
BACKUP_PATH="$BACKUP_DIR/app.asar.original"

echo "=== Antigravity Theme Reverter ==="

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Antigravity app not found at $APP_PATH"
    exit 1
fi

# Locate pristine backup from safe location or legacy in-bundle location
SOURCE_BACKUP=""
if [ -f "$BACKUP_PATH" ]; then
    SOURCE_BACKUP="$BACKUP_PATH"
elif [ -f "$RESOURCES_DIR/app.asar.original" ]; then
    SOURCE_BACKUP="$RESOURCES_DIR/app.asar.original"
elif [ -f "$RESOURCES_DIR/app.asar.bak" ]; then
    SOURCE_BACKUP="$RESOURCES_DIR/app.asar.bak"
fi

if [ -n "$SOURCE_BACKUP" ]; then
    echo "Found pristine backup at $SOURCE_BACKUP. Restoring original app.asar..."
    cp "$SOURCE_BACKUP" "$ASAR_PATH"

    # Clean up all in-bundle backups to prevent macOS code seal / Gatekeeper errors
    rm -f "$RESOURCES_DIR/app.asar.original"
    rm -f "$RESOURCES_DIR/app.asar.bak"

    echo "Clearing quarantine and re-signing Antigravity.app bundle..."
    xattr -cr "$APP_PATH"
    codesign --force --deep --sign - "$APP_PATH"
    xattr -cr "$APP_PATH"

    echo "=== Revert Complete! Pristine state restored. ==="
    echo "Please completely restart Antigravity (Cmd+Q) to see the original."
else
    echo "Error: No pristine backup found at $BACKUP_PATH. Cannot revert."
    exit 1
fi
