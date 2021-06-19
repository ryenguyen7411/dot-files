#!/bin/bash#

# Nvim
if [ ! -e ~/.config/nvim/init.vim ]; then
  ln -s "$(pwd)/nvim/init.vim" ~/.config/nvim/init.vim
fi
if [ ! -e ~/.config/nvim/coc-settings.json ]; then
  ln -s "$(pwd)/nvim/coc-settings.json" ~/.config/nvim/coc-settings.json
fi

# Alacritty
if [ ! -e ~/.config/alacritty/alacritty.yml ]; then
  ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty/alacritty.yml
fi

