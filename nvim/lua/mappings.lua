local v = require('vimp')

local cmd = vim.cmd
local g = vim.g

g.mapleader = ' '

-- Center navigation
v.nmap('j', 'gj')
v.nmap('k', 'gk')
v.xmap('j', 'gj')
v.xmap('k', 'gk')
v.nmap('<C-j>', '5j')
v.nmap('<C-k>', '5k')
v.xmap('<C-j>', '5j')
v.xmap('<C-k>', '5k')

v.nmap('#', '#zz')
v.nmap('*', '*zz')
v.nmap('n', 'nzz')
v.nmap('N', 'Nzz')
v.nmap('G', 'Gzz')

-- Exclude trailing whitespace + end of line
v.nmap('$', 'g_')
v.xmap('$', 'g_')

v.nmap('{', '{zz')
v.nmap('}', '}zz')
v.xmap('{', '{zz')
v.xmap('}', '}zz')

-- Map redo to U (undo is u)
v.nmap('U', '<C-R>')

-- Yank to Vim + OS clipboard
v.nnoremap({'silent'}, 'YY', 'gg"*yG')
v.nnoremap('y', '"*y')
v.xnoremap('y', '"*y')
v.nnoremap('d', '"*d')
v.xnoremap('d', '"*d')
v.nnoremap('x', '"*x')
v.xnoremap('x', '"*x')
v.xnoremap('p', '"_dP')

-- Fast save / quit
v.nmap({'silent'}, '<leader>w', ':w!<CR>')
v.nmap({'silent'}, '<leader>qq', ':bp|bd #<CR>')
v.imap({'silent'}, ':w', '<Esc>:w<CR>')

-- Keep the cursor in place while joining lines
v.nnoremap('J', 'mzJ`z')

-- Visual mode: shifting > and <, move line up and down
v.vmap('<', '<gv')
v.vmap('>', '>gv')
v.vmap('J', ':m \'>+1<CR><CR>gv')
v.vmap('K', ':m \'<-2<CR><CR>gv')

-- Split resize current pane
v.nmap('zh', '<C-w>h')
v.nmap('zl', '<C-w>l')
v.nmap('zj', '<C-w>j')
v.nmap('zk', '<C-w>k')
v.nmap('z<BS>', '<Space>15<C-w><')
v.nmap('z<CR>', '<Space>15<C-w>>')
v.nmap('zb', '<C-w>=')
v.nmap('z|', ':vsplit<CR>')
v.nmap('z-', ':split<CR>')
v.nmap('zm', '<C-w>q')

-- Fold / unfold code
v.vmap('zf', 'zfzz')
v.vmap('zo', 'zozz')

-- Switch buffer with Tab
v.nmap({'silent'}, '<Tab>', ':bnext<CR>')
v.nmap({'silent'}, '<S-Tab>', ':bprevious<CR>')

-- Miscellaneous
v.nmap({'silent'}, '<leader>n', ':enew<CR>')
v.nmap({'silent'}, '<leader><CR>', ':nohl<CR><C-l>zz')
-- v.nmap({'silent'}, '<leader><CR>', ':TSHighlightCapturesUnderCursor<CR>')
v.xmap({'silent'}, '<leader><CR>', '<C-l>zz')
v.nmap({'silent'}, '<leader><BS><CR>', ':%bdelete!<CR><CR>')
v.nnoremap({'silent'}, '<leader><BS><BS>', 'ggdG:w<CR><C-w>q')

-- Vim profiling
v.nmap({'silent'}, '<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>')
v.nmap({'silent'}, '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>')
