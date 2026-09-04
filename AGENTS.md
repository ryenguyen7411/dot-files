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
- **Individual packages**: `make install-shell`, `make install-nvim`, `make install-kitty`, `make install-tmux`, `make install-git`, `make install-starship`, `make install-bat`, `make install-raycast`, `make install-tools`

This creates symbolic links for:
- Shell config (`~/.zshrc`, `~/.config/zsh/`)
- Neovim config (`~/.config/nvim`)
- Kitty config (`~/.config/kitty/kitty.conf`)
- Tmux config (`~/.tmux.conf.local`)
- Git config (`~/.gitconfig`)
- Starship prompt (`~/.config/starship.toml`)
- Bat config (`~/.config/bat/`)
- Raycast Script Commands (`~/.config/raycast/scripts/`)

Project-specific documentation and tooling config belong in **each application repository**, not in this dotfiles repo.

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
- `shottr-optimize`: Optimizes screenshot/clipboard image or image file with ImageOptim and copies optimized image back to clipboard (installed to `~/.local/bin/shottr-optimize`)
- `shottr-upload`: Uploads screenshot from clipboard or any file/directory to File.kiwi (auto-optimizes images with ImageOptim) and copies download link to clipboard (installed to `~/.local/bin/shottr-upload`)
- `imgcopy`: Native macOS clipboard image copy utility (installed to `~/.local/bin/imgcopy`)
- `jump-display`: Teleports mouse cursor across connected monitors dynamically or via env overrides (installed to `~/.local/bin/jump-display`)

### Raycast Script Commands
Stored in `raycast/.config/raycast/scripts/` and installed to `~/.config/raycast/scripts/` via `make install` or `make install-raycast`:
- `jump-display-next.sh`: Teleport mouse cursor to next display and automatically focus the top window.
- `jump-display-1.sh`: Teleport mouse cursor to display 1 and focus the top window.
- `jump-display-2.sh`: Teleport mouse cursor to display 2 and focus the top window.
- `jump-display-3.sh`: Teleport mouse cursor to display 3 and focus the top window.
- `shottr-optimize.sh`: Optimize clipboard image or screenshot with ImageOptim.
- `shottr-upload.sh`: Optimize clipboard image and upload to File.kiwi.

Setup in Raycast on any machine:
1. Open Raycast Settings (`Cmd + ,`) -> **Extensions**.
2. Click **Add Extension** / `+` -> **Add Script Directory**.
3. Select `~/.config/raycast/scripts`.
4. Assign global hotkeys directly in Raycast Settings (e.g. `Jump to Next Display`).
