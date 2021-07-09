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
