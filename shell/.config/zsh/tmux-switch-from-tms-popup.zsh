#!/usr/bin/env zsh
# Called from tms fzf: close the TMS popup, then open test popup (p|o) or Claude (claude).

emulate -L zsh
[[ -r "${HOME}/.config/zsh/tmux-popup-log.zsh" ]] && source "${HOME}/.config/zsh/tmux-popup-log.zsh"

typeset kind="${1:?kind p|o|claude}"
[[ "$kind" == (p|o|claude) ]] || exit 1

typeset popup_pane="${TMS_TMUX_PANE:-${TMUX_PANE:-}}" client="" q_client q_dispatch q_kind q_pane
[[ -n "${TMS_TMUX_CLIENT:-}" ]] && client="$TMS_TMUX_CLIENT"
if [[ -z "$client" && -n "$popup_pane" ]]; then
  client=$(tmux display-message -p '#{client_name}' -t "$popup_pane" 2>/dev/null) || client=
  [[ -z "$client" ]] && client=$(tmux display-message -p '#{client_tty}' -t "$popup_pane" 2>/dev/null) || true
fi
[[ -z "$client" ]] && client=$(tmux display-message -p '#{client_name}' 2>/dev/null) || true
[[ -z "$client" ]] && client=$(tmux display-message -p '#{client_tty}' 2>/dev/null) || true

tmux_popup_log "switch kind=$kind popup_pane=$popup_pane client=$client TMS_UI_MARKER=${TMS_UI_MARKER:-}"

dismiss_then() {
  typeset cmd="$1"
  if [[ -n "$popup_pane" ]]; then
    q_pane=${(q)popup_pane}
    if [[ -n "$client" ]]; then
      q_client=${(q)client}
      tmux run-shell "tmux kill-pane -t $q_pane 2>/dev/null || true; tmux display-popup -c $q_client -C 2>/dev/null || true; $cmd"
    else
      tmux run-shell "tmux kill-pane -t $q_pane 2>/dev/null || true; $cmd"
    fi
  elif [[ -n "$client" ]]; then
    q_client=${(q)client}
    tmux run-shell "tmux display-popup -c $q_client -C 2>/dev/null || true; $cmd"
  else
    tmux run-shell "tmux display-popup -C 2>/dev/null || true; $cmd"
  fi
}

if [[ "$kind" == claude ]]; then
  q_dispatch=${(q)"$HOME/.config/zsh/claude-popup-dispatch.zsh"}
  dismiss_then "zsh $q_dispatch"
else
  q_dispatch=${(q)"$HOME/.config/zsh/test-popup-dispatch.zsh"}
  q_kind=${(q)kind}
  dismiss_then "zsh $q_dispatch $q_kind"
fi
