local g = vim.g
local o = vim.opt

o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true

o.splitbelow = true
o.splitright = true

o.hidden = true
o.updatetime = 750
o.laststatus = 3

o.fillchars = 'eob: '
o.whichwrap:append '<>'
o.cursorline = true
o.cmdheight = 0

o.number = true
o.relativenumber = true
o.signcolumn = 'number'
o.mouse = ''

-- Encoding
vim.cmd "let $LANG='en_US.UTF-8'"
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

o.termguicolors = true

o.langmap = 'ư]ơ[Ơ{Ư}'
o.scrolloff = 3
o.scroll = 10

-- disable some builtin vim plugins
local disabled_built_ins = {
  '2html_plugin',
  'getscript',
  'getscriptPlugin',
  'gzip',
  'logipat',
  'netrw',
  'netrwPlugin',
  'netrwSettings',
  'netrwFileHandlers',
  'matchit',
  'tar',
  'tarPlugin',
  'rrhelper',
  'spellfile_plugin',
  'vimball',
  'vimballPlugin',
  'zip',
  'zipPlugin',
}

for _, plugin in pairs(disabled_built_ins) do
  g['loaded_' .. plugin] = 1
end

-- Plugin: any-jump
g.any_jump_window_top_offset = 8
g.any_jump_disable_default_keybindings = 1

-- Plugin: vim-startify
g.startify_change_to_dir = 0

g.filetype = 'on'

-- Plugin: git-blame
g.gitblame_enabled = 0
g.gitblame_message_template = ' <author> • <sha> • <date> • <summary>'
g.gitblame_date_format = '%r'

-- Plugin: vim-smoothie
g.smoothie_speed_linear_factor = 30
g.smoothie_speed_constant_factor = 30
