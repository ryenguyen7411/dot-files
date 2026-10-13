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
  atinit"zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# One compinit for the whole shell (the turbo block above only replays compdefs).
# Full security check at most once a day, otherwise trust the dump (-C).
autoload -Uz compinit
_zcompdump_stale=(${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24))
if (( $#_zcompdump_stale )) || [[ ! -f ${ZDOTDIR:-$HOME}/.zcompdump ]]; then
  compinit
else
  compinit -C
fi
unset _zcompdump_stale

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

# Not tracked in git: work-only helpers, then machine-specific config
safe_source "$ZSH_CONFIG_DIR/work.zsh"
safe_source "$ZSH_CONFIG_DIR/local.zsh"

# ========================
# TMUX AUTO-START
# ========================

# One tmux session per client, so two machines never share (and fight over the size
# and layout of) the same session:
#   main     - Kitty on the Mac attaches here
#   phone    - SSH logins from a tailnet peer named *phone* (Termius) attach here; on
#              the Mac it is only created detached and left running in the background
#   <device> - SSH logins from any other tailnet peer get a session named after it
#              (ryeng-work -> "work"); reconnecting from that device reattaches to it
#   ssh-<ip> - SSH logins from a non-tailnet client (LAN IP, no tailscale CLI)
# phone starts in ~/projects running claude; claude is typed into the shell
# (not run as the session command) so quitting it leaves a shell, not a dead session
tmux_ensure_phone() {
  tmux has-session -t phone 2>/dev/null && return 0
  tmux new-session -d -s phone -c "$HOME/projects"
  tmux send-keys -t phone 'claude' Enter
}

# Tailscale device name of the SSH client (e.g. ryeng-phone, ryeng-work); empty when
# the client isn't a tailnet peer (e.g. a LAN IP) or the tailscale CLI is missing
ssh_peer_name() {
  command_exists tailscale || return 0
  tailscale whois "${SSH_CONNECTION%% *}" 2>/dev/null \
    | awk '/^  Name:/ { split($2, parts, "."); print parts[1]; exit }'
}

# tmux session name for the current SSH login (see the list above). Characters tmux
# rejects or rewrites in session names (".", ":", "%" in IPv6 addresses) become "-"
ssh_session_name() {
  local peer name
  peer="$(ssh_peer_name)"
  if [[ "$peer" == *phone* ]]; then
    name=phone
  elif [[ -n "$peer" ]]; then
    name="${peer#ryeng-}"
  else
    name="ssh-${SSH_CONNECTION%% *}"
  fi
  # Never hand an SSH client Kitty's session
  [[ "$name" == main ]] && name=ssh-main
  print -r -- "${name//[^[:alnum:]_-]/-}"
}

if [[ -z "$TMUX" ]] && command_exists tmux; then
  if [[ -n "$SSH_CONNECTION" ]]; then
    # Leaving tmux (detach or last pane closed) also ends the SSH login; if tmux itself
    # fails, the login falls through to a plain shell instead of disconnecting
    ssh_session="$(ssh_session_name)"
    if [[ "$ssh_session" == phone ]]; then
      tmux_ensure_phone && tmux attach-session -t phone && exit
    else
      tmux new-session -A -s "$ssh_session" -c "$HOME/projects" && exit
    fi
    unset ssh_session
  elif [[ -n "$KITTY_WINDOW_ID" ]]; then
    tmux_ensure_phone
    tmux new-session -A -s main
  fi
fi

# ========================
# FINALIZATION
# ========================

zsh_debug "ZSH configuration loaded successfully"

