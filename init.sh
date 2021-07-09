#!/bin/bash#

# nvim
if [ ! -d ~/.config/nvim ]; then
  ln -s "$(pwd)/nvim" ~/.config/nvim
fi

# alacritty
if [ ! -e ~/.config/alacritty/alacritty.yml ]; then
  ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty/alacritty.yml
fi

# .zshrc
if [ ! -e ~/.zshrc ]; then
  ln -s "$(pwd)/.zshrc" ~/.zshrc
fi

# .tmux.conf.local
if [ ! -e ~/.tmux.conf.local ]; then
  ln -s "$(pwd)/.tmux.conf.local" ~/.tmux.conf.local
fi
