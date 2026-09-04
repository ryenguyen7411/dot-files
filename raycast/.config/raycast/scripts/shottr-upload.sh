#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Shottr Upload Image
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Media Tools

# Documentation:
# @raycast.description Optimize clipboard image and upload to File.kiwi
# @raycast.author colorye

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
shottr-upload
