#!/usr/bin/env zsh
# Claude popup with same toggle/switch rules as test-popup-dispatch (C-b, TMS fzf ctrl-b).

emulate -L zsh
[[ -r "${HOME}/.config/zsh/tmux-popup-log.zsh" ]] && source "${HOME}/.config/zsh/tmux-popup-log.zsh"

source_shell_environment() {
  local zprofile="${HOME}/.zprofile"
  local zshrc="${HOME}/.zshrc"
  [[ -f "$zprofile" ]] && source "$zprofile"
  [[ -f "$zshrc" ]]   && source "$zshrc"
}

source_shell_environment

typeset workdir
workdir=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null) || workdir=
[[ -n "$workdir" && -d "$workdir" ]] || workdir="${HOME:-~}"

typeset dirslug="${workdir:t}"
dirslug="${dirslug//[^A-Za-z0-9_-]/_}"

typeset target="claude_${dirslug}"
typeset sopencode="opencode_${dirslug}"
typeset sp="tmux_test_p_${dirslug}"
typeset so="tmux_test_o_${dirslug}"
typeset sy="tmux_test_y_${dirslug}"

typeset current
current=$(tmux display-message -p '#{session_name}' 2>/dev/null) || current=

tmux_popup_log "claude-dispatch session=$current target=$target popup=$(tmux display-message -p '#{popup}' 2>/dev/null)"

if [[ "$current" == "$target" ]]; then
  tmux kill-session -t "$target" 2>/dev/null || true
  exit 0
fi

if [[ "$current" == "$sp" || "$current" == "$so" || "$current" == "$sy" || "$current" == "$sopencode" ]]; then
  tmux kill-session -t "$current" 2>/dev/null || true
fi

if tmux has-session -t "$target" 2>/dev/null; then
  tmux kill-session -t "$target" 2>/dev/null || true
  exit 0
fi

typeset s
for s in "$sp" "$so" "$sy" "$sopencode"; do
  [[ "$s" == "$target" ]] && continue
  tmux has-session -t "$s" 2>/dev/null && tmux kill-session -t "$s" 2>/dev/null || true
done

typeset -a claude_env
claude_env=()
[[ -n "${ANTHROPIC_BASE_URL:-}" ]]   && claude_env+=(ANTHROPIC_BASE_URL="$ANTHROPIC_BASE_URL")
[[ -n "${ANTHROPIC_AUTH_TOKEN:-}" ]] && claude_env+=(ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_AUTH_TOKEN")
[[ -n "${ANTHROPIC_API_KEY:-}" ]]    && claude_env+=(ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY")
[[ -n "${ANTHROPIC_MODEL:-}" ]]      && claude_env+=(ANTHROPIC_MODEL="$ANTHROPIC_MODEL")

typeset inner
if (( $#claude_env )); then
  inner="tmux new-session -s ${(q)target} env"
  for e in "${claude_env[@]}"; do
    inner+=" ${(q)e}"
  done
  inner+=" claude 2>/dev/null || tmux attach-session -t ${(q)target}"
else
  inner="tmux new-session -s ${(q)target} claude 2>/dev/null || tmux attach-session -t ${(q)target}"
fi

tmux display-popup -E -T "Claude" -w 30% -h 100% -xR -d "$workdir" /bin/sh -c "$inner" \
  || tmux display-message 'claude-popup-dispatch: display-popup failed (see tmux logs)'
