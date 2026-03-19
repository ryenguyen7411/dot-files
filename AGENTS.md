# Dot Files Repository - Agent Guidelines

## Project Type
Personal dotfiles configuration repository containing Neovim configs, shell configurations, terminal emulators, and development tool setups. Managed with [GNU Stow](https://www.gnu.org/software/stow/) via Makefile.

## Installation and Setup

Prerequisites:
```bash
brew install stow
```

Commands:
- **Prerequisites check**: `make check` - verifies stow and other tools are installed
- **Preview**: `make dry-run` - preview what stow would do
- **Install all**: `make install` - creates symbolic links via GNU Stow
- **Individual packages**: `make install-shell`, `make install-nvim`, `make install-kitty`, `make install-tmux`, `make install-git`, `make install-starship`, `make install-bat`, `make install-ai`, `make install-tools`

This creates symbolic links for:
- Shell config (`~/.zshrc`, `~/.config/zsh/`)
- Neovim config (`~/.config/nvim`)
- Kitty config (`~/.config/kitty/kitty.conf`)
- Tmux config (`~/.tmux.conf.local`)
- Git config (`~/.gitconfig`)
- Starship prompt (`~/.config/starship.toml`)
- Bat config (`~/.config/bat/`)
- AI tools (`~/.claude`, `~/.codex`, `~/.config/opencode`, `~/.cursor`)

## Cursor (user-level)

Stowed from `ai-tools/.cursor/` to `~/.cursor/`.

- **Rules** (`ai-tools/.cursor/rules/*.mdc`): `autonomous-execution` (**signal file only**, always on) and `quality-checks` (format / types / lint before completing code work, always on). `browser-testing` and `atlassian-mcp` are **on-demand** (`alwaysApply: false`) — loaded via **globs** or **description** so everyday chats stay lean.
- **Skills**: `skills/` (repeatable workflows), `skills-cursor/` (meta: create-rule, create-skill, etc.).
- **MCP**: `mcp.json` — no secrets in repo; use Cursor/Atlassian auth where applicable.

Stack- and repo-specific conventions should live in **that project’s** `.cursor/rules/` and `AGENTS.md`, not in dotfiles.

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

## Build/Lint/Test Commands
- **No build/test commands** - This is a configuration repository
- **Lua formatting**: `make lint` (check) / `make lint-fix` (auto-fix) - uses stylua via `.stylua.toml`
- **JS/TS linting**: ESLint configured in `.eslintrc` (standard, standard-jsx, standard-react)
- **Yarn commands**: `check-format`, `check-lint`, `check-types`
- **Make commands**: `make lint` (check), `make lint-fix` (auto-fix)

## Code Style Guidelines

### Lua (Neovim configs)
- Configured via `.stylua.toml`
- 2-space indentation, 120 character line width
- Single quotes preferred (`quote_style = "AutoPreferSingle"`)
- No call parentheses for single string/table args (`no_call_parentheses = true`)
- Module pattern: `local M = {}` and return plugin spec
- Format on save enabled via conform.nvim with stylua

### JavaScript/TypeScript
- Follow `standard`, `standard-jsx`, `standard-react` extends
- Semicolons required (`semi: ["error", "always"]`)
- Comma dangle on multiline (`comma-dangle: ["error", "always-multiline"]`)
- JSX uses double quotes (`jsx-quotes: ["error", "prefer-double"]`)
- Unix line endings, unused vars with `_` prefix ignored
- Import ordering enforced

### General
- Focus on dotfile consistency and Neovim plugin configuration
- Respect existing formatting and structure patterns
- Use descriptive variable names, avoid abbreviations
- Neovim config uses modern Lua API and disables legacy providers
- Terminal configurations support true color and Nerd Font icons
- All symbolic links are managed through GNU Stow via `make install` - avoid manual linking

## Utilities
- `check_secure_input`: Python script to identify processes using macOS Secure Input
- `tms`: Tmux session manager for project-based workflows (installed to `~/.local/bin/tms`)
