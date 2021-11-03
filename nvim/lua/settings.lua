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

o.number = true
o.relativenumber = true
o.signcolumn = 'number'
o.mouse = 'a'
o.mousemodel = 'popup_setpos'

-- Encoding
cmd('let $LANG=\'en_US.UTF-8\'')
o.encoding = 'utf-8'
o.fileencoding = 'utf-8'

-- Fix backspace indent
o.backspace = 'indent,eol,start'

-- Searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- indentLine
g.indentLine_char = '┆'
g.indentLine_faster = 1

-- coc.nvim
g.coc_global_extensions = { 'coc-stylelintplus', 'coc-eslint', 'coc-json', 'coc-tsserver' }

-- vim-startify
g.startify_change_to_dir = 0

-- lightline
cmd('let g:lightline = { "colorscheme": "tokyonight" }')

-- tokyonight
g.tokyonight_transparent = true

cmd('filetype on')
cmd('colorscheme tokyonight')
cmd('au VimEnter * highlight Normal ctermbg=NONE guibg=NONE')
cmd('au VimEnter * highlight NonText ctermbg=NONE guibg=NONE')
cmd('au VimEnter * highlight LineNr ctermbg=NONE guibg=NONE')
cmd('au VimEnter * highlight SignColumn ctermbg=NONE guibg=NONE')
cmd('au VimEnter * highlight EndOfBuffer ctermbg=NONE guibg=NONE')
cmd('au VimEnter * highlight Folded ctermfg=yellow')
