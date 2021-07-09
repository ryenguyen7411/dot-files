#!/bin/bash#

# Nvim
if [ ! -d ~/.config/nvim ]; then
  ln -s "$(pwd)/nvim" ~/.config/nvim
fi

# Alacritty
if [ ! -e ~/.config/alacritty/alacritty.yml ]; then
  ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty/alacritty.yml
fi
