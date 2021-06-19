#!/bin/bash#

# Nvim
if [ -e ~/.config/nvim/init.vim ]; then
  rm ~/.config/nvim/init.vim
fi
if [ -e ~/.config/nvim/coc-settings.json ]; then
  rm ~/.config/nvim/coc-settings.json
fi

# Alacritty
if [ -e ~/.config/alacritty/alacritty.yml ]; then
  rm ~/.config/alacritty/alacritty.yml
fi

