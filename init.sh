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
if [ -d ~/.config/opencode ]; then
  if [ ! -e ~/.config/opencode/opencode.json ]; then
    ln -s "$(pwd)/opencode.config.json" ~/.config/opencode/opencode.json
  fi
fi
