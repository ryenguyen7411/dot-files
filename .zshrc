# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/ryeng/.oh-my-zsh"

ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT="true"

plugins=(git zsh-syntax-highlighting zsh-completions zsh-z)
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/opt/libtool/libexec/gnubin

export LDFLAGS="-L/usr/local/opt/libffi/lib"
export CPPFLAGS="-I/usr/local/opt/libffi/include"

export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

source $HOME/.cargo/env

# User configuration
alias vi='nvim'
alias n='sudo n'

## tmux
alias ts='tmux new -s'
alias tr='tmux a -t'

## git
alias gac='git add --all && clear'
alias gcm='git checkout master && git pull && clear'
alias gcd='git checkout develop && git pull && clear'
alias gcg='git add --all && git stash && git checkout staging && git reset --hard origin/staging && clear'
alias gcs='gac && stash && git checkout release-loship && git pull && clear'
alias gcss='gac && stash && git checkout release && git pull && clear'
alias gct='gac && git commit -m "temp" --no-verify && clear'

alias dev4='clear && DEV_PORT=4000 yarn dev'
alias dev5='clear && DEV_PORT=5000 yarn dev'
devx() { clear; DEV_PORT=$1 yarn dev; }

alias push='npm version patch --no-git-tag-version && git add package.json && amend && git push -u origin HEAD'
alias púh='push'
alias fush='git push -u origin HEAD'
alias fstag='git push origin HEAD:staging -f'
alias amend='git commit --amend --no-edit'
alias amendf='git commit --amend --no-verify --no-edit'
alias grc='git add --all && git rebase --continue && clear'
alias stash='git stash'
alias skip='git update-index --skip-worktree'
alias nskip='git update-index --no-skip-worktree'
reset() { git reset HEAD~"$1" }
rhard() { gac; git reset --hard HEAD~"$1" }

## exit
alias :q='exit'

## Colorize the ls output ##
alias ls='ls -a --color=auto'
alias lf='ls -d .* --color=auto'

## helper
alias zshr='source ~/.zshrc && clear'
alias tmuxr='tmux source-file ~/.tmux.conf'
killp () { kill $(lsof -ti:$1) }
