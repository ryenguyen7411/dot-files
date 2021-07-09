#!/bin/bash#

# Nvim
if [ -d ~/.config/nvim ]; then
  rm -rf ~/.config/nvim
fi

# Alacritty
if [ -e ~/.config/alacritty/alacritty.yml ]; then
  rm ~/.config/alacritty/alacritty.yml
fi
