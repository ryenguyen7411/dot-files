# =============================================================================
# ZSH CONFIGURATION - Enhanced Edition
# =============================================================================
#
# Version: 3.0.0
# Last Updated: 2025-01-28
# Compatible: macOS, Linux, WSL
# Dependencies: zsh, oh-my-zsh
#
# Features:
# - Cross-platform compatibility with conditional loading
# - Performance optimizations with lazy loading
# - Comprehensive error handling
# - Modular organization within single file
# - Extensive development tool support
#
# Quick Reference:
# - Ctrl+R: History search
# - Tab: Auto-completion
# - zshr: Reload configuration
# - swe <env>: Switch Kubernetes environment
#
# =============================================================================

# ========================
# UTILITY FUNCTIONS
# ========================

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

# Add path if directory exists
add_path() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Lazy load function wrapper
lazy_load() {
  local func_name="$1"
  local loader_func="$2"

  eval "$func_name() {
    unset -f $func_name
    $loader_func
    $func_name \"\$@\"
  }"
}

# Debug logging (disabled by default)
zsh_debug() {
  [[ -n "$ZSH_DEBUG" ]] && echo "[DEBUG] $*" >&2
}

# ========================
# ZSH CORE CONFIGURATION
# ========================

zsh_debug "Loading ZSH core configuration"

# Oh-My-Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT="true"

# Plugins - conditionally load based on availability
plugins=()
command_exists git && plugins+=(git)
command_exists sudo && plugins+=(sudo)

# Check for plugin files in both main and custom directories
# (plugins can be installed in $ZSH/custom/plugins/ via antigen, zplug, etc.)
for plugin in zsh-autosuggestions zsh-completions zsh-syntax-highlighting zsh-z; do
  if [[ -d "$ZSH/plugins/$plugin" ]] || [[ -d "$ZSH/custom/plugins/$plugin" ]]; then
    plugins+=("$plugin")
    zsh_debug "Loaded plugin: $plugin"
  fi
done

autoload -U compinit && compinit

# Load Oh-My-Zsh (fail gracefully if not installed)
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Warning: Oh-My-Zsh not found at $ZSH" >&2
fi

# ========================
# ENVIRONMENT & LOCALE
# ========================

zsh_debug "Setting up environment variables"

# Locale settings
export LANG="${LANG:-en_US.UTF-8}"

# Terminal settings
export TERM="${TERM:-xterm-256color}"

# GPG
if command_exists gpg; then
  export GPG_TTY="${TTY:-$(tty)}"
fi

# Editor fallback chain
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"

# History settings
export HISTSIZE="${HISTSIZE:-10000}"
export SAVEHIST="${SAVEHIST:-10000}"
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

# Disable duplicate history entries
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# ========================
# PATH CONFIGURATION
# ========================

zsh_debug "Configuring PATH"

# ---------------------------
# System & Core Paths
# ---------------------------

# macOS/Homebrew paths
add_path "/opt/homebrew/bin"
add_path "/opt/homebrew/sbin"

# GNU utilities (prefer over BSD versions on macOS)
add_path "/usr/local/opt/libtool/libexec/gnubin"
add_path "/usr/local/opt/gnu-sed/libexec/gnubin"
add_path "/usr/local/opt/gnu-tar/libexec/gnubin"

# Standard system paths
add_path "/usr/local/sbin"
add_path "/usr/local/bin"

# User local binaries (always include)
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------
# Development Tools
# ---------------------------

# Version managers
add_path "$HOME/.rbenv/bin"
if [[ -d "$HOME/.rbenv/shims" ]]; then
  export PATH="$HOME/.rbenv/shims:$PATH"
fi

add_path "$HOME/.cargo/bin"
add_path "$HOME/PHP_CodeSniffer/bin"

# Go
if [[ -d "$HOME/go/bin" ]]; then
  export GOPATH="$HOME/go"
  export PATH="$PATH:$GOPATH/bin"
fi

# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# ---------------------------
# Mobile Development
# ---------------------------

# Android SDK
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  add_path "$ANDROID_HOME/emulator"
  add_path "$ANDROID_HOME/tools"
  add_path "$ANDROID_HOME/tools/bin"
  add_path "$ANDROID_HOME/platform-tools"
  add_path "$ANDROID_HOME/build-tools/36.0.0"
fi

# Flutter
add_path "$HOME/flutter/bin"

# ---------------------------
# Node.js Package Managers
# ---------------------------

# PNPM
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  add_path "$PNPM_HOME"
fi

# Yarn
if [[ -d "$HOME/.yarn/bin" ]]; then
  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi

# Bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  add_path "$BUN_INSTALL/bin"
fi

# NPM global
add_path "$HOME/.npm-cache/bin"

# ---------------------------
# Specialized Tools
# ---------------------------

# OpenCode
add_path "$HOME/.opencode/bin"

# ---------------------------
# Final PATH Cleanup
# ---------------------------

# Remove duplicates while preserving order
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')

# ========================
# TMUX AUTO-START
# ========================

# Only auto-start tmux in Kitty terminal (not in integrated terminals like Cursor/VSCode)
if [ -z "$TMUX" ] && [ -n "$KITTY_WINDOW_ID" ]; then
  tmux attach || tmux
fi

# ========================
# ALIASES
# ========================

zsh_debug "Setting up aliases"

# ---------------------------
# Editor & Navigation
# ---------------------------

alias vi='nvim'
alias suvi='sudo nvim'
alias n='sudo n'

# ---------------------------
# System & Utilities
# ---------------------------

alias :q='exit'
alias zm='exit'

# Enhanced ls with colors and hidden files
if command_exists ls; then
  alias ls='ls -a --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -CF --color=auto'
fi

# ---------------------------
# Configuration Management
# ---------------------------

alias zshr='source ~/.zshrc && clear'
alias tmuxr='tmux source-file ~/.tmux.conf'

# ---------------------------
# Git Workflow
# ---------------------------

# Basic operations
alias ga='git add'
alias gac='git add --all'
alias gc='git commit'
alias gcm='git checkout master && git pull'
alias gcmm='git checkout main && git pull'
alias gcd='git checkout develop && git pull'

# Advanced operations
alias gcs='gac && stash && git checkout release && git pull'
alias gct='gac && git commit -m "temp" --no-verify'
alias push='git push -u origin HEAD'
alias pull='git pull'
alias fetch='git fetch'
alias merge='git merge'
alias uppush='npm version patch --no-git-tag-version && git add package.json && amend && git push -u origin HEAD'
alias púh='push'
alias fush='push'
alias amend='git commit --amend --no-edit'
alias amendf='git commit --amend --no-verify --no-edit'
alias grc='git add --all && git rebase --continue'
alias stash='git stash'
alias pop='git stash pop'

# Git configuration
alias skip='git update-index --skip-worktree'
alias nskip='git update-index --no-skip-worktree'

# ---------------------------
# Development Tools
# ---------------------------

# Kubernetes
if command_exists kubectl; then
  alias k='kubectl'
  alias kx='kubectl exec -it'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
fi

# Docker
if command_exists docker; then
  alias d='docker'
  alias dc='docker compose'
  alias dcu='docker compose up'
  alias dcd='docker compose down'
fi

# ========================
# FUNCTIONS
# ========================

zsh_debug "Loading functions"

# ---------------------------
# Git Utilities
# ---------------------------

# Reset operations
reset() { git reset HEAD~"$1" }
rhard() { gac; git reset --hard HEAD~"$1" }

# Cherry pick visualization
git-cherry() { git cherry -v $1 | tail -n 50 | awk '/^\+/ {print "\033[31m" $0 "\033[39m"} /^\-/ {print "\033[32m" $0 "\033[39m"}' }

# ---------------------------
# Process Management
# ---------------------------

# Process killer (conditional)
if command_exists lsof; then
  killp() { kill $(lsof -ti:$1) }
fi

# Find and kill process by name
killname() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: killname <process_name>"
    return 1
  fi
  pkill -f "$name" && echo "Killed processes matching: $name"
}

# ---------------------------
# Environment Management
# ---------------------------

# Environment switcher with validation
senv() {
  case "$1" in
    which)
      if [[ -x "$HOME/env" ]]; then
        ~/env env
      else
        echo "Environment script not found at $HOME/env"
      fi
      ;;
    prod)
      if [[ -d "$HOME/notes/env/prod" ]]; then
        rm -rf ~/env && ln -s ~/notes/env/prod ~/env && echo "Switched to production environment"
      else
        echo "Production environment not found at $HOME/notes/env/prod"
      fi
      ;;
    dev|*)
      if [[ -d "$HOME/notes/env/dev" ]]; then
        rm -rf ~/env && ln -s ~/notes/env/dev ~/env && echo "Switched to development environment"
      else
        echo "Development environment not found at $HOME/notes/env/dev"
      fi
      ;;
  esac
}

# ---------------------------
# Development Workflow
# ---------------------------

# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ---------------------------
# Cloud & Infrastructure
# ---------------------------

