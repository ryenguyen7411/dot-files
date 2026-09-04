```
     _       _         __ _ _
  __| | ___ | |_      / _(_) | ___  ___
 / _` |/ _ \| __|____| |_| | |/ _ \/ __|
| (_| | (_) | ||_____|  _| | |  __/\__ \
 \__,_|\___/ \__|    |_| |_|_|\___||___/
```

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.10+-57A143?style=flat-square&logo=neovim&logoColor=white" alt="Neovim">
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/Zsh-F15A24?style=flat-square&logo=zsh&logoColor=white" alt="Zsh">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License">
</p>

---

Personal configuration files for my development environment (mostly macOS), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 📑 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Structure](#-structure)
- [Key Bindings](#-key-bindings)
- [Tools](#-tools)
- [Updating](#-updating)
- [License](#-license)

## ✨ Features

| Tool | What's Inside |
|------|---------------|
| **Neovim** | Lua-based config with lazy.nvim, LSP, Treesitter, Telescope, and Oil |
| **Zsh** | Modular shell with oh-my-zsh, starship prompt, and performance tweaks |
| **Tmux** | Custom theming via [oh-my-tmux](https://github.com/gpakosz/.tmux) + `tms` session manager |
| **Kitty** | GPU-accelerated terminal with Hack Nerd Font |
| **Git** | Sensible defaults and useful aliases |
| **Bat** | Syntax highlighting for `cat` with custom themes |
| **Raycast** | Custom Script Commands for multi-monitor jump and image optimization |

## 🚀 Quick Start

```bash
# Clone it
git clone https://github.com/colorye/dot-files.git ~/projects/colorye/dot-files
cd ~/projects/colorye/dot-files

# Check you have what you need
make check

# See what will happen (dry run)
make dry-run

# Ship it
make install
```

## 📦 Installation

### Prerequisites

```bash
# Homebrew (if you don't have it yet)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages from Brewfile
brew bundle

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Full Install

```bash
# Backup existing configs (optional but recommended)
make backup

# Install everything
make install

# Or pick what you need
make install-shell     # Zsh config
make install-nvim      # Neovim
make install-kitty     # Kitty terminal
make install-tmux      # Tmux
make install-git       # Git config
make install-starship  # Starship prompt
make install-bat       # Bat themes
make install-raycast   # Raycast script commands
make install-tools     # Standalone tools (tms, jump-display, etc.)
```

### Machine-Specific Setup

```bash
# Set your machine name in ~/.config/zsh/local.zsh (used for tmux-sessions, etc.)
export MACHINE_NAME=work  # or 'home', 'default'

# Copy and customize local config
cp shell/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

## 🗂 Structure

```
dot-files/
├── shell/              # Zsh configuration (modular)
│   ├── .zshrc          # Main loader
│   └── .config/zsh/    # Modules (aliases, functions, etc.)
├── nvim/               # Neovim configuration
│   └── .config/nvim/
├── kitty/              # Kitty terminal
│   └── .config/kitty/
├── tmux/               # Tmux configuration
│   └── .tmux.conf.local
├── git/                # Git configuration
│   └── .gitconfig
├── starship/           # Starship prompt
│   └── .config/starship.toml
├── bat/                # Bat syntax highlighter
│   └── .config/bat/
├── raycast/            # Raycast Script Commands
│   └── .config/raycast/scripts/
├── tools/              # Standalone tools
│   ├── tms             # Tmux session manager
│   ├── jump-display.swift # Multi-monitor cursor teleport utility
│   └── imgcopy.swift   # Clipboard image utility
├── tmux-sessions/      # Machine-specific tmux layouts
│   ├── home/
│   ├── work/
│   └── default/
```

### Stow Packages

Each directory is a "stow package" that mirrors your home directory:

| Package | Creates |
|---------|---------|
| `shell` | `~/.zshrc`, `~/.config/zsh/*` |
| `nvim` | `~/.config/nvim/*` |
| `kitty` | `~/.config/kitty/kitty.conf` |
| `tmux` | `~/.tmux.conf.local` |
| `git` | `~/.gitconfig` |
| `starship` | `~/.config/starship.toml` |
| `bat` | `~/.config/bat/*` |
| `raycast` | `~/.config/raycast/scripts/*` |

## ⌨️ Key Bindings

### Neovim

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `,` | Local Leader |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>e` | File explorer (Oil) |

### Tmux

| Key | Action |
|-----|--------|
| `Ctrl+a` | Prefix |
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |

## 🛠 Tools

### tms - Tmux Session Manager

A handy script for managing project-based tmux sessions:

```bash
tms              # Interactive project picker
tms start NAME   # Open project window
tms stop NAME    # Close project window
tms add          # Add new project
tms list         # List all projects
```

### jump-display - Instant Multi-Monitor Cursor Teleport

A fast native Swift binary for moving mouse cursor across connected displays:

```bash
jump-display next            # Jump to next monitor relative to current cursor
jump-display next --focus    # Jump to next monitor and activate window under cursor
jump-display 1               # Jump to display 1 (leftmost)
jump-display 2               # Jump to display 2
jump-display list            # List connected monitors and positions
```

### Raycast Script Commands

Integrates `jump-display` and Shottr utilities into Raycast with 0ms delay:

1. In Raycast, go to **Settings (`Cmd + ,`) -> Extensions**.
2. Click **Add Extension (`+`) -> Add Script Directory** and select `~/.config/raycast/scripts`.
3. Assign hotkeys to commands (e.g. `Jump to Next Display`).

## 🔄 Updating

```bash
make update      # Update Neovim plugins
make lint        # Check Lua formatting
make lint-fix    # Auto-fix Lua formatting
make brew-dump   # Update Brewfile from installed packages
```

## 📄 License

MIT — do whatever you want with it.

---

<p align="center">
  <sub>Made with ☕ and occasional mass of frustration</sub>
</p>
