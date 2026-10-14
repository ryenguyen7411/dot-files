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
alias arc='/Applications/Arc.app/Contents/MacOS/Arc --remote-debugging-port=9222'

# Modern CLI replacements
if command_exists eza; then
  # Functions, not aliases: eza reads paths from stdin when stdin isn't a terminal, which
  # makes `ls` print nothing or hang in agent shells and pipes. Fall back to plain ls there.
  # (`function name` form: zsh won't alias-expand the name, e.g. Oh My Zsh's own `ls` alias)
  # Each function is self-contained: Claude Code's shell snapshot drops `_`-prefixed functions,
  # so a shared `_eza` helper left `ls` failing with "command not found: _eza" there.
  unalias ls ll la lt l 2>/dev/null
  function ls { if [[ -t 0 ]]; then eza --icons --group-directories-first "$@"; else command ls "${@:#--*}"; fi }
  function ll { if [[ -t 0 ]]; then eza --icons --group-directories-first -la "$@"; else command ls -la "${@:#--*}"; fi }
  function la { if [[ -t 0 ]]; then eza --icons --group-directories-first -a "$@"; else command ls -a "${@:#--*}"; fi }
  function lt { if [[ -t 0 ]]; then eza --tree --level=2 --icons "$@"; else command ls -R "$@"; fi }
  function l { if [[ -t 0 ]]; then eza --icons --group-directories-first -F "$@"; else command ls -F "${@:#--*}"; fi }
else
  alias ls='ls -a --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -CF --color=auto'
fi

# bat (better cat)
if command_exists bat; then
  alias cat='bat --paging=never'
  alias catp='bat'  # with paging
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
alias gcs='gac && stash push -m "auto-stash: $(git branch --show-current)" && git checkout release && git pull'
alias gct='gac && git commit --fixup=HEAD --no-verify'
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

# Git fast commit
alias gmm='git commit -m'
alias gmmn='git commit --no-verify -m'

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

