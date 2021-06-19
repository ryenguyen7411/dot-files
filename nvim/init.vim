"*****************************************************************************
" Vim-Plug core
"*****************************************************************************

call plug#begin(expand('~/.config/nvim/plugged'))

Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'
Plug 'Yggdroot/indentLine'
" Plug 'scrooloose/nerdtree'
" Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'nvim-treesitter/playground'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'alvan/vim-closetag'
Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-surround'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-project.nvim'

call plug#end()

lua << EOF

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
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
}

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

"*****************************************************************************
" Visual Settings
"*****************************************************************************

syntax on
set number relativenumber
colorscheme codedark

highlight Normal     ctermbg=NONE guibg=NONE
highlight LineNr     ctermbg=NONE guibg=NONE
highlight SignColumn ctermbg=NONE guibg=NONE

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

" Map leader to <slash>
let mapleader=','

" Basic mappings
nnoremap U <C-R>
nnoremap j jzz
nnoremap k kzz
nnoremap # #zz
nnoremap * *zz
nnoremap n nzz
nnoremap N Nzz
nnoremap G Gzz

inoremap <expr>k EscapeInsertOrNot()

function! EscapeInsertOrNot() abort
  " If k is preceded by j, then remove j and go to normal mode.
  let line = getline('.')
  let cur_idx = CursorIdx()
  let pre_char = CharAtIdx(line, cur_idx-1)

  if pre_char ==# 'j'
    return "\b\e"
  else
    return 'k'
  endif
endfunction

function! CharAtIdx(str, idx) abort
  return strcharpart(a:str, a:idx, 1)
endfunction

function! CursorIdx() abort
  let cursor_byte_idx = col('.')
  if cursor_byte_idx == 1
    return 0
  endif

  let pre_cursor_text = getline('.')[:col('.')-2]
  return strchars(pre_cursor_text)
endfunction

""""""""""""

nmap <silent><leader><cr> :noh<cr>

" Yank to Vim + OS clipboard
nnoremap y "*y
xnoremap y "*y

" Telescope
nnoremap <silent><leader>f /
nnoremap <silent><leader>fp <cmd>lua require('telescope').extensions.project.project{}<cr>
nnoremap <silent><leader>ff <cmd>Telescope find_files<cr>
nnoremap <silent><leader>fg <cmd>Telescope live_grep<cr>
nnoremap <silent><leader>fb <cmd>Telescope buffers sort_lastused=true default_selection_index=2<cr>
nnoremap <silent><leader>fx <cmd>lua require('telescope.builtin').file_browser({cwd = vim.fn.expand('%:p:h'), hidden = true})<cr>

nnoremap <silent><leader>fa <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <silent><leader>fh <cmd>Telescope help_tags<cr>

" Fast save
nmap <leader>w :w!<cr>
nmap <leader>qq :bd!<cr>

" Visual Mode: Shifting > and <, move line up and down
vnoremap < <gv
vnoremap > >gv
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" nnoremap <silent><F2> :NERDTreeFind<CR>
" nnoremap <silent><F3> :NERDTreeToggle<CR>

" Do emmet
imap j<Tab> <C-Y>,

" Miscellaneous
nnoremap <silent><leader>\ :w \| :source % \| :PlugInstall<CR>
nnoremap <silent><leader>= :e! ~/.config/nvim/init.vim<CR>
nnoremap <silent><leader>n :e! ~/buff<CR>

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

" Autoclose Tags
let g:closetag_filenames = '*.html,*.xhtml,*.js,*.jsx'
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'
let g:closetag_emptyTags_caseSensitive = 1

" IndentLine
let g:indentLine_char = '┆'
let g:indentLine_faster = 1

" COC
let g:coc_global_extensions = ['coc-stylelintplus', 'coc-eslint', 'coc-json', 'coc-tsserver']

"" NerdTree
" let NERDTreeShowHidden=1

" Startify
let g:startify_change_to_dir=0

" Vim Airline
let g:airline_theme = 'codedark'

" Include user's local vim config
if filereadable(expand("~/.config/nvim/local_init.vim"))
  source ~/.config/nvim/local_init.vim
endif
