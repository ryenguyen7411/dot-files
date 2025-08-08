# ========================
# ZSH CONFIGURATION
# ========================

# Oh-My-Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT="true"

# Plugins
plugins=(git sudo zsh-autosuggestions zsh-completions zsh-syntax-highlighting zsh-z)
autoload -U compinit && compinit

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# ========================
# ENVIRONMENT SETUP
# ========================

# Locale
export LANG=en_US.UTF-8

# GPG
export GPG_TTY=$(tty)

# ========================
# PATH CONFIGURATION
# ========================

# System paths
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/usr/local/opt/libtool/libexec/gnubin"
export PATH="$PATH:/usr/local/opt/gnu-sed/libexec/gnubin"
export PATH="$HOME/.local/bin:$PATH"

# Development tools
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/shims:${PATH}"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/PHP_CodeSniffer/bin:$PATH"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Ruby
eval "$(rbenv init -)"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Flutter
export PATH="$PATH:$HOME/flutter/bin"

# Node.js package managers
export PNPM_HOME="/Users/ryeng/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# NPM
export PATH="$HOME/.npm-cache/bin:$PATH"

# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"

# ========================
# TMUX AUTO-START
# ========================

if [ -v $TMUX ]; then
  tmux attach || tmux
fi

# ========================
# ALIASES
# ========================

# Editor
alias vi='nvim'
alias suvi='sudo nvim'
alias n='sudo n'

# System
alias :q='exit'
alias zm='exit'
alias ls='ls -a --color=auto'
alias lf='ls -d .* --color=auto'

# Configuration reload
alias zshr='source ~/.zshrc && clear'
alias tmuxr='tmux source-file ~/.tmux.conf'

# Git shortcuts
alias gac='git add --all'
alias gcm='git checkout master && git pull'
alias gcmm='git checkout main && git pull'
alias gcd='git checkout develop && git pull'
alias gcs='gac && stash && git checkout release && git pull'
alias gct='gac && git commit -m "temp" --no-verify'
alias push='git push -u origin HEAD'
alias uppush='npm version patch --no-git-tag-version && git add package.json && amend && git push -u origin HEAD'
alias púh='push'
alias fush='push'
alias amend='git commit --amend --no-edit'
alias amendf='git commit --amend --no-verify --no-edit'
alias grc='git add --all && git rebase --continue'
alias stash='git stash'
alias skip='git update-index --skip-worktree'
alias nskip='git update-index --no-skip-worktree'

# OTP
alias otp='~/otp-cli/otp-cli clip'
alias otpshow='~/otp-cli/otp-cli show'

# Kubernetes
alias k=kubectl

# ========================
# FUNCTIONS
# ========================

# Git utilities
reset() { git reset HEAD~"$1" }
rhard() { gac; git reset --hard HEAD~"$1" }
git-cherry() { git cherry -v $1 | tail -n 50 | awk '/^\+/ {print "\033[31m" $0 "\033[39m"} /^\-/ {print "\033[32m" $0 "\033[39m"}' }

# Process killer
killp() { kill $(lsof -ti:$1) }

# Environment switcher
senv() {
  if [ "$1" = "which" ]; then
    ~/env env;
  elif [ "$1" = "prod" ]; then
    rm -rf ~/env && ln -s ~/notes/env/prod ~/env;
  else
    rm -rf ~/env && ln -s ~/notes/env/dev ~/env;
  fi
}

# Claudecode
cc() {
  if [ "$1" ]; then
    cd "$1" && claude
  else
    claude
  fi
}

# GCloud/Kubernetes environment switcher
function swe() {
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
        echo """
          develop
          stage
          production
          qa
        """
        ;;
    esac;
}

# ========================
# BITWARDEN CLI INTEGRATION
# ========================

# Session management
export BW_SESSION_FILE="$HOME/.bw-session"

# Auto-unlock with timeout (30 minutes)
bw_unlock() {
  if [ -f "$BW_SESSION_FILE" ]; then
    export BW_SESSION=$(cat "$BW_SESSION_FILE")
    if ! bw unlock --check &>/dev/null; then
      echo "Bitwarden session expired. Please unlock:"
      local session=$(bw unlock --raw)
      if [ $? -eq 0 ]; then
        echo "$session" > "$BW_SESSION_FILE"
        export BW_SESSION="$session"
      fi
    fi
  else
    echo "No Bitwarden session found. Please unlock:"
    local session=$(bw unlock --raw)
    if [ $? -eq 0 ]; then
      echo "$session" > "$BW_SESSION_FILE"
      export BW_SESSION="$session"
    fi
  fi
}

# Auto-lock after timeout
bw_lock() {
  bw lock
  rm -f "$BW_SESSION_FILE"
  unset BW_SESSION
}

# Bitwarden aliases
alias bwu='bw_unlock'
alias bwl='bw_lock'
alias bws='bw sync'
alias bwst='bw status'

# Password utilities
bwp() {
  bw_unlock
  bw get password "$1" | pbcopy
  echo "Password copied to clipboard"
}

bwt() {
  bw_unlock
  bw get totp "$1" | pbcopy
  echo "TOTP code copied to clipboard"
}

bwshow() {
  bw_unlock
  bw get item "$1" | jq
}

bwsearch() {
  bw_unlock
  bw list items --search "$1" | jq -r '.[] | "\(.id) - \(.name)"'
}

# Generate password
bwgen() {
  local length=${1:-16}
  bw generate --length "$length" --uppercase --lowercase --numbers --special | pbcopy
  echo "Generated password copied to clipboard"
}

# Auto-unlock on shell start (optional - uncomment if desired)
# bw_unlock

# ========================
# EXTERNAL SOURCES
# ========================

# Bun completions
[ -s "/Users/ryeng/.bun/_bun" ] && source "/Users/ryeng/.bun/_bun"
[ -s "/Users/tan.nguyen2/.bun/_bun" ] && source "/Users/tan.nguyen2/.bun/_bun"

# Google Cloud SDK
if [ -f '/Users/tan.nguyen2/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/tan.nguyen2/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/tan.nguyen2/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/tan.nguyen2/google-cloud-sdk/completion.zsh.inc'; fi

. "$HOME/.local/bin/env"
