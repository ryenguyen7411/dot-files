local cmd = vim.cmd
local g = vim.g
local o = vim.opt

o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true

o.splitbelow = true
o.splitright = true

o.hidden = true
o.updatetime = 250
o.autoread = true
o.lazyredraw = true

o.fillchars = 'eob: '
o.whichwrap:append "<>hl"
o.cursorline = true
cmd('set noshowmode')

o.number = true
o.relativenumber = true
o.signcolumn = 'number'
o.mouse = 'a'
o.mousemodel = 'popup_setpos'

-- Encoding
cmd('let $LANG=\'en_US.UTF-8\'')
o.encoding = 'utf-8'
o.fileencoding = 'utf-8'
o.backupcopy = 'yes'

-- Fix backspace indent
o.backspace = 'indent,eol,start'

-- Searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- disable some builtin vim plugins
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

for _, plugin in pairs(disabled_built_ins) do
   g["loaded_" .. plugin] = 1
end

local transparents = {
  'Normal',
  'NonText',
  'LineNr',
  'SignColumn',
  'EndOfBuffer',
  'NormalFloat',
  'FloatBorder',
  'TelescopeNormal',
  'TelescopeBorder',
}

for _, part in pairs(transparents) do
  cmd('au VimEnter * highlight ' .. part .. ' ctermbg=NONE guibg=NONE')
end

-- Plugin: any-jump
g.any_jump_window_top_offset = 8
g.any_jump_disable_default_keybindings = 1

-- vim-startify
g.startify_change_to_dir = 0

-- lightline
g.lightline = {
  colorscheme = "tokyonight"
}

-- tokyonight
g.tokyonight_transparent = true
g.tokyonight_colors = {
  diff = {
    text = '#3b4f77'
  }
}

g.quickrun_config = {
  outputter = 'outputter/loclist'
}

cmd('filetype on')
cmd('colorscheme tokyonight')
