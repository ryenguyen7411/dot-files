# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles configuration repository containing Neovim configs, shell configurations, terminal emulators, and development tool setups. The repository is managed through symbolic links created by the `init.sh` script.

## Installation and Setup

To install the dotfiles, run:
```bash
./init.sh
```

This script creates symbolic links for:
- Neovim config (`~/.config/nvim`)
- Alacritty config (`~/.config/alacritty/alacritty.yml`)
- Shell config (`~/.zshrc`)
- Tmux config (`~/.tmux.conf.local`)
- Kitty config (`~/.config/kitty/kitty.conf`)
- Ripgrep/fd ignore files (`~/.config/rg/.rgignore`, `~/.config/fd/.fdignore`)
- OpenCode config (`~/.config/opencode`)
- Claude config (`~/.claude`)

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
- Settings in `claude/settings.json`
- Permissions allow git commands, curl, ls, yarn format/lint/type checks and web fetch
- Default mode: `acceptEdits`

## Development Tools

### Linting and Formatting
- **Lua**: StyLua formatter (`.stylua.toml`)
- **JavaScript/TypeScript**: ESLint (`.eslintrc`)
- **Yarn commands**: `check-format`, `check-lint`, `check-types` (allowed in Claude permissions)

### Utilities
- `check_secure_input`: Python script to identify processes using macOS Secure Input
- `dein.sh`: Legacy plugin manager script

## Important Notes

- This is a configuration repository - no build/test commands are needed
- Focus on consistency with existing formatting and structure patterns
- Neovim config uses modern Lua API and disables legacy providers
- Terminal configurations support true color and Nerd Font icons
- All symbolic links are managed through `init.sh` - avoid manual linking
