#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Smart Open URL from Clipboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName Web Tools

# Documentation:
# @raycast.description Open URL in clipboard with matched browser and profile
# @raycast.author colorye

# shellcheck source=_env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"
link-router
