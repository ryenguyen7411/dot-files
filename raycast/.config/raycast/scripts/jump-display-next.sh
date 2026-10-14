#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump to Next Display
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Window Management

# Documentation:
# @raycast.description Teleport mouse cursor to the next display
# @raycast.author colorye

# shellcheck source=_env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"
jump-display next --focus
