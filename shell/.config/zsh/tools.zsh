# =============================================================================
# MODERN CLI TOOL INITIALIZATIONS
# =============================================================================
# These tools enhance the shell experience with better defaults and features.
# Install via: brew bundle (see Brewfile)
# =============================================================================

# ---------------------------
# zoxide (smarter cd)
# ---------------------------
# Learns your most-used directories and lets you jump to them with `z`
if command_exists zoxide; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias cdi='zi'  # interactive selection
fi

# # ---------------------------
# # starship (modern prompt)
# # ---------------------------
# # Cross-shell prompt with git status, language versions, etc.
# if command_exists starship; then
#   eval "$(starship init zsh)"
# fi

# ---------------------------
# atuin (better history)
# ---------------------------
# Magical shell history with sync, search, and stats
if command_exists atuin; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ---------------------------
# direnv (per-directory env)
# ---------------------------
# Auto-load .envrc files when entering directories
if command_exists direnv; then
  eval "$(direnv hook zsh)"
fi
