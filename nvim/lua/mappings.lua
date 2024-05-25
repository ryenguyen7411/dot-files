local g = vim.g

-- Center navigation
vim.keymap.set('n', '<C-d>', '10<C-d>', { silent = true })
vim.keymap.set('n', '<C-u>', '10<C-u>', { silent = true })
vim.keymap.set('n', '<C-j>', '5j', { silent = true })
vim.keymap.set('n', '<C-k>', '5k', { silent = true })
vim.keymap.set('x', '<C-j>', '5j', { silent = true })
vim.keymap.set('x', '<C-k>', '5k', { silent = true })
vim.keymap.set('n', '#', '#zz', { silent = true })
vim.keymap.set('n', '*', '*zz', { silent = true })
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })
vim.keymap.set('n', 'G', 'Gzz', { silent = true })

-- Exclude trailing whitespace + end of line
vim.keymap.set('n', '$', 'g_', { silent = true })
vim.keymap.set('x', '$', 'g_', { silent = true })

vim.keymap.set('n', '{', '{zz', { silent = true })
vim.keymap.set('n', '}', '}zz', { silent = true })
vim.keymap.set('x', '{', '{zz', { silent = true })
vim.keymap.set('x', '}', '}zz', { silent = true })

-- Map redo to U (undo is u)
vim.keymap.set('n', 'U', '<C-R>', { silent = true })

-- Yank to Vim + OS clipboard
vim.keymap.set('n', 'YY', 'gg"*yG', { silent = true, noremap = true })
vim.keymap.set('n', 'y', '"*y', { silent = true, noremap = true })
vim.keymap.set('x', 'y', '"*y', { silent = true, noremap = true })
vim.keymap.set('n', 'd', '"*d', { silent = true, noremap = true })
vim.keymap.set('x', 'd', '"*d', { silent = true, noremap = true })
vim.keymap.set('n', 'x', '"*x', { silent = true, noremap = true })
vim.keymap.set('x', 'x', '"*x', { silent = true, noremap = true })
vim.keymap.set('x', 'p', '"_dP', { silent = true, noremap = true })

-- Fast save / quit
vim.keymap.set('n', '<leader>w', ':w!<CR>', { silent = true })
vim.keymap.set('n', '<leader>ư', ':w!<CR>', { silent = true })
vim.keymap.set('n', '<leader>qq', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('i', ':w', '<Esc>:w<CR>', { silent = true })

-- Visual mode: shifting > and <, move line up and down
vim.keymap.set('v', '<', '<gv', { silent = true })
vim.keymap.set('v', '>', '>gv', { silent = true })
vim.keymap.set('v', 'J', ":m '>+1<CR><CR>gv=gv", { silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR><CR>gv=gv", { silent = true })

-- Split resize current pane
vim.keymap.set('n', 'zh', '<C-w>h', { silent = true })
vim.keymap.set('n', 'zl', '<C-w>l', { silent = true })
vim.keymap.set('n', 'zj', '<C-w>j', { silent = true })
vim.keymap.set('n', 'zk', '<C-w>k', { silent = true })
vim.keymap.set('n', 'z<BS>', '<Space>15<C-w><', { silent = true })
vim.keymap.set('n', 'z<CR>', '<Space>15<C-w>>', { silent = true })
vim.keymap.set('n', 'zb', '<C-w>=', { silent = true })
vim.keymap.set('n', 'z|', ':vsplit<CR>', { silent = true })
vim.keymap.set('n', 'z-', ':split<CR>', { silent = true })
vim.keymap.set('n', 'zm', '<C-w>q', { silent = true })

-- Fold / unfold code
vim.keymap.set('v', 'zf', 'zfzz', { silent = true })
vim.keymap.set('v', 'zo', 'zozz', { silent = true })
vim.keymap.set('n', 'zo', 'zozz', { silent = true })

-- Switch buffer with Tab
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { silent = true })

-- Miscellaneous
vim.keymap.set('n', '<leader>n', ':enew<CR>', { silent = true })
vim.keymap.set('n', '<leader><CR>', ':nohl<CR><C-l>zz', { silent = true })
vim.keymap.set('x', '<leader><CR>', '<C-l>zz', { silent = true })
vim.keymap.set('n', 'gT', ':Inspect<CR>', { silent = true })
vim.keymap.set('n', '0\\', ':%bdelete!<CR><CR>', { silent = true })
vim.keymap.set('n', '00', 'ggdG:w<CR><C-w>q', { silent = true, noremap = true })

-- Vim profiling
vim.keymap.set(
  'n',
  '<leader>vp',
  ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>',
  { silent = true }
)
vim.keymap.set('n', '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>', { silent = true })
