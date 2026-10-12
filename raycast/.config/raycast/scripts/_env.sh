# shellcheck shell=bash
# Shared environment for Raycast Script Commands.
# Raycast runs scripts in a non-login shell where HOME is often unset.

if [[ -z "${HOME:-}" ]]; then
  HOME="$(/bin/bash -c 'cd ~ && pwd')"
  export HOME
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}"
