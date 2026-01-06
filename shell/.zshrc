# =============================================================================
# ZSH CONFIGURATION - Modular Edition
# =============================================================================
#
# Version: 4.0.0
# Last Updated: 2026-01-07
# Compatible: macOS, Linux, WSL
# Dependencies: zsh, oh-my-zsh
#
# This is a slim loader that sources modular config files from ~/.config/zsh/
# =============================================================================

# Configuration directory
ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Safe source function with error handling
safe_source() {
  local file="$1"
  if [[ -f "$file" ]]; then
    source "$file" 2>/dev/null && return 0
    echo "Warning: Failed to source $file" >&2
    return 1
  fi
  return 1
}

# Debug logging (disabled by default)
zsh_debug() {
  [[ -n "$ZSH_DEBUG" ]] && echo "[DEBUG] $*" >&2
}

# ========================
# OH-MY-ZSH SETUP
# ========================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT="true"

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Plugins - conditionally load based on availability
plugins=()
command_exists git && plugins+=(git)
command_exists sudo && plugins+=(sudo)

for plugin in zsh-autosuggestions zsh-completions zsh-syntax-highlighting zsh-z; do
  if [[ -d "$ZSH/plugins/$plugin" ]] || [[ -d "$ZSH/custom/plugins/$plugin" ]]; then
    plugins+=("$plugin")
  fi
done

autoload -U compinit && compinit

# Load Oh-My-Zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Warning: Oh-My-Zsh not found at $ZSH" >&2
fi

# ========================
# LOAD MODULAR CONFIG
# ========================

zsh_debug "Loading modular configuration from $ZSH_CONFIG_DIR"

# Core modules (order matters)
safe_source "$ZSH_CONFIG_DIR/exports.zsh"
safe_source "$ZSH_CONFIG_DIR/path.zsh"
safe_source "$ZSH_CONFIG_DIR/aliases.zsh"
safe_source "$ZSH_CONFIG_DIR/functions.zsh"

# Machine-specific config (not tracked in git)
safe_source "$ZSH_CONFIG_DIR/local.zsh"

# Legacy: Also check ~/.env.local for backwards compatibility
safe_source "$HOME/.env.local"

# ========================
# TMUX AUTO-START
# ========================

# Only auto-start tmux in Kitty terminal (not in integrated terminals)
if [[ -z "$TMUX" ]] && [[ -n "$KITTY_WINDOW_ID" ]]; then
  tmux attach || tmux
fi

# ========================
# FINALIZATION
# ========================

zsh_debug "ZSH configuration loaded successfully"

