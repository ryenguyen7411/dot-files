# Dotfiles

Personal configuration files for macOS development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Features

- **Neovim** - Modern Lua-based config with lazy.nvim, LSP, Treesitter, and Telescope
- **Zsh** - Modular shell configuration with oh-my-zsh and performance optimizations
- **Tmux** - Custom theming with [oh-my-tmux](https://github.com/gpakosz/.tmux) and `tms` session manager
- **Kitty** - GPU-accelerated terminal with Hack Nerd Font
- **AI Tools** - Configurations for Claude, Codex, and OpenCode

## Prerequisites

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages from Brewfile
brew bundle

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Installation

```bash
# Clone the repository
git clone https://github.com/colorye/dot-files.git ~/projects/colorye/dot-files
cd ~/projects/colorye/dot-files

# Check prerequisites
make check

# Preview what will be installed (dry run)
make dry-run

# First-time install (adopts existing configs)
make backup           # Optional: backup existing configs
make install-adopt    # Install, adopting existing files

# Or fresh install (fails if configs already exist)
make install

# Or install individual packages
make install-shell
make install-nvim
make install-kitty
make install-tmux
make install-git
make install-ai
```

## Structure

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
├── tools/              # Standalone tools
│   └── tms             # Tmux session manager
└── ai-tools/           # AI assistant configs
    ├── claude/
    ├── codex/
    └── opencode/
```

## Stow Packages

Each directory is a "stow package" that mirrors your home directory structure:

| Package | Contents |
|---------|----------|
| `shell` | `.zshrc`, `.config/zsh/*` |
| `nvim` | `.config/nvim/*` |
| `kitty` | `.config/kitty/kitty.conf` |
| `tmux` | `.tmux.conf.local`, `.config/tmux-sessions/*` |
| `git` | `.gitconfig` |
| `ai-tools` | `.claude/`, `.codex/`, `.config/opencode/` |

## Machine-Specific Configuration

Set your machine name for tmux session configs:

```bash
# In ~/.env.local
export MACHINE_NAME=work  # or 'home', 'default'
```

Then copy and customize:
```bash
cp shell/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

## Key Bindings

### Neovim
- **Leader**: `<Space>`
- **Local Leader**: `,`
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>e` - File explorer (Oil)

### Tmux
- **Prefix**: `Ctrl+a`
- `prefix + |` - Split vertical
- `prefix + -` - Split horizontal

### tms (Tmux Session Manager)
```bash
tms              # Interactive project picker
tms start NAME   # Open project window
tms stop NAME    # Close project window
tms add          # Add new project
tms list         # List all projects
```

## Updating

```bash
make update      # Update Neovim plugins
make lint        # Check Lua formatting
```

## License

MIT
