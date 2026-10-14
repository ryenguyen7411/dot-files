```
     _       _         __ _ _
  __| | ___ | |_      / _(_) | ___  ___
 / _` |/ _ \| __|____| |_| | |/ _ \/ __|
| (_| | (_) | ||_____|  _| | |  __/\__ \
 \__,_|\___/ \__|    |_| |_|_|\___||___/
```

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.11+-57A143?style=flat-square&logo=neovim&logoColor=white" alt="Neovim">
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
| **Neovim** | Lua-based config with lazy.nvim, LSP, Treesitter, Snacks picker, and Oil |
| **Zsh** | Modular shell on zinit (turbo mode) with Oh My Zsh library snippets and the robbyrussell prompt |
| **Tmux** | Custom theming via [oh-my-tmux](https://github.com/gpakosz/.tmux) + `tms` session manager |
| **Kitty** | GPU-accelerated terminal with Hack Nerd Font |
| **Git** | Sensible defaults, delta pager, global ignore, automatic work identity for `~/projects/be/` |
| **Bat** | Syntax highlighting for `cat` with custom themes |
| **Raycast** | Custom Script Commands for multi-monitor jump and image optimization |

## 🚀 Quick Start

```bash
# Clone it
git clone https://github.com/ryenguyen7411/dot-files.git ~/projects/colorye/dot-files
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
```

Zinit (the zsh plugin manager) and Oh my tmux! are installed automatically on first use.

### Full Install

```bash
# Backup existing configs (optional but recommended)
make backup

# Install everything
make install

# Or pick what you need
make install-shell     # Zsh config (.zshrc, .zprofile, ~/.config/zsh)
make install-nvim      # Neovim
make install-kitty     # Kitty terminal
make install-tmux      # Tmux (clones Oh my tmux! if missing)
make install-git       # Git config + global ignore
make install-starship  # Starship prompt config (prompt init is off; robbyrussell is used)
make install-bat       # Bat themes
make install-raycast   # Raycast script commands
make install-search    # fd/rg ignore files used by the Neovim pickers
make install-ssh       # SSH config (needs ssh/.ssh/config.local)
make install-tools     # Standalone tools (tms, jump-display, etc.), rebuilt when changed
```

### Ubuntu Server

```bash
git clone https://github.com/ryenguyen7411/dot-files.git ~/projects/colorye/dot-files
cd ~/projects/colorye/dot-files
./tools/install-ubuntu-server.sh   # needs sudo; safe to re-run (fresh Ubuntu has no make)
```

Stows `shell`, `nvim`, `git`, `bat` and `mise`, makes zsh the login shell, and installs the CLI tools in
`mise/.config/mise/config.toml` (Neovim, fzf, ripgrep, fd, bat, eza, zoxide, yq, atuin, direnv, delta,
difftastic, lazygit, k9s, dust) as current release binaries through [mise](https://mise.jdx.dev). tmux is
installed with its stock config, so it nests cleanly inside the Mac's tmux. Neovim plugins are pinned to
`lazy-lock.json` (bump them on the Mac with `make update`, commit the lockfile). On the server, update with
`mise up` (tools) and `git pull && nvim --headless "+Lazy! restore" +qa` (plugins).

### Machine-Specific Setup

```bash
# Machine-specific shell config (MACHINE_NAME picks the tmux-sessions layout: home, work, default)
cp shell/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh

# Work-only shell helpers (e.g. `swe`) go in ~/.config/zsh/work.zsh (untracked: this repo is public)

# Git identity: personal in ~/.gitconfig-local, work (used under ~/projects/be/) in ~/.gitconfig-work
cp git/.gitconfig-local.example ~/.gitconfig-local
cp git/.gitconfig-work.example ~/.gitconfig-work
```

## 🗂 Structure

```
dot-files/
├── shell/              # Zsh configuration (modular)
│   ├── .zshrc          # Main loader
│   ├── .zprofile       # Login shells (Homebrew, OrbStack)
│   └── .config/zsh/    # Modules (aliases, functions, etc.)
├── nvim/               # Neovim configuration
│   └── .config/nvim/
├── kitty/              # Kitty terminal
│   └── .config/kitty/
├── tmux/               # Tmux configuration
│   └── .tmux.conf.local
├── git/                # Git configuration
│   ├── .gitconfig
│   └── .config/git/ignore  # Global ignores
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
├── ssh/                # SSH config template (config.local is untracked)
├── launchd/            # LaunchAgent for the jump-desktop watcher
└── .ignore             # fd/rg ignore list for the Neovim pickers (make install-search)
```

### Stow Packages

Each directory is a "stow package" that mirrors your home directory:

| Package | Creates |
|---------|---------|
| `shell` | `~/.zshrc`, `~/.zprofile`, `~/.config/zsh/*` |
| `nvim` | `~/.config/nvim/*` |
| `kitty` | `~/.config/kitty/kitty.conf` |
| `tmux` | `~/.tmux.conf.local` |
| `git` | `~/.gitconfig`, `~/.config/git/ignore` |
| `starship` | `~/.config/starship.toml` |
| `bat` | `~/.config/bat/*` |
| `raycast` | `~/.config/raycast/scripts/*` |
| `mise` | `~/.config/mise/config.toml` (Ubuntu servers only) |

## ⌨️ Key Bindings

### Neovim

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `,` | Local Leader |
| `<leader>h` | Find files |
| `<leader>j` | Grep |
| `<leader>;` | Smart find (frecency) |
| `<leader>b` | Buffers |
| `<leader>k` | File explorer |
| `<leader>o` | Oil (floating) |
| `<leader>l` | Projects |
| `<leader>0` | Close all buffers |
| `00` | In a commit message / rebase todo: abort (`:cq`) |

### Tmux

| Key | Action |
|-----|--------|
| `` ` `` | Prefix (backtick) |
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |
| `Ctrl+p` | Open `tms` Project Manager popup |
| `Ctrl+o` | Open Claude popup |
| `Ctrl+y` | Open Opencode popup |

`Ctrl+p`, `Ctrl+o` and `Ctrl+y` are passed through to Neovim when the pane runs nvim (jump back, scroll, etc.).
| `prefix + u` | Spread & equalize layout |
| `prefix + U` | Restore previous layout |

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

### jump-desktop - Desktop / Space Switcher with Window Autofocus

Autofocuses the frontmost window on the destination space whenever you switch Desktops (via keyboard `Ctrl + Left/Right`, trackpad gesture, or Raycast), or on-demand:

```bash
jump-desktop focus           # Autofocus top window on current desktop right now
jump-desktop --watch         # Background watcher daemon (managed via LaunchAgent)
```

### clean-url - Instant Tracker Stripper & URL Cleaner

Strips tracking query parameters (`utm_*`, `fbclid`, `gclid`, `si`, etc.) from URLs and clipboard:

```bash
clean-url "https://youtu.be/xyz?si=track123&utm_source=share"
clean-url                    # Clean current clipboard content in-place
clean-url --watch            # Run lightweight background watcher on clipboard
```

### link-router - Cross-Browser & Multi-Profile Smart URL Router

Routes URLs to specific browsers and profiles (e.g. Work vs Personal) based on customizable domain rules in `~/.config/link-router/rules.json`:

```bash
link-router "https://gitlab.company.com/project"   # Routes to Chrome Work profile
link-router "https://youtube.com/watch?v=..."       # Routes to Arc personal browser
link-router config                                 # View/edit rules in editor
```

### Raycast Script Commands

Integrates `jump-display` and Shottr utilities into Raycast with 0ms delay:

1. In Raycast, go to **Settings (`Cmd + ,`) -> Extensions**.
2. Click **Add Extension (`+`) -> Add Script Directory** and select `~/.config/raycast/scripts`.
3. Assign hotkeys to commands (e.g. `Jump to Next Display`).

## 🔄 Updating

```bash
make update      # Update Neovim plugins
make lint        # stylua + shellcheck + zsh syntax check
make lint-fix    # Auto-fix Lua formatting
make brew-check  # Drift between the Brewfile and what's installed
make brew-dump   # Update Brewfile from installed packages
```

## 📄 License

MIT — do whatever you want with it.

---

<p align="center">
  <sub>Made with ☕ and occasional mass of frustration</sub>
</p>
