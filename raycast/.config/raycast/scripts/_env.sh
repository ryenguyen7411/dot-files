# Shared environment for Raycast Script Commands.
# Raycast runs scripts in a non-login shell where HOME is often unset.

if [[ -z "${HOME:-}" ]]; then
  export HOME="$(/bin/bash -c 'cd ~ && pwd')"
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}"
