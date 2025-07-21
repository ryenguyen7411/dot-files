# Dot Files Repository - Agent Guidelines

## Project Type
Personal dotfiles configuration repository containing Neovim configs, shell configs, and linting rules.

## Build/Lint/Test Commands
- **No build/test commands** - This is a configuration repository
- **Lua formatting**: `stylua .` (configured via `.stylua.toml`)
- **JS/TS linting**: ESLint configured in `.eslintrc` (standard, standard-jsx, standard-react)
- **Installation**: `./init.sh` creates symbolic links to home directory

## Code Style Guidelines

### Lua (Neovim configs)
- Use 2-space indentation, 120 character line width
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

### General
- Focus on dotfile consistency and Neovim plugin configuration
- Respect existing formatting and structure patterns
- Use descriptive variable names, avoid abbreviations
- Leader key: `<Space>`, Local leader: `,`