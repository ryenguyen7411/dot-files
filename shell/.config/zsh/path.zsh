# =============================================================================
# PATH CONFIGURATION
# =============================================================================

# Helper: Add path if directory exists
add_path() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# ---------------------------
# System & Core Paths
# ---------------------------

# macOS/Homebrew
add_path "/opt/homebrew/bin"
add_path "/opt/homebrew/sbin"

# GNU utilities (prefer over BSD on macOS)
add_path "/usr/local/opt/libtool/libexec/gnubin"
add_path "/usr/local/opt/gnu-sed/libexec/gnubin"
add_path "/usr/local/opt/gnu-tar/libexec/gnubin"

# Standard system paths
add_path "/usr/local/sbin"
add_path "/usr/local/bin"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------
# Development Tools
# ---------------------------

# Ruby (rbenv)
add_path "$HOME/.rbenv/bin"
[[ -d "$HOME/.rbenv/shims" ]] && export PATH="$HOME/.rbenv/shims:$PATH"

# Rust
add_path "$HOME/.cargo/bin"

# PHP
add_path "$HOME/PHP_CodeSniffer/bin"

# Go
[[ -n "$GOPATH" ]] && add_path "$GOPATH/bin"

# fnm (Fast Node Manager)
if command_exists fnm; then
  eval "$(fnm env --use-on-cd)"
fi

# ---------------------------
# Mobile Development
# ---------------------------

# Android SDK
if [[ -n "$ANDROID_HOME" ]]; then
  add_path "$ANDROID_HOME/emulator"
  add_path "$ANDROID_HOME/tools"
  add_path "$ANDROID_HOME/tools/bin"
  add_path "$ANDROID_HOME/platform-tools"
  add_path "$ANDROID_HOME/build-tools/36.0.0"
fi

# Flutter
add_path "$HOME/flutter/bin"

# ---------------------------
# Package Managers
# ---------------------------

# PNPM
[[ -n "$PNPM_HOME" ]] && add_path "$PNPM_HOME"

# Yarn
if [[ -d "$HOME/.yarn/bin" ]]; then
  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi

# Bun
[[ -n "$BUN_INSTALL" ]] && add_path "$BUN_INSTALL/bin"

# NPM global
add_path "$HOME/.npm-cache/bin"

# ---------------------------
# Specialized Tools
# ---------------------------

# OpenCode
add_path "$HOME/.opencode/bin"

# ---------------------------
# Final Cleanup
# ---------------------------

# Remove duplicates while preserving order
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

