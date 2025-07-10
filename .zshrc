# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT="true"

plugins=(git zsh-syntax-highlighting zsh-completions zsh-z)
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

if [ -v $TMUX ]; then
  tmux attach || tmux
fi

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/opt/libtool/libexec/gnubin
export PATH=$PATH:/usr/local/opt/gnu-sed/libexec/gnubin

export PATH="$PATH:$HOME/flutter/bin"

export VSToolsPath="/Library/Frameworks/Mono.framework/Versions/Current/lib/mono/xbuild/Microsoft/VisualStudio/v15.0/"
export VisualStudioVersion="15.0"

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# User configuration
alias vi='nvim'
alias suvi='sudo nvim'
alias n='sudo n'

## tmux
alias ts='tmux new -s'
alias tr='tmux a -t'

## git
alias gac='git add --all'
alias gcm='git checkout master && git pull'
alias gcmm='git checkout main && git pull'
alias gcbb='git checkout beta && git pull'
alias gcd='git checkout develop && git pull'
alias gcg='git add --all && git stash && git checkout staging && git fetch && git reset --hard origin/staging'
alias gcu='git add --all && git stash && git checkout uat && git fetch && git reset --hard origin/uat'
alias gcgg='git add --all && git stash && git checkout stg && git fetch && git reset --hard origin/stg'
alias gcs='gac && stash && git checkout release-loship && git pull'
alias gcss='gac && stash && git checkout release && git pull'
alias gct='gac && git commit -m "temp" --no-verify'

alias dev4='clear && DEV_PORT=4000 yarn dev'
alias dev5='clear && DEV_PORT=5000 yarn dev'
devx() { clear; DEV_PORT=$1 yarn dev; }

alias push='npm version patch --no-git-tag-version && git add package.json && amend && git push -u origin HEAD'
alias púh='push'
alias fush='git push -u origin HEAD'
alias fstag='git push origin HEAD:staging -f'
alias amend='git commit --amend --no-edit'
alias amendf='git commit --amend --no-verify --no-edit'
alias grc='git add --all && git rebase --continue'
alias stash='git stash'
alias skip='git update-index --skip-worktree'
alias nskip='git update-index --no-skip-worktree'
reset() { git reset HEAD~"$1" }
rhard() { gac; git reset --hard HEAD~"$1" }

git-cherry() { git cherry -v $1 | tail -n 50 | awk '/^\+/ {print "\033[31m" $0 "\033[39m"} /^\-/ {print "\033[32m" $0 "\033[39m"}' }

## exit
alias :q='exit'
alias zm='exit'

## Colorize the ls output ##
alias ls='ls -a --color=auto'
alias lf='ls -d .* --color=auto'

## helper
alias zshr='source ~/.zshrc && clear'
alias tmuxr='tmux source-file ~/.tmux.conf'
killp() { kill $(lsof -ti:$1) }

alias otp='~/otp-cli/otp-cli clip'
alias otpshow='~/otp-cli/otp-cli show'

senv() {
  if [ "$1" = "which" ]; then
    ~/env env;
  elif [ "$1" = "prod" ]; then
    rm -rf ~/env && ln -s ~/notes/env/prod ~/env;
  else
    rm -rf ~/env && ln -s ~/notes/env/dev ~/env;
  fi
}

ConsoleLogWriter() {

}

StringLogParser() {
  echo "abcdef"
}

GcLog() {
  read -r curl

  content="$(StringLogParser("$curl"))"
  echo "hello world" $content
}

export PNPM_HOME="/Users/ryeng/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.rbenv/shims:${PATH}"
export PATH="$HOME/PHP_CodeSniffer/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

export LANG=en_US.UTF-8

# bun completions
[ -s "/Users/ryeng/.bun/_bun" ] && source "/Users/ryeng/.bun/_bun"
[ -s "/Users/tan.nguyen2/.bun/_bun" ] && source "/Users/tan.nguyen2/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tan.nguyen2/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/tan.nguyen2/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/tan.nguyen2/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/tan.nguyen2/google-cloud-sdk/completion.zsh.inc'; fi

# The next line enables shell command completion for kubectl.
alias k=kubectl
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

# GPG
export GPG_TTY=$(tty)

. "$HOME/.local/bin/env"

# opencode
export PATH=/Users/tan.nguyen2/.opencode/bin:$PATH
