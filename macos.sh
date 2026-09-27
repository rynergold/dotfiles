#!/usr/bin/env bash

# ~/.macos — Developer macOS system defaults and UI optimizations
# Run without sudo: ./macos.sh

echo "Applying developer macOS defaults and animation optimizations..."

# ------------------------------------------------------------------------------
# 1. Dock & Mission Control (Instant Hover & No Lag)
# ------------------------------------------------------------------------------
echo "Configuring Dock and Mission Control..."

# Remove the delay before the Dock starts sliding out on hover
defaults write com.apple.dock autohide-delay -float 0

# Set animation duration to 0 for instant snap popup
defaults write com.apple.dock autohide-time-modifier -float 0

# Disable icon bounce animation when launching an application
defaults write com.apple.dock launchanim -bool false

# Make hidden app icons translucent on the Dock
defaults write com.apple.dock showhidden -bool true

# Accelerate Mission Control / Exposé animation
defaults write com.apple.dock expose-animation-duration -float 0.1

# ------------------------------------------------------------------------------
# 2. Animations & Reduce Motion (Instant UI)
# ------------------------------------------------------------------------------
echo "Configuring system animations and Reduce Motion..."

# Enable Reduce Motion (replaces space-sliding with instant cross-fades)
defaults write com.apple.universalaccess reduceMotion -bool true

# Disable window open and close zoom animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Accelerate window and dialog resize speed
defaults write -g NSWindowResizeTime -float 0.001

# Disable Spotlight popup zoom animation
defaults write com.apple.Spotlight NSAutomaticWindowAnimationsEnabled -bool false

# ------------------------------------------------------------------------------
# 3. Keyboard & Cursor Latency (Essential for Vim & Code Editing)
# ------------------------------------------------------------------------------
echo "Configuring keyboard repeat and input latency..."

# Disable press-and-hold for accented characters to allow rapid key repeat (hjkl)
defaults write -g ApplePressAndHoldEnabled -bool false

# Set blazing-fast key repeat rates (lower = faster)
defaults write -g InitialKeyRepeat -int 10  # Delay until repeat (default: 15 / 225ms)
defaults write -g KeyRepeat -int 1         # Repeat interval (default: 2 / 30ms)

# ------------------------------------------------------------------------------
# 4. Finder Preferences
# ------------------------------------------------------------------------------
echo "Configuring Finder defaults..."

# Always show all filename extensions (.json, .ts, .yaml, etc.)
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show breadcrumb path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Disable the warning prompt when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Prevent .DS_Store file creation on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ------------------------------------------------------------------------------
# 5. Spotlight & Privacy
# ------------------------------------------------------------------------------
echo "Configuring Spotlight privacy..."

# Disable network lookup queries in Spotlight
defaults write com.apple.lookup.shared LookupEnabled -bool false

# Disable Safari universal search suggestions
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Immunize ~/Developer from Spotlight indexing if present
if [ -d "$HOME/Developer" ]; then
  touch "$HOME/Developer/.metadata_never_index"
fi

# ------------------------------------------------------------------------------
# 6. System & Error Reporting
# ------------------------------------------------------------------------------
echo "Configuring system error reporting..."

# Disable the slow crash reporter popup (writes log silently without freezing UI)
defaults write com.apple.CrashReporter DialogType -string "none"

# ------------------------------------------------------------------------------
# Restart Affected Services
# ------------------------------------------------------------------------------
echo "Restarting affected system services..."
for app in "Dock" "Finder" "Spotlight"; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo ""
echo "Done! Note: Key repeat settings require a logout/login (or reboot) to take full effect."
