local v = require('vimp')

local cmd = vim.cmd
local g = vim.g

g.mapleader = ' '

-- Center navigation
v.nmap('j', 'gjzz')
v.nmap('k', 'gkzz')
v.xmap('j', 'gjzz')
v.xmap('k', 'gkzz')
v.nmap('<C-j>', '5j')
v.nmap('<C-k>', '5k')
v.xmap('<C-j>', '5j')
v.xmap('<C-k>', '5k')

v.nmap('#', '#zz')
v.nmap('*', '*zz')
v.nmap('n', 'nzz')
v.nmap('N', 'Nzz')
v.nmap('G', 'Gzz')

v.nmap('{', '{zz')
v.nmap('}', '}zz')
v.xmap('{', '{zz')
v.xmap('}', '}zz')

-- Map redo to U (undo is u)
v.nmap('U', '<C-R>')

-- Yank to Vim + OS clipboard
v.nnoremap({'silent'}, 'YY', ':%y+<CR>')
v.nnoremap('y', '"*y')
v.xnoremap('y', '"*y')
v.nnoremap('d', '"*d')
v.xnoremap('d', '"*d')
v.nnoremap('x', '"*x')
v.xnoremap('x', '"*x')

-- Fast save / quit
v.nmap({'silent'}, '<leader>w', ':w!<CR>')
v.nmap({'silent'}, '<leader>qq', ':bp|bd #<CR>')
v.nnoremap({'silent'}, '<leader><BS>', ':%bdelete!<CR>')

-- Keep the cursor in place while joining lines
v.nnoremap('J', 'mzJ`z')

-- Visual mode: shifting > and <, move line up and down
v.vmap('<', '<gv')
v.vmap('>', '>gv')
v.vmap('J', ':m \'>+1<CR>gv=gvzz')
v.vmap('K', ':m \'<-2<CR>gv=gvzz')

-- Split resize current pane
v.nmap('zh', '<C-w>h')
v.nmap('zl', '<C-w>l')
v.nmap('zj', '<Space>5<C-w><')
v.nmap('zk', '<Space>5<C-w>>')
v.nmap('zb', '<C-w>=')
v.nmap({'silent'}, 'zn', ':vs<CR><Space>,;')
v.nmap('zm', '<C-w>q')

-- Fold / unfold code
v.vmap('zf', 'zfzz')
v.vmap('zo', 'zozz')

-- Switch buffer with Tab
v.nmap({'silent'}, '<Tab>', ':bnext<CR>')
v.nmap({'silent'}, '<S-Tab>', ':bprevious<CR>')

-- Miscellaneous
v.nmap({'silent'}, '<leader>\\', ':w|:source %|:PackerInstall<CR>')
v.nmap({'silent'}, '<leader>=', ':e! ~/.config/nvim/init.lua<CR>')
v.nmap({'silent'}, '<leader>n', ':enew<CR>')
v.nmap({'silent'}, '<leader><cr>', ':nohl<CR><C-L>')

-- Vim profiling
v.nmap({'silent'}, '<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>')
v.nmap({'silent'}, '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>')
