#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump to Display 2
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 2️⃣
# @raycast.packageName Window Management

# Documentation:
# @raycast.description Teleport mouse cursor to display 2
# @raycast.author colorye

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
jump-display 2
