#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clean Clipboard URL
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🧹
# @raycast.packageName Web Tools

# Documentation:
# @raycast.description Strip trackers and tracking query parameters from clipboard URL
# @raycast.author colorye

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
clean-url
