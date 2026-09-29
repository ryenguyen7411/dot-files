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

# shellcheck source=_env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"
clean-url
