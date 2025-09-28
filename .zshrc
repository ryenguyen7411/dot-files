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
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d "/usr/local/sbin" ]; then
  export PATH="$PATH:/usr/local/sbin"
fi
if [ -d "/usr/local/opt/libtool/libexec/gnubin" ]; then
  export PATH="$PATH:/usr/local/opt/libtool/libexec/gnubin"
fi
if [ -d "/usr/local/opt/gnu-sed/libexec/gnubin" ]; then
  export PATH="$PATH:/usr/local/opt/gnu-sed/libexec/gnubin"
fi
export PATH="$HOME/.local/bin:$PATH"

# Development tools
if [ -d "$HOME/.rbenv/bin" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  export PATH="$HOME/.rbenv/shims:${PATH}"
fi
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
if [ -d "$HOME/PHP_CodeSniffer/bin" ]; then
  export PATH="$HOME/PHP_CodeSniffer/bin:$PATH"
fi

# Go
if [ -d "$HOME/go/bin" ]; then
  export GOPATH=$HOME/go
  export PATH=$PATH:$GOPATH/bin
fi

# Ruby
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Android SDK
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# Flutter
if [ -d "$HOME/flutter/bin" ]; then
  export PATH="$PATH:$HOME/flutter/bin"
fi

# Node.js package managers
if [ -d "$HOME/Library/pnpm" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi
if [ -d "$HOME/.yarn/bin" ]; then
  export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi

# Bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# NPM
if [ -d "$HOME/.npm-cache/bin" ]; then
  export PATH="$HOME/.npm-cache/bin:$PATH"
fi

# OpenCode
if [ -d "$HOME/.opencode/bin" ]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

# ========================
# TMUX AUTO-START
# ========================

if [ -z "$TMUX" ]; then
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
if [ -x "$HOME/otp-cli/otp-cli" ]; then
  alias otp='~/otp-cli/otp-cli clip'
  alias otpshow='~/otp-cli/otp-cli show'
fi

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
if command -v lsof >/dev/null 2>&1; then
  killp() { kill $(lsof -ti:$1) }
fi

# Environment switcher
senv() {
  if [ "$1" = "which" ]; then
    if [ -x "$HOME/env" ]; then
      ~/env env
    fi
  elif [ "$1" = "prod" ]; then
    if [ -d "$HOME/notes/env/prod" ]; then
      rm -rf ~/env && ln -s ~/notes/env/prod ~/env
    fi
  else
    if [ -d "$HOME/notes/env/dev" ]; then
      rm -rf ~/env && ln -s ~/notes/env/dev ~/env
    fi
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

if command -v bw >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
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
fi

# ========================
# EXTERNAL SOURCES
# ========================

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# External environment file
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
