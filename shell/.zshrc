# =============================================================================
# ZSH CONFIGURATION - Zinit Edition
# =============================================================================
#
# Version: 5.0.0
# Last Updated: 2026-03-01
# Compatible: macOS, Linux, WSL
# Dependencies: zsh, zinit
#
# Migrated from Oh-My-Zsh to Zinit for faster shell startup.
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

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ========================
# ZINIT SETUP
# ========================

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  echo "Installing Zinit..."
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# OMZ library snippets (key-bindings, history, completion, prompt colors, etc.)
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::async_prompt.zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZL::theme-and-appearance.zsh

# OMZ theme (robbyrussell - colored prompt with git branch)
zinit snippet OMZT::robbyrussell

# OMZ plugins (git aliases, sudo double-ESC)
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Core plugins loaded in Turbo mode (after prompt, for speed)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

autoload -U compinit && compinit

# ========================
# LOAD MODULAR CONFIG
# ========================

zsh_debug "Loading modular configuration from $ZSH_CONFIG_DIR"

# Core modules (order matters)
safe_source "$ZSH_CONFIG_DIR/exports.zsh"
safe_source "$ZSH_CONFIG_DIR/path.zsh"
safe_source "$ZSH_CONFIG_DIR/aliases.zsh"
safe_source "$ZSH_CONFIG_DIR/functions.zsh"
safe_source "$ZSH_CONFIG_DIR/tools.zsh"

# Machine-specific config (not tracked in git)
safe_source "$ZSH_CONFIG_DIR/local.zsh"

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


# Added by Antigravity
export PATH="/Users/ryeng/.antigravity/antigravity/bin:$PATH"
