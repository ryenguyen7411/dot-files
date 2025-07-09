# Dot Files Repository - Agent Guidelines

## Project Type
Personal dotfiles configuration repository containing Neovim configs, shell configs, and linting rules.

## Code Style Guidelines

### Lua (Neovim configs)
- Use 2-space indentation
- Single quotes preferred (`quote_style = "AutoPreferSingle"`)
- No call parentheses for single string/table args (`no_call_parentheses = true`)
- 120 character line width
- Module pattern: expose functions via `M` table and return plugin spec
- Use `local M = {}` pattern for modules

### JavaScript/TypeScript
- Use Prettier for formatting with ESLint
- Follow `standard-with-typescript` and `prettier` extends
- Sort imports alphabetically (`import/order` rule)
- No explicit function return types (`@typescript-eslint/explicit-function-return-type: off`)

### General
- This is a configuration repository - no build/test commands available
- Focus on dotfile consistency and Neovim plugin configuration
- Respect existing formatting and structure patterns