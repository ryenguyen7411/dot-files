local g = vim.g

g.mapleader = ' '

-- Center navigation
vim.api.nvim_set_keymap('n', 'j', 'gj', { silent = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { silent = true })
vim.api.nvim_set_keymap('x', 'j', 'gj', { silent = true })
vim.api.nvim_set_keymap('x', 'k', 'gk', { silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '5j', { silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '5k', { silent = true })
vim.api.nvim_set_keymap('x', '<C-j>', '5j', { silent = true })
vim.api.nvim_set_keymap('x', '<C-k>', '5k', { silent = true })

vim.api.nvim_set_keymap('n', '#', '#zz', { silent = true })
vim.api.nvim_set_keymap('n', '*', '*zz', { silent = true })
vim.api.nvim_set_keymap('n', 'n', 'nzz', { silent = true })
vim.api.nvim_set_keymap('n', 'N', 'Nzz', { silent = true })
vim.api.nvim_set_keymap('n', 'G', 'Gzz', { silent = true })

-- Exclude trailing whitespace + end of line
vim.api.nvim_set_keymap('n', '$', 'g_', { silent = true })
vim.api.nvim_set_keymap('x', '$', 'g_', { silent = true })

vim.api.nvim_set_keymap('n', '{', '{zz', { silent = true })
vim.api.nvim_set_keymap('n', '}', '}zz', { silent = true })
vim.api.nvim_set_keymap('x', '{', '{zz', { silent = true })
vim.api.nvim_set_keymap('x', '}', '}zz', { silent = true })

-- Map redo to U (undo is u)
vim.api.nvim_set_keymap('n', 'U', '<C-R>', { silent = true })

-- Yank to Vim + OS clipboard
vim.api.nvim_set_keymap('n', 'YY', 'gg"*yG', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', 'y', '"*y', { silent = true, noremap = true })
vim.api.nvim_set_keymap('x', 'y', '"*y', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', 'd', '"*d', { silent = true, noremap = true })
vim.api.nvim_set_keymap('x', 'd', '"*d', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', 'x', '"*x', { silent = true, noremap = true })
vim.api.nvim_set_keymap('x', 'x', '"*x', { silent = true, noremap = true })
vim.api.nvim_set_keymap('x', 'p', '"_dP', { silent = true, noremap = true })

-- Fast save / quit
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>qq', ':bp|bd #<CR>', { silent = true })
vim.api.nvim_set_keymap('i', ':w', '<Esc>:w|<CR>jk', { silent = true })

-- Keep the cursor in place while joining lines
-- vim.api.nvim_set_keymap('n', 'J', 'mzJ`z', { silent = true })

-- Visual mode: shifting > and <, move line up and down
vim.api.nvim_set_keymap('v', '<', '<gv', { silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { silent = true })
vim.api.nvim_set_keymap('v', 'J', ':m \'>+1<CR><CR>gv', { silent = true })
vim.api.nvim_set_keymap('v', 'K', ':m \'<-2<CR><CR>gv', { silent = true })

-- Split resize current pane
vim.api.nvim_set_keymap('n', 'zh', '<C-w>h', { silent = true })
vim.api.nvim_set_keymap('n', 'zl', '<C-w>l', { silent = true })
vim.api.nvim_set_keymap('n', 'zj', '<C-w>j', { silent = true })
vim.api.nvim_set_keymap('n', 'zk', '<C-w>k', { silent = true })
vim.api.nvim_set_keymap('n', 'z<BS>', '<Space>15<C-w><', { silent = true })
vim.api.nvim_set_keymap('n', 'z<CR>', '<Space>15<C-w>>', { silent = true })
vim.api.nvim_set_keymap('n', 'zb', '<C-w>=', { silent = true })
vim.api.nvim_set_keymap('n', 'z|', ':vsplit<CR>', { silent = true })
vim.api.nvim_set_keymap('n', 'z-', ':split<CR>', { silent = true })
vim.api.nvim_set_keymap('n', 'zm', '<C-w>q', { silent = true })

-- Fold / unfold code
vim.api.nvim_set_keymap('v', 'zf', 'zfzz', { silent = true })
vim.api.nvim_set_keymap('v', 'zo', 'zozz', { silent = true })
vim.api.nvim_set_keymap('n', 'zo', 'zozz', { silent = true })

-- Switch buffer with Tab
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { silent = true })

-- Miscellaneous
vim.api.nvim_set_keymap('n', '<leader>n', ':enew<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader><CR>', ':nohl<CR><C-l>zz', { silent = true })
vim.api.nvim_set_keymap('x', '<leader><CR>', '<C-l>zz', { silent = true })
-- vim.api.nvim_set_keymap('n', '<leader><CR>', ':TSHighlightCapturesUnderCursor<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '0\\', ':%bdelete!<CR><CR>', { silent = true })
vim.api.nvim_set_keymap('n', '00', 'ggdG:w<CR><C-w>q', { silent = true, noremap = true })

-- Vim profiling
vim.api.nvim_set_keymap('n', '<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>', { silent = true })
