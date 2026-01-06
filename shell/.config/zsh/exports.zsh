# =============================================================================
# ENVIRONMENT EXPORTS
# =============================================================================

# Locale
export LANG="${LANG:-en_US.UTF-8}"

# Terminal
export TERM="${TERM:-xterm-256color}"

# GPG
if command_exists gpg; then
  export GPG_TTY="${TTY:-$(tty)}"
fi

# Editors
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# History
export HISTSIZE="${HISTSIZE:-10000}"
export SAVEHIST="${SAVEHIST:-10000}"
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

# History options
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Go
if [[ -d "$HOME/go" ]]; then
  export GOPATH="$HOME/go"
fi

# Android SDK
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
fi

# PNPM
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
fi

# Bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
fi

