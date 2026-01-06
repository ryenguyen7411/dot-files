#!/bin/bash#

# nvim
if [ ! -d ~/.config/nvim ]; then
  ln -s "$(pwd)/nvim" ~/.config/nvim
fi

# alacritty
if [ -d ~/.config/alacritty ]; then
  if [ ! -e ~/.config/alacritty/alacritty.yml ]; then
    ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty/alacritty.yml
  fi
fi

# .zshrc
if [ ! -e ~/.zshrc ]; then
  ln -s "$(pwd)/.zshrc" ~/.zshrc
fi

# .tmux.conf.local
if [ ! -e ~/.tmux.conf.local ]; then
  ln -s "$(pwd)/.tmux.conf.local" ~/.tmux.conf.local
fi

# kitty
if [ -d ~/.config/kitty ]; then
  if [ ! -e ~/.config/kitty/kitty.conf ]; then
    ln -s "$(pwd)/kitty.conf" ~/.config/kitty/kitty.conf
  fi
fi

# rgignore / fdignore
if [ -d ~/.config/rg ]; then
  if [ ! -e ~/.config/rg/.rgignore ]; then
    ln -s "$(pwd)/.ignore" ~/.config/rg/.rgignore
  fi
fi
if [ -d ~/.config/fd ]; then
  if [ ! -e ~/.config/fd/.fdignore ]; then
    ln -s "$(pwd)/.ignore" ~/.config/fd/.fdignore
  fi
fi

# opencode
if [ -e ~/.config/opencode ] || [ -L ~/.config/opencode ]; then
  rm -rf ~/.config/opencode
fi
ln -s "$(pwd)/opencode" ~/.config/opencode

# claude
if [ -e ~/.claude ] || [ -L ~/.claude ]; then
  rm -rf ~/.claude
fi
ln -s "$(pwd)/claude" ~/.claude

# codex
if [ -e ~/.codex ] || [ -L ~/.codex ]; then
  rm -rf ~/.codex
fi
ln -s "$(pwd)/codex" ~/.codex

# tmux-sessions (tms)
# Requires MACHINE_NAME environment variable to be set
# Structure: tmux-sessions/<machine>/projects.conf + layouts/
mkdir -p ~/.local/bin

if [ -n "$MACHINE_NAME" ]; then
  MACHINE_DIR="$(pwd)/tmux-sessions/${MACHINE_NAME}"
  DEFAULT_DIR="$(pwd)/tmux-sessions/default"

  # Create machine directory from template if it doesn't exist
  if [ ! -d "$MACHINE_DIR" ]; then
    echo "Creating new machine config from template..."
    cp -r "$DEFAULT_DIR" "$MACHINE_DIR"
    echo "Created: $MACHINE_DIR"
  fi

  # Symlink entire machine directory to ~/.config/tmux-sessions
  if [ -e ~/.config/tmux-sessions ] || [ -L ~/.config/tmux-sessions ]; then
    rm -rf ~/.config/tmux-sessions
  fi
  ln -s "$MACHINE_DIR" ~/.config/tmux-sessions
  echo "Linked tmux-sessions config for: $MACHINE_NAME"
else
  echo "Warning: MACHINE_NAME not set, skipping tmux-sessions config symlinks"
  echo "Set MACHINE_NAME in ~/.env.local (e.g., export MACHINE_NAME=work)"
fi

# Symlink tms executable
if [ -e ~/.local/bin/tms ] || [ -L ~/.local/bin/tms ]; then
  rm -f ~/.local/bin/tms
fi
ln -s "$(pwd)/tmux-sessions/tms" ~/.local/bin/tms
