#!/bin/bash#

if [ ! -e ~/.config/alacritty/alacritty.yml ]; then
  ln -s "$(pwd)/alacritty.yml" ~/.config/alacritty/alacritty.yml
fi
