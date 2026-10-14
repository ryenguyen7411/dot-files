vim.g.have_nerd_font = true -- Enable Nerd Font support for icons
vim.g.loaded_python3_provider = 0 -- Disable Python 3 provider
vim.g.loaded_perl_provider = 0 -- Disable Perl provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider
vim.g.loaded_node_provider = 0 -- Disable Node.js provider

vim.env.LANG = 'en_US.UTF-8' -- Set language environment variable

vim.opt.backspace = 'indent,eol,start' -- Allow backspace over everything
vim.opt.backup = false -- No backup files
vim.opt.backupcopy = 'yes' -- Use copy method for backup
vim.opt.breakindent = true -- Enable break indent
vim.opt.cmdheight = 0 -- Hide command line unless needed
vim.opt.cursorline = true -- Highlight current line
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

vim.filetype.add {
  extension = { mdc = 'markdown', hbs = 'html', cshtml = 'html' },
  filename = { Fastfile = 'ruby' },
}

-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false -- Make keymaps silent unless specified
  return keymap_set(mode, lhs, rhs, opts)
end

-- Clipboard. `y`/`d`/`x` write to "* (mappings.lua), so these decide where a yank ends up.
-- SSH_CONNECTION is not trusted inside tmux: an SSH client attaching to a session leaves it in the
-- session environment, so later local panes would look remote and pick OSC 52.
local is_remote = vim.env.TMUX ~= nil or vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil

-- Put lines on the clipboard of the terminal showing this nvim, over SSH too, with OSC 52 ("c" is
-- the clipboard Cmd+V reads; "p" would be the primary selection). Inside tmux it goes straight to
-- the tmux client's tty, so this host's tmux config and the outer terminal's type don't matter;
-- a local tmux in between needs set-clipboard on to pass it to Kitty.
local function osc52_send(lines)
  local seq = string.format('\027]52;c;%s\027\\', vim.base64.encode(table.concat(lines, '\n')))
  if vim.env.TMUX then
    local tty = vim.trim(vim.fn.system { 'tmux', 'display-message', '-p', '#{client_tty}' })
    local f = vim.v.shell_error == 0 and tty ~= '' and io.open(tty, 'w')
    if f then
      f:write(seq)
      f:close()
      return
    end
  end
  vim.api.nvim_ui_send(seq)
end

if vim.fn.executable 'pbcopy' == 1 then
  -- macOS: the built-in pbcopy/pbpaste provider. In tmux or over SSH, also send OSC 52 so the
  -- clipboard of the machine you are typing on gets the yank too.
  if is_remote then
    vim.api.nvim_create_autocmd('TextYankPost', {
      group = vim.api.nvim_create_augroup('osc52_yank', { clear = true }),
      callback = function()
        local reg = vim.v.event.regname
        if reg == '*' or reg == '+' then
          osc52_send(vim.v.event.regcontents)
        end
      end,
    })
  end
elseif is_remote then
  -- Remote host without pbcopy: copy via OSC 52. Paste the last copy: an OSC 52 read gets no
  -- answer through tmux and blocks for 10s; Cmd+V still pastes the local clipboard.
  local last = { {}, 'v' }
  local function copy(lines, regtype)
    last = { lines, regtype }
    osc52_send(lines)
  end
  local function paste()
    return last
  end
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = copy, ['*'] = copy },
    paste = { ['+'] = paste, ['*'] = paste },
  }
end
