#!/bin/bash#

# Nvim
if [ -d ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi

# Alacritty
if [ -e ~/.config/alacritty/alacritty.yml ]; then
  rm ~/.config/alacritty/alacritty.yml
fi

# .zshrc
if [ -e ~/.zshrc ]; then
  rm ~/.zshrc
fi

# .tmux.conf.local
if [ -e ~/.tmux.conf.local ]; then
  rm ~/.tmux.conf.local
fi

# Kitty
if [ -e ~/.config/kitty/kitty.conf ]; then
  rm ~/.config/kitty/kitty.conf
fi

# rgignore / fdignore
if [ -e ~/.config/rg/.rgignore ]; then
  rm ~/.config/rg/.rgignore
fi
if [ -e ~/.config/fd/.fdignore ]; then
  rm ~/.config/fd/.fdignore
fi

# opencode
if [ -e ~/.config/opencode ] || [ -L ~/.config/opencode ]; then
  rm -rf ~/.config/opencode
fi

# claude
if [ -e ~/.claude ] || [ -L ~/.claude ]; then
  rm -rf ~/.claude
fi
