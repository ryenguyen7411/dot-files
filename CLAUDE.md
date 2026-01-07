# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles configuration repository containing Neovim configs, shell configurations, terminal emulators, and development tool setups. The repository is managed with [GNU Stow](https://www.gnu.org/software/stow/) via Makefile.

## Installation and Setup

Prerequisites:
```bash
brew install stow
```

To install the dotfiles:
```bash
# Check prerequisites
make check

# Preview what will be installed
make dry-run

# Install all packages
make install

# Or install individual packages
make install-shell
make install-nvim
make install-kitty
make install-tmux
make install-git
make install-starship
make install-bat
make install-ai
make install-tools
```

This creates symbolic links for:
- Shell config (`~/.zshrc`, `~/.config/zsh/`)
- Neovim config (`~/.config/nvim`)
- Kitty config (`~/.config/kitty/kitty.conf`)
- Tmux config (`~/.tmux.conf.local`)
- Git config (`~/.gitconfig`)
- Starship prompt (`~/.config/starship.toml`)
- Bat config (`~/.config/bat/`)
- AI tools (`~/.claude`, `~/.codex`, `~/.config/opencode`)

## Architecture

### Neovim Configuration
- **Plugin Manager**: Uses Lazy.nvim for plugin management
- **Structure**:
  - `init.lua`: Main entry point, sets up Lazy.nvim and imports modules
  - `lua/settings.lua`: Core Neovim settings and options
  - `lua/mappings.lua`: Key mappings
  - `lua/autocmds.lua`: Auto commands
  - `lua/plugins/`: Plugin configurations organized by functionality
- **Key Features**:
  - Disabled built-in plugins for performance
  - Leader key: `<Space>`, Local leader: `,`
  - 2-space indentation, 120 character line width
  - Persistent undo, relative line numbers

### Code Style and Formatting

#### Lua (Neovim configs)
- Configured via `.stylua.toml`
- 2-space indentation, 120 character line width
- Single quotes preferred (`quote_style = "AutoPreferSingle"`)
- No call parentheses for single string/table args
- Module pattern: use `local M = {}` and return plugin spec

#### JavaScript/TypeScript
- ESLint configured with standard, standard-jsx, standard-react
- Semicolons required, comma-dangle on multiline
- Import ordering enforced
- JSX uses double quotes

### Claude Code Configuration
- Settings in `ai-tools/.claude/settings.json`
- Permissions allow git commands, curl, ls, yarn format/lint/type checks, web fetch, and MCP tools (context7, code-reasoning, octocode)
- Default mode: `bypassPermissions`

## Development Tools

### Linting and Formatting
- **Lua**: StyLua formatter (`.stylua.toml`)
- **JavaScript/TypeScript**: ESLint (`.eslintrc`)
- **Yarn commands**: `check-format`, `check-lint`, `check-types` (allowed in Claude permissions)
- **Make commands**: `make lint` (check), `make lint-fix` (auto-fix)

### Utilities
- `check_secure_input`: Python script to identify processes using macOS Secure Input
- `tms`: Tmux session manager for project-based workflows (installed to `~/.local/bin/tms`)

## Important Notes

- This is a configuration repository - no build/test commands are needed
- Focus on consistency with existing formatting and structure patterns
- Neovim config uses modern Lua API and disables legacy providers
- Terminal configurations support true color and Nerd Font icons
- All symbolic links are managed through GNU Stow via `make install` - avoid manual linking