# Lazy load GCloud/Kubernetes environment switcher
_load_swe() {
  zsh_debug "Loading GCloud environment switcher"
  swe() {
    case $1 in
      develop)
        gcloud config set project gam-project-cgd-x0l-zm4
        gcloud container clusters get-credentials bu1-k8s-dev --zone=asia-southeast1-a
        ;;
      stage)
        gcloud config set project veep-staging
        gcloud container clusters get-credentials default --zone=asia-southeast1-a
        ;;
      production)
        gcloud config set project veep-production
        gcloud container clusters get-credentials default --zone=asia-southeast1-a
        ;;
      saas)
        gcloud config set project veep-production
        gcloud container clusters get-credentials saas-1 --region=asia-southeast1
        ;;
      qa)
        gcloud config set project veep-staging
        gcloud container clusters get-credentials qa --zone=asia-southeast1-a
        ;;
      cake-dev)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-dev-2 --zone=asia-southeast1
        ;;
      cake-qa)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-qa-1 --zone=asia-southeast1
        ;;
      cake-stage)
        gcloud config set project bef-cake-sandbox
        gcloud container clusters get-credentials cake-stage-1 --zone=asia-southeast1
        ;;
      cake-prod)
        gcloud config set project bef-cake-prod
        gcloud container clusters get-credentials cake-prod-1 --zone=asia-southeast1
        ;;
      help|*)
        echo "Available environments:"
        echo "  develop    - Development environment"
        echo "  stage      - Staging environment"
        echo "  production - Production environment"
        echo "  qa         - QA environment"
        echo "  saas       - SaaS environment"
        echo "  cake-dev   - Cake development"
        echo "  cake-qa    - Cake QA"
        echo "  cake-stage - Cake staging"
        echo "  cake-prod  - Cake production"
        ;;
    esac
  }
}

lazy_load swe _load_swe

# ========================
# EXTERNAL SOURCES
# ========================

zsh_debug "Loading external sources"

# Tool completions and configurations
safe_source "$HOME/.bun/_bun"
safe_source "$HOME/google-cloud-sdk/path.zsh.inc"
safe_source "$HOME/google-cloud-sdk/completion.zsh.inc"

# External environment file
safe_source "$HOME/.local/bin/env"

# ========================
# UTILITY & MAINTENANCE
# ========================

zsh_debug "Loading utility functions"

# Configuration management
zshrc-edit() {
  ${EDITOR:-vim} ~/.zshrc && echo "Reload with: zshr"
}

zshrc-reload() {
  source ~/.zshrc && echo "Configuration reloaded"
}

zshrc-backup() {
  local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  cp ~/.zshrc "$backup_file" && echo "Backup created: $backup_file"
}

# Performance monitoring
zshrc-profile() {
  local start_time=$(date +%s.%3N)
  source ~/.zshrc >/dev/null 2>&1
  local end_time=$(date +%s.%3N)
  local load_time=$(echo "$end_time - $start_time" | bc)
  echo "ZSH configuration loaded in ${load_time}s"
}

# Debug mode toggle
zshrc-debug-on() {
  export ZSH_DEBUG=1
  echo "Debug mode enabled. Reload config to see debug output."
}

zshrc-debug-off() {
  unset ZSH_DEBUG
  echo "Debug mode disabled."
}

# Plugin status check
zshrc-plugins() {
  echo "Loaded ZSH plugins:"
  for plugin in "${plugins[@]}"; do
    if [[ -d "$ZSH/custom/plugins/$plugin" ]]; then
      echo "  - $plugin (custom)"
    elif [[ -d "$ZSH/plugins/$plugin" ]]; then
      echo "  - $plugin (built-in)"
    else
      echo "  - $plugin (command-based)"
    fi
  done
}

# Path diagnostics
zshrc-path() {
  echo "PATH contents (one per line):"
  echo "$PATH" | tr ':' '\n' | nl
}

# Environment summary
zshrc-info() {
  echo "=== ZSH Configuration Info ==="
  echo "Version: 3.0.0"
  echo "ZSH Version: $ZSH_VERSION"
  echo "Theme: $ZSH_THEME"
  echo "Plugins: ${#plugins[@]} loaded"
  echo "PATH entries: $(echo "$PATH" | tr ':' '\n' | wc -l)"
  echo "Terminal: $TERM"
  echo "Editor: ${EDITOR:-not set}"
  echo "Debug mode: ${ZSH_DEBUG:-disabled}"
}

# ========================
# FINALIZATION
# ========================

zsh_debug "ZSH configuration loaded successfully"

# Optional: Show load time in debug mode
if [[ -n "$ZSH_DEBUG" ]]; then
  zshrc-profile
fi
