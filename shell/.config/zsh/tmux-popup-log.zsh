# Shared debug log for tmux popup helpers — dot-source from zsh: source "$HOME/.config/zsh/tmux-popup-log.zsh"
# Tail:  tail -f ~/.cache/tmux-popup-debug.log
# Off:   export TMUX_POPUP_DEBUG=0

: "${TMUX_POPUP_LOG:=$HOME/.cache/tmux-popup-debug.log}"

tmux_popup_log() {
  [[ "${TMUX_POPUP_DEBUG:-1}" == 0 ]] && return 0
  mkdir -p "${TMUX_POPUP_LOG:h}" 2>/dev/null || true
  print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$TMUX_POPUP_LOG" 2>/dev/null || true
}
