# =============================================================================
# ALIASES
# =============================================================================

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

# Enhanced ls with colors
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
# Kubernetes
# ---------------------------

if command_exists kubectl; then
  alias k='kubectl'
  alias kx='kubectl exec -it'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kl='kubectl logs'
fi

# ---------------------------
# Docker
# ---------------------------

if command_exists docker; then
  alias d='docker'
  alias dc='docker compose'
  alias dcu='docker compose up'
  alias dcd='docker compose down'
fi

