#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump to Display 3
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 3️⃣
# @raycast.packageName Window Management

# Documentation:
# @raycast.description Teleport mouse cursor to display 3
# @raycast.author colorye

# shellcheck source=_env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"
jump-display 3 --focus
