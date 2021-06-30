"*****************************************************************************
" Vim-Plug core
"*****************************************************************************

call plug#begin(expand('~/.config/nvim/plugged'))

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'
Plug 'Yggdroot/indentLine'
" Plug 'windwp/nvim-autopairs'
" Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'windwp/nvim-ts-autotag'
Plug 'p00f/nvim-ts-rainbow'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-project.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-surround'
Plug 'tveskag/nvim-blame-line'
Plug 'ThePrimeagen/vim-be-good'
Plug 'jiangmiao/auto-pairs'

call plug#end()

""" Extra script for setup plugin, written in lua script
lua << EOF
local previewers = require('telescope.previewers')
local _bad = { 'metadata/.*%.json' } -- Put all filetypes that slow you down in this array
local bad_files = function(filepath)
  for _, v in ipairs(_bad) do
    if filepath:match(v) then
      return false
    end
  end
  return true
end

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}
  if opts.use_ft_detect == nil then opts.use_ft_detect = true end
  opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
  previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--hidden',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    file_ignore_patterns = {
      ".git/",
    },
    buffer_previewer_maker = new_maker,
  },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      mappings = {
        i = {
          ["<c-d>"] = "delete_buffer",
        },
        n = {
          ["<c-d>"] = "delete_buffer",
        }
      }
    }
  },
}

require'telescope'.load_extension('project')

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
  },
}

-- require('nvim-autopairs').setup()
-- require'lspconfig'.tsserver.setup{}
EOF

"*****************************************************************************
" Basic Setup
"*****************************************************************************

filetype plugin indent on

set tabstop=2
set shiftwidth=2
set expandtab
set hidden
set laststatus=2
set updatetime=300
set autoread
set lazyredraw
set splitbelow
set splitright

" Prefered .swp directory
set directory^=$HOME/.vimswap//

" Encoding
let $LANG='en_US.UTF-8'
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set fileformats=unix

" Fix backspace indent
set backspace=indent,eol,start

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

syntax on
set number relativenumber
colorscheme codedark

highlight Normal      ctermbg=NONE guibg=NONE
highlight NonText     ctermbg=NONE guibg=NONE
highlight LineNr      ctermbg=NONE guibg=NONE
highlight SignColumn  ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE
highlight Folded      ctermfg=yellow

set mouse=a
set mousemodel=popup_setpos

set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

"*****************************************************************************
" Abbreviations
"*****************************************************************************

" no one is really happy until you have this shortcuts
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q

"*****************************************************************************
" Commands
"*****************************************************************************

" remove trailing whitespaces
command! FixWhitespace :%s/\s\+$//e

"*****************************************************************************
" Autocmd Rules
"*****************************************************************************

" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=200
augroup END

" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

autocmd FileType scss setl iskeyword+=@-@

"*****************************************************************************
" Mappings
"*****************************************************************************

" Map leader to <comma>
let mapleader=','

" Basic mappings
nnoremap j gjzz
nnoremap k gkzz
xnoremap j gjzz
xnoremap k gkzz
nmap <C-j> 5j
nmap <C-k> 5k
xmap <C-j> 5j
xmap <C-k> 5k

nnoremap # #zz
nnoremap * *zz
nnoremap n nzz
nnoremap N Nzz
nnoremap G Gzz

nnoremap { {zz
nnoremap } }zz
xnoremap { {zz
xnoremap } }zz

" Map redo to U (undo is u)
nnoremap U <C-R>

" Quick switch buffer
nnoremap <silent><leader><tab> :bn<CR>
nnoremap <silent><leader><S-tab> :bp<CR>

" Yank to Vim + OS clipboard
nnoremap y "*y
xnoremap y "*y

" Fast save / quit
nmap <leader>w :w!<cr>
nmap <leader>qq :bd!<cr>

" Visual mode: shifting > and <, move line up and down
vnoremap < <gv
vnoremap > >gv
vnoremap J :m '>+1<CR>gv=gvzz
vnoremap K :m '<-2<CR>gv=gvzz

" Split resize current pane
nnoremap zh         <C-w>h
nnoremap zl         <C-w>l
nnoremap zj         5<C-w><
nnoremap zk         5<C-w>>
nnoremap zb         <C-w>=
nnoremap <silent>zn :vs<CR>
nnoremap zm         <C-w>q

nnoremap <silent><leader>- 5<C-w><
nnoremap <silent><leader>+ 5<C-w>>
nnoremap <silent><leader>. <C-w>=

" Expand emmet abbr
imap j<Tab> <C-Y>,

" Fold / unfold code
vnoremap zf zfzz
vnoremap zo zozz

" Go to normal mode if k is preceded by j.
inoremap <expr>k EscapeInsertOrNot()
function! EscapeInsertOrNot() abort
  if col('.') <= 1
    return ''
  endif

  let pre_cursor = getline('.')[:col('.')-2]
  let pre_char = strcharpart(pre_cursor, strchars(pre_cursor)-1)
  if pre_char ==# 'j'
    return "\b\e"
  else
    return 'k'
  endif
endfunction

" Telescope
nnoremap <silent><leader>ff <cmd>lua require('telescope.builtin').find_files({hidden = true})<cr>
nnoremap <silent><leader>fg <cmd>Telescope live_grep prompt_prefix=<cr>
nnoremap <silent><leader>fp <cmd>lua require('telescope').extensions.project.project{ display_type = 'full' }<cr>
nnoremap <silent><leader>fx <cmd>lua require('telescope.builtin').file_browser({cwd = vim.fn.expand('%:p:h'), hidden = true})<cr>
nnoremap <silent><leader>fb <cmd>Telescope buffers sort_lastused=true default_selection_index=2<cr>
nnoremap <silent><leader>fa <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <silent><leader>fh <cmd>Telescope help_tags<cr>

" GoTo code navigation.
nmap <silent><F12> <Plug>(coc-definition)
nmap <silent>gi <Plug>(coc-implementation)
nmap <silent>gr <Plug>(coc-references)
nmap <silent><space>e <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
xmap <silent><space>f <Plug>(coc-format-selected)
nmap <silent><space>f <Plug>(coc-format-selected)
nmap <silent>K :call <SID>show_documentation()<CR>
nmap <leader>o :call CocAction('runCommand', 'tsserver.organizeImports')<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Miscellaneous
nnoremap <silent><leader>\ :w \| :source % \| :PlugInstall<CR>
nnoremap <silent><leader>= :e! ~/.config/nvim/init.vim<CR>
nnoremap <silent><leader>n :e! ~/buff<CR>
nnoremap <silent><leader><cr> :noh<cr>

" Git blame
nnoremap <silent><leader>b :ToggleBlameLine<CR>

" nmap <silent><F12> <cmd>lua vim.lsp.buf.definition()<CR>
" nmap <silent>gi <cmd>lua vim.lsp.buf.implementation()<CR>
" nmap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
" nmap <silent><space>e <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
" nmap <silent>[g <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
" nmap <silent>]g <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
" nmap <silent><space>f <cmd>lua vim.lsp.buf.formatting()<CR>
" nmap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>

"*****************************************************************************
" Custom configs
"*****************************************************************************

" indentLine
let g:indentLine_char = '┆'
let g:indentLine_faster = 1

" coc.nvim
let g:coc_global_extensions = ['coc-stylelintplus', 'coc-eslint', 'coc-json', 'coc-tsserver']

" vim-startify
let g:startify_change_to_dir=0

" Include user's local vim config
if filereadable(expand("~/.config/nvim/local_init.vim"))
  source ~/.config/nvim/local_init.vim
endif
