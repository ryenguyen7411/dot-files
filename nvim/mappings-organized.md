# Neovim Key Mappings Reference

A comprehensive guide to all custom key mappings in this Neovim configuration.

## Key Patterns

- **Leader Key**: `<Space>` (Space bar)
- **Local Leader Key**: `,` (Comma)
- **Configuration Source**: Most mappings defined in `~/projects/colorye/dot-files/nvim/init.lua`

## File and Project Operations

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>h` | Find Files | Search and open files using Snacks picker |
| `<Space>i` | Find Notes | Search files in ~/notes directory |
| `<Space>;` | Smart Find Files | Intelligent file finder with context |
| `<Space>k` | File Explorer | Open file explorer (Snacks.explorer) |
| `<Space>b` | Buffers | List and switch between open buffers |
| `<Space>j` | Grep | Search text content across project |
| `<Space>'` | Resume | Resume last picker/search |
| `<Space>l` | Project List | Browse and switch between projects |
| `<Space>n` | New File | Create new empty buffer |
| `<Space>w` | Write File | Save current file |
| `<Space>ư` | Write File | Alternative save mapping |
| `<Space>qq` | Close Buffer | Close current buffer smartly |

## Git Operations

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>f` | File History | View git history for current file |
| `<Space>r` | Diff View | Open git diff view |
| `<Space>,b` | Git Blame | Toggle git blame for current line |
| `[h` / `]h` | Prev/Next Hunk | Navigate between git hunks |
| `[H` / `]H` | First/Last Hunk | Jump to first/last hunk |
| `gh` | Apply Hunks | Apply git hunks |
| `gH` | Reset Hunks | Reset git hunks |

## Toggle Options (Space + u)

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>uD` | Toggle Dimming | Enable/disable inactive window dimming |
| `<Space>ug` | Toggle Indent Guides | Show/hide indentation guides |
| `<Space>uh` | Toggle Inlay Hints | Show/hide LSP inlay hints |
| `<Space>ub` | Toggle Dark Background | Switch between light/dark background |
| `<Space>uT` | Toggle Treesitter | Enable/disable syntax highlighting |
| `<Space>uc` | Toggle Conceallevel | Show/hide concealed text |
| `<Space>ul` | Toggle Line Numbers | Show/hide line numbers |
| `<Space>ud` | Toggle Diagnostics | Enable/disable LSP diagnostics |
| `<Space>uL` | Toggle Relative Numbers | Switch between absolute/relative line numbers |
| `<Space>uw` | Toggle Wrap | Enable/disable line wrapping |
| `<Space>us` | Toggle Spelling | Enable/disable spell checking |

## AI & Copilot Operations

### Next Edit Suggestions (NES)

