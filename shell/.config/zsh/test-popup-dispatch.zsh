#!/usr/bin/env zsh
# Test popups: toggle (same key closes) and switch (other key closes current, opens that one).
# Bound from tmux as: run-shell -b "zsh \"$HOME/.config/zsh/test-popup-dispatch.zsh\" <p|o|y>"
#
# Session names mirror the idea of C-p / C-o / C-y but are isolated from real claude/opencode/tms.

emulate -L zsh

local kind="${1:-}"
[[ "$kind" == (p|o|y) ]] || exit 1

typeset workdir
workdir=$(tmux display-message -p '#{pane_current_path}' 2>/dev/null) || workdir=
[[ -n "$workdir" && -d "$workdir" ]] || workdir="${HOME:-~}"

local dirslug="${workdir:t}"
dirslug="${dirslug//[^A-Za-z0-9_-]/_}"

local sp="tmux_test_p_${dirslug}"
local so="tmux_test_o_${dirslug}"
local sy="tmux_test_y_${dirslug}"
local sclaude="claude_${dirslug}"
local sopencode="opencode_${dirslug}"

local target=""
case "$kind" in
  p) target="$sp" ;;
  o) target="$so" ;;
  y) target="$sy" ;;
esac

typeset current
current=$(tmux display-message -p '#{session_name}' 2>/dev/null) || current=

# Focus inside this popup + same key → close (toggle off)
if [[ "$current" == "$target" ]]; then
  tmux kill-session -t "$target" 2>/dev/null || true
  exit 0
fi

# Inside another popup for this dir → close so we can open/switch
if [[ "$current" == "$sp" || "$current" == "$so" || "$current" == "$sy" || "$current" == "$sclaude" || "$current" == "$sopencode" ]]; then
  tmux kill-session -t "$current" 2>/dev/null || true
fi

# Focus elsewhere but this popup session still exists → close (toggle from outside)
if tmux has-session -t "$target" 2>/dev/null; then
  tmux kill-session -t "$target" 2>/dev/null || true
  exit 0
fi

# Opening a new one: one popup at a time for this dir (tests + Claude + Opencode)
local s
for s in "$sp" "$so" "$sy" "$sclaude" "$sopencode"; do
  [[ "$s" == "$target" ]] && continue
  tmux has-session -t "$s" 2>/dev/null && tmux kill-session -t "$s" 2>/dev/null || true
done

local title
case "$kind" in
  p) title='Test popup (p)' ;;
  o) title='Test popup (o)' ;;
  y) title='Test popup (y)' ;;
esac

# Hold the session open (same outer pattern as claude-popup / opencode-popup)
local inner="tmux new-session -s ${(q)target} tail -f /dev/null"

tmux display-popup -E -T "$title" -w 30% -h 100% -xR -d "$workdir" /bin/sh -c "$inner" \
  || tmux display-message 'test-popup-dispatch: display-popup failed'
