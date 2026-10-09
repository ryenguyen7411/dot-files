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
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

autoload -U compinit && compinit

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

# Machine-specific config (not tracked in git)
safe_source "$ZSH_CONFIG_DIR/local.zsh"

# ========================
# TMUX AUTO-START
# ========================

# Two named sessions so the Mac and the phone never steal each other's session:
#   main   - Kitty on the Mac auto-attaches here
#   mobile - SSH logins (Termius on the phone) auto-attach here; on the Mac it
#            is only created detached and left running in the background
# mobile starts in ~/projects running claude; claude is typed into the shell
# (not run as the session command) so quitting it leaves a shell, not a dead session
tmux_ensure_mobile() {
  tmux has-session -t mobile 2>/dev/null && return 0
  tmux new-session -d -s mobile -c "$HOME/projects"
  tmux send-keys -t mobile 'claude' Enter
}

# Tailscale device name of the SSH client (e.g. ryeng-phone, ryeng-work); empty when
# the client isn't a tailnet peer (e.g. a LAN IP) or the tailscale CLI is missing
ssh_peer_name() {
  command_exists tailscale || return 0
  tailscale whois "${SSH_CONNECTION%% *}" 2>/dev/null \
    | awk '/^  Name:/ { split($2, parts, "."); print parts[1]; exit }'
}

if [[ -z "$TMUX" ]] && command_exists tmux; then
  if [[ -n "$SSH_CONNECTION" ]]; then
    # Phone (or an unrecognised client) -> mobile; another Mac -> its own session named
    # after it (ryeng-work -> "work"), so Mac-to-Mac logins never take over mobile/main.
    # Leaving tmux (detach or last pane closed) also ends the SSH login; if tmux itself
    # fails, the login falls through to a plain shell instead of disconnecting
    ssh_peer="$(ssh_peer_name)"
    if [[ -n "$ssh_peer" && "$ssh_peer" != *phone* ]]; then
      tmux new-session -A -s "${ssh_peer#ryeng-}" -c "$HOME/projects" && exit
    else
      tmux_ensure_mobile && tmux attach-session -t mobile && exit
    fi
    unset ssh_peer
  elif [[ -n "$KITTY_WINDOW_ID" ]]; then
    tmux_ensure_mobile
    tmux new-session -A -s main
  fi
fi

# ========================
# FINALIZATION
# ========================

zsh_debug "ZSH configuration loaded successfully"


# Added by Antigravity
export PATH="/Users/ryeng/.antigravity/antigravity/bin:$PATH"

# Upload a file to transfer.ryenguyen.dev (creds from ~/.netrc)
transfer() { curl -n --progress-bar --upload-file "$1" "https://transfer.ryenguyen.dev/$(basename "$1")"; echo; }