| Key | Action | Description |
|-----|--------|-------------|
| `<M-l>` | Accept NES | Accept AI suggestion (Alt+L) |
| `<M-h>` | Reject NES | Reject AI suggestion (Alt+H) |
| `<M-]>` | Next Suggestion | Show next suggestion (Alt+]) |
| `<M-[>` | Previous Suggestion | Show previous suggestion (Alt+[) |
| `<Space>snu` | Update NES | Manually trigger new suggestion |
| `<Space>sne` | Enable NES | Enable Next Edit Suggestions |
| `<Space>snd` | Disable NES | Disable Next Edit Suggestions |
| `<Space>snc` | Clear NES | Clear current suggestion |

### Cursor CLI Integration

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>sct` | Toggle CLI | Open/close Cursor CLI window |
| `<Space>scs` | Send Selection | Send visual selection to Cursor (visual mode) |
| `<Space>scf` | Focus CLI | Focus the CLI window |
| `<Space>sch` | Hide CLI | Hide the CLI window |

## LSP Operations (g prefix)

| Key | Action | Description |
|-----|--------|-------------|
| `gra` | Code Action | Show available code actions |
| `grr` | References | Find all references to symbol |
| `gri` | Implementation | Go to implementation |
| `grn` | Rename | Rename symbol across project |
| `gO` | Document Symbol | Show document outline |
| `gcF` | Format Buffer | Format current buffer |
| `gD` | Declaration | Go to declaration |
| `gd` | Definition | Go to definition |
| `gy` | Type Definition | Go to type definition |
| `K` | Hover | Show hover information |
| `<C-K>` | Signature Help | Show signature help |

## Diagnostic Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `[d` / `]d` | Prev/Next Diagnostic | Navigate between diagnostics |
| `[D` / `]D` | First/Last Diagnostic | Jump to first/last diagnostic |
| `<C-W>d` | Show Diagnostics | Show diagnostics under cursor |

## Enhanced Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `*` / `#` | Search Word | Search word under cursor (with centering) |
| `N` / `n` | Next/Prev Search | Navigate search results (with centering) |
| `G` | Go to End | Jump to end of file (with centering) |
| `$` | End of Line | Go to end of line (mapped to `g_`) |
| `<C-J>` / `<C-K>` | Move 6 Lines | Move 6 lines down/up |
| `<C-D>` / `<C-U>` | Enhanced Page | Enhanced page down/up (10 lines) |
| `<Tab>` | Next Buffer | Switch to next buffer |

## Text Objects and Motions

| Key | Action | Description |
|-----|--------|-------------|
| `f` / `F` | Jump Forward/Back | Smart jump to character |
| `t` / `T` | Jump Till Forward/Back | Smart jump till character |
| `;` | Repeat Jump | Repeat last jump motion |
| `ai` | Full Scope | Select full scope textobject |
| `[i` / `]i` | Scope Edge | Jump to top/bottom edge of scope |

## Editing Operations

| Key | Action | Description |
|-----|--------|-------------|
| `U` | Redo | Redo last change |
| `YY` | Copy All | Copy entire buffer to system clipboard |
| `S` | Add Surrounding | Add surrounding in visual mode |
| `cs` / `ds` | Change/Delete Surrounding | Modify surrounding characters |
| `gs` | Toggle Arguments | Toggle function arguments layout |
| `gcc` / `gc` | Comment | Comment line/selection |
| `d` | Delete to Clipboard | Delete to system clipboard (visual) |

## Visual Selection Movement

| Key | Action | Description |
|-----|--------|-------------|
| `J` / `K` | Move Selection | Move selection down/up |
| `<` / `>` | Move Selection | Move selection left/right |

## Special Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>a` | Todo Telescope | Search TODO comments |
| `<Space><Space>` | Toggle Syntax | Toggle syntax highlighting |
| `<Space>vs` / `<Space>vp` | Profile | Pause/start Neovim profiling |
| `<Esc>` | Clear All | Clear highlights and close quickfix |
| `<C-T>` | Terminal | Toggle terminal (vertical, size 60) |
| `zp` | Zen Mode | Toggle zen/focus mode |
| `gb` | Show Path | Show current file path |
| `gT` | Inspect | Inspect element under cursor |
| `co` / `cp` | Curl | Open/close curl operations |
| `00` | Clear & Close | Clear file and close window |
| `0\` | Custom Action | Execute custom lua function |

## Folding Operations

| Key | Action | Description |
|-----|--------|-------------|
| `zo` / `zf` | Open/Create Fold | Open existing or create new fold |
| `zc` | Close Fold | Close fold under cursor |
| `za` | Toggle Fold | Toggle fold open/closed |

## Search Operations

| Key | Action | Description |
|-----|--------|-------------|
| `/` | Search in Visual | Search within visual selection |
| `?` | Search Backward | Search backward in buffer |

## System Integration

| Key | Action | Description |
|-----|--------|-------------|
| `"*` | System Clipboard | Operations using system clipboard |
| `"+` | Primary Selection | Operations using primary selection |

## Plugin-Specific Features

This configuration leverages several modern Neovim plugins:

- **Snacks.nvim**: File picker, explorer, and utilities
- **Mini.nvim Suite**: Jump, move, surround, comment, and more
- **Sidekick.nvim**: AI-powered Next Edit Suggestions (NES) and CLI integration
- **Supermaven**: Inline AI code completions
- **CodeCompanion**: AI-powered code assistance
- **Hardtime**: Movement restrictions for better habits
- **Diffview**: Git diff and merge operations
- **Telescope**: Fuzzy finding and selection
- **Treesitter**: Enhanced syntax highlighting and text objects

## Notes

- Most mappings include `zz` for automatic centering
- System clipboard integration is built into many operations
- Consistent prefix patterns make mappings easy to remember
- Visual mode mappings often have normal mode equivalents
- Configuration emphasizes efficiency and minimal keystrokes
