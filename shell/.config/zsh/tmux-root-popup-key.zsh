#!/usr/bin/env zsh
# Root C-b / C-n: in TMS UI, forward to fzf (--bind). Else Claude / test dispatch.
# TMS detection: TMS_UI_MARKER file + #{pane_pid} match (see tools/tms main_tui).

emulate -L zsh
[[ -r "${HOME}/.config/zsh/tmux-popup-log.zsh" ]] && source "${HOME}/.config/zsh/tmux-popup-log.zsh"

typeset key="${1:-}"
typeset tpane="${2:-}"
[[ "$key" == (b|n) ]] || exit 1

typeset cmd ptitle pop pid_from_file pid_actual marker forward=0
cmd=$(tmux display-message -p '#{pane_current_command}' -t "$tpane" 2>/dev/null) || cmd=
[[ -z "$cmd" ]] && cmd=$(tmux display-message -p '#{pane_current_command}' 2>/dev/null) || true
ptitle=$(tmux display-message -p '#{pane_title}' -t "$tpane" 2>/dev/null) || ptitle=
pop=$(tmux display-message -p '#{popup}' -t "$tpane" 2>/dev/null) || pop=
[[ -z "$pop" ]] && pop=$(tmux display-message -p '#{popup}' 2>/dev/null) || true
pid_actual=$(tmux display-message -p '#{pane_pid}' -t "$tpane" 2>/dev/null) || pid_actual=

marker="/tmp/tmux-tms-ui-${tpane#%}.marker"
if [[ -f "$marker" ]]; then
  pid_from_file="$(<$marker)" 2>/dev/null || pid_from_file=
  [[ -n "$pid_from_file" && "$pid_from_file" == "$pid_actual" ]] && forward=1
fi

if [[ "$forward" == 0 ]]; then
  if [[ "$cmd" == *fzf* || "$ptitle" == *'Tmux Session Manager'* || "$ptitle" == *'Session Manager'* ]]; then
    forward=1
  fi
fi

tmux_popup_log "root-key key=$key tpane=$tpane pop=$pop cmd=$cmd title=${ptitle[1,80]} marker=$marker forward=$forward pid_file=$pid_from_file pid_actual=$pid_actual"

if [[ "$forward" == 1 ]]; then
  if [[ -n "$tpane" ]]; then
    case "$key" in
      b) tmux send-keys -t "$tpane" C-b ;;
      n) tmux send-keys -t "$tpane" C-n ;;
    esac
  else
    case "$key" in
      b) tmux send-keys C-b ;;
      n) tmux send-keys C-n ;;
    esac
  fi
  exit 0
fi

case "$key" in
  b) exec zsh "$HOME/.config/zsh/claude-popup-dispatch.zsh" ;;
  n) exec zsh "$HOME/.config/zsh/test-popup-dispatch.zsh" o ;;
esac
