#!/usr/bin/env zsh
# C-v: open TMS, or send C-v to fzf (abort), or dismiss non-fzf popup then TMS.
# Args: #{client_name} #{pane_id}

emulate -L zsh
[[ -r "${HOME}/.config/zsh/tmux-popup-log.zsh" ]] && source "${HOME}/.config/zsh/tmux-popup-log.zsh"

typeset cli_client="${1:-}"
typeset cli_pane="${2:-}"
typeset popup cmd
popup=$(tmux display-message -p '#{popup}' 2>/dev/null) || popup=
cmd=$(tmux display-message -p '#{pane_current_command}' 2>/dev/null) || cmd=

tmux_popup_log "bind-c-v popup=$popup cli_pane=$cli_pane client_in=$cli_client pane_cmd=$cmd"

if [[ -z "$popup" || "$popup" == 0 ]]; then
  tmux_popup_log "bind-c-v branch=open_tms_direct"
  exec zsh "$HOME/.config/zsh/tms-popup"
fi

if [[ "$cmd" == *fzf* ]]; then
  tmux_popup_log "bind-c-v branch=send_keys_fzf_abort"
  tmux send-keys C-v
  exit 0
fi

typeset tms="$HOME/.config/zsh/tms-popup"
typeset pane="${TMUX_PANE:-}" client="" q_tms q_client q_killpane
typeset killpane="$cli_pane"
[[ -z "$killpane" && -n "$pane" ]] && killpane="$pane"
[[ -n "$cli_client" ]] && client="$cli_client"
if [[ -z "$client" && -n "$pane" ]]; then
  client=$(tmux display-message -p '#{client_name}' -t "$pane" 2>/dev/null) || client=
  [[ -z "$client" ]] && client=$(tmux display-message -p '#{client_tty}' -t "$pane" 2>/dev/null) || true
fi
[[ -z "$client" ]] && client=$(tmux display-message -p '#{client_name}' 2>/dev/null) || true
[[ -z "$client" ]] && client=$(tmux display-message -p '#{client_tty}' 2>/dev/null) || true

typeset sn="" kill_sess=""
sn=$(tmux display-message -p '#{session_name}' 2>/dev/null) || sn=
if [[ "$sn" == claude_* || "$sn" == opencode_* || "$sn" == tmux_test_* ]]; then
  kill_sess="tmux kill-session -t ${(q)sn} 2>/dev/null || true; "
  tmux_popup_log "bind-c-v will_kill_session=$sn"
fi

q_tms=${(q)tms}
if [[ -n "$killpane" ]]; then
  q_killpane=${(q)killpane}
  if [[ -n "$client" ]]; then
    q_client=${(q)client}
    tmux_popup_log "bind-c-v branch=dismiss kill_sess+killpane+-C+tms killpane=$killpane client=$client"
    tmux run-shell "${kill_sess}tmux kill-pane -t $q_killpane 2>/dev/null || true; tmux display-popup -c $q_client -C 2>/dev/null || true; zsh $q_tms"
  else
    tmux_popup_log "bind-c-v branch=dismiss kill_sess+killpane+tms killpane=$killpane"
    tmux run-shell "${kill_sess}tmux kill-pane -t $q_killpane 2>/dev/null || true; zsh $q_tms"
  fi
elif [[ -n "$client" ]]; then
  q_client=${(q)client}
  tmux_popup_log "bind-c-v branch=dismiss -C+tms client=$client"
  tmux run-shell "${kill_sess}tmux display-popup -c $q_client -C 2>/dev/null || true; zsh $q_tms"
else
  tmux_popup_log "bind-c-v branch=dismiss bare-C+tms"
  tmux run-shell "${kill_sess}tmux display-popup -C 2>/dev/null || true; zsh $q_tms"
fi
