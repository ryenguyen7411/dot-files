local cmd = vim.cmd
local g = vim.g

local vimp = require('vimp')
local nmap = vimp.nmap
local nnoremap = vimp.nnoremap
local xmap = vimp.xmap
local xnoremap = vimp.xnoremap
local vmap = vimp.vmap
local vnoremap = vimp.vnoremap
local imap = vimp.imap

g.mapleader = ' '

-- Center navigation
nmap('j', 'gjzz')
nmap('k', 'gkzz')
xmap('j', 'gjzz')
xmap('k', 'gkzz')
nmap('<C-j>', '5j')
nmap('<C-k>', '5k')
xmap('<C-j>', '5j')
xmap('<C-k>', '5k')

nmap('#', '#zz')
nmap('*', '*zz')
nmap('n', 'nzz')
nmap('N', 'Nzz')
nmap('G', 'Gzz')

nmap('{', '{zz')
nmap('}', '}zz')
xmap('{', '{zz')
xmap('}', '}zz')

-- Map redo to U (undo is u)
nmap('U', '<C-R>')

-- Yank to Vim + OS clipboard
nnoremap('y', '"*y')
xnoremap('y', '"*y')
nnoremap({'silent'}, 'Y', ':%y+<CR>')

-- Fast save / quit
nmap({'silent'}, '<leader>w', ':w!<CR>')
nmap({'silent'}, '<leader>qq', ':bp|bd #<CR>')
nnoremap({'silent'}, '<leader><BS>', ':%bdelete!<CR>')

-- Visual mode: shifting > and <, move line up and down
vmap('<', '<gv')
vmap('>', '>gv')
vmap('J', ':m \'>+1<CR>gv=gvzz')
vmap('K', ':m \'<-2<CR>gv=gvzz')

-- Split resize current pane
nmap('zh', '<C-w>h')
nmap('zl', '<C-w>l')
nmap('zj', '<Space>5<C-w><')
nmap('zk', '<Space>5<C-w>>')
nmap('zb', '<C-w>=')
nmap({'silent'}, 'zn', ':vs<CR><Space>,;')
nmap('zm', '<C-w>q')

-- Fold / unfold code
vmap('zf', 'zfzz')
vmap('zo', 'zozz')

-- Switch buffer with Tab
nmap({'silent'}, '<Tab>', ':bnext<CR>')
nmap({'silent'}, '<S-Tab>', ':bprevious<CR>')

-- -- Go to normal mode if k is preceded by j.
-- imap('<expr>k' EscapeInsertOrNot())
-- function EscapeInsertOrNot() {}
--   if col('.') <= 1
--     return ''
--   end

--   let pre_cursor = getline('.')[:col('.')-2]
--   let pre_char = strcharpart(pre_cursor, strchars(pre_cursor)-1)
--   if pre_char ==# 'j'
--     return "\b\e"
--   else
--     return 'k'
--   end
-- end

-- Plugin: emmet-vim
imap({'silent'}, ',g', '<Plug>(emmet-expand-abbr)')

-- Plugin: vim-startify
nmap({'silent'}, '<F6>', ':Startify<CR>')

-- Plugin: coc.nvim
nmap({'silent'}, '<leader>,c', ':CocConfig<CR>')
-- nmap({'silent'}, '<F12>', '<Plug>(coc-definition)')
nmap({'silent'}, 'gi', '<Plug>(coc-definition)')
nmap({'silent'}, '<leader>,n', '<Plug>(coc-diagnostic-prev)<CR>zz')
nmap({'silent'}, '<leader>,m', '<Plug>(coc-diagnostic-next)<CR>zz')
nmap({'silent'}, '<leader>,o', ':call CocAction("runCommand", "tsserver.organizeImports")<CR>')
-- nmap('<leader>ck', show_documentation())
-- nmap('<space>f', '<Plug>(coc-format-selected)')
-- nmap('gi', '<Plug>(coc-implementation)')
-- nmap('gr', '<Plug>(coc-references)')
-- nmap('<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')

-- function show_documentation()
--   local filetype = vim.bo.filetype
--   if filetype == "vim" or filetype == "help" then
--     vim.api.nvim_command("h " .. vim.fn.expand("<cword>"))
--   elseif vim.fn["coc#rpc#ready"]() then
--     vim.fn.CocActionAsync("doHover")
--   else
--     vim.api.nvim_command(
--       "!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>")
--     )
--   end
-- end

-- Plugin: telescope.nvim
nmap({'silent'}, '<leader>,;', '<cmd>lua require("telescope.builtin").find_files({ hidden=true })<cr>')
nmap({'silent'}, '<leader>,j', '<cmd>lua require("telescope.builtin").live_grep()<cr>')
nmap({'silent'}, '<leader>,l', '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<cr>')
nmap({'silent'}, '<leader>,k', '<cmd>lua require("telescope.builtin").file_browser({ cwd = vim.fn.expand("%:p:h"), hidden=true })<cr>')
nmap({'silent'}, '<leader>,b', '<cmd>lua require("telescope.builtin").buffers({ sort_lastused=true, default_selection_index=2 })<cr>')
nmap({'silent'}, '<leader>,h', '<cmd>lua require("telescope.builtin").help_tags()<cr>')

-- Git blame
nmap({'silent'}, '<leader>b', ':ToggleBlameLine<CR>')

-- Diffview
nmap({'silent'}, '<leader>,r', ':DiffviewOpen<CR>')
nmap({'silent'}, '<leader>,f', ':DiffviewFileHistory<CR>')

-- Plugin: any-jump
nmap({'silent'}, '<F12>', ':AnyJump<CR>')
nmap({'silent'}, '<F8>', ':AnyJumpLastResults<CR>')

-- Plugin: nvim-spectre
-- open plugin -> set smaller pane -> switch pane side
nnoremap({'silent'}, '<leader>,i', ':lua require("spectre").open()<CR><Space>60<C-w><<CR><C-w>r')
vnoremap({'silent'}, '<leader>,i', ':lua require("spectre").open_visual()<CR><CR><Space>60<C-w><<CR><C-w>r')

-- Miscellaneous
nmap({'silent'}, '<leader>\\', ':w|:source %|:PackerInstall<CR>')
nmap({'silent'}, '<leader>=', ':e! ~/.config/nvim/init.lua<CR>')
nmap({'silent'}, '<leader>n', ':enew<CR>')
nmap({'silent'}, '<leader><cr>', ':nohl<CR><C-L>')

-- Vim profiling
nmap({'silent'}, '<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>')
nmap({'silent'}, '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>')

