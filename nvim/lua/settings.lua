vim.g.have_nerd_font = true -- Enable Nerd Font support for icons
vim.g.filetype = 'on' -- Enable filetype detection
vim.g.loaded_python3_provider = 0 -- Disable Python 3 provider
vim.g.loaded_perl_provider = 0 -- Disable Perl provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider
vim.g.loaded_node_provider = 0 -- Disable Node.js provider

vim.env.LANG = 'en_US.UTF-8' -- Set language environment variable

vim.opt.backspace = 'indent,eol,start' -- Allow backspace over everything
vim.opt.backup = false -- Enable backup files
vim.opt.backupcopy = 'yes' -- Use copy method for backup
vim.opt.breakindent = true -- Enable break indent
vim.opt.cmdheight = 0 -- Hide command line unless needed
vim.opt.cursorline = true -- Highlight current line
vim.opt.encoding = 'utf-8' -- Set internal encoding
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.fileencoding = 'utf-8' -- Set file encoding
vim.opt.fillchars = 'eob: ' -- Remove ~ from empty lines
vim.opt.hidden = true -- Allow buffer switching without saving
vim.opt.hlsearch = true -- Highlight search matches
vim.opt.ignorecase = true -- Ignore case in searches
vim.opt.incsearch = true -- Show search matches as you type
vim.opt.langmap = 'ư]ơ[Ơ{Ư}' -- Keyboard language mapping
vim.opt.laststatus = 3 -- Global statusline
vim.opt.maxmempattern = 2000 -- Max memory for pattern matching
vim.opt.mouse = '' -- Disable mouse support
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.scroll = 10 -- Scroll 10 lines at a time
vim.opt.scrolloff = 3 -- Keep 3 lines above/below cursor
vim.opt.shiftwidth = 2 -- Indent by 2 spaces
vim.opt.showmode = false -- Don't show mode in command line
vim.opt.signcolumn = 'number' -- Show signs in number column
vim.opt.smartcase = true -- Override ignorecase if uppercase used
vim.opt.splitbelow = true -- Horizontal splits open below
vim.opt.splitright = true -- Vertical splits open right
vim.opt.tabstop = 2 -- Tab character is 2 spaces
vim.opt.termguicolors = true -- Enable true color support
vim.opt.timeout = true -- Enable mapping timeout
vim.opt.timeoutlen = 500 -- Timeout length in ms
vim.opt.undofile = true -- Enable persistent undo
vim.opt.updatetime = 750 -- Faster CursorHold events
vim.opt.whichwrap:append '<>' -- Allow left/right keys to wrap lines

-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false -- Make keymaps silent unless specified
  return keymap_set(mode, lhs, rhs, opts)
end

local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil

if is_ssh then
  -- Remote: OSC 52 → local clipboard
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste '+',
      ['*'] = require('vim.ui.clipboard.osc52').paste '*',
    },
    osc52 = {
      max_length = 100000,
    },
  }
else
  -- Local: native system clipboard
  vim.opt.clipboard = 'unnamedplus'
end
