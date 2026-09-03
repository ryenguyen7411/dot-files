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

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
shottr-optimize
