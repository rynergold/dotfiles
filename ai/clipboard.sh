#!/bin/sh

# launchctl: macOS service manager controlling background and user sessions
# asuser: Runs cmd inside target user's active desktop GUI session
interceptCopyToGlobalClipboard() {
  local globalClipboard="/usr/bin/pbcopy"

  local userId
  userId=$(id -u)

  exec launchctl asuser "$userId" "$globalClipboard" "$@"
}

interceptCopyToGlobalClipboard "$@"
