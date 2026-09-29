#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Shottr Optimize Image
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ⚡
# @raycast.packageName Media Tools

# Documentation:
# @raycast.description Optimize clipboard image or screenshot with ImageOptim
# @raycast.author colorye

# shellcheck source=_env.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_env.sh"
shottr-optimize
