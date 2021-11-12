local cmd = vim.cmd
local g = vim.g
local map = vim.api.nvim_set_keymap

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
nnoremap('Y', ':%y+<CR>')

-- Fast save / quit
nmap('<leader>w', ':w!<CR>', 'silent')
nmap('<leader>qq', ':bp|bd #<CR>', 'silent')
nnoremap('<leader><BS>', ':%bdelete!<CR>', 'silent')

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
nmap('zn', ':vs<CR><Space>,;', 'silent')
nmap('zm', '<C-w>q')

-- Fold / unfold code
vmap('zf', 'zfzz')
vmap('zo', 'zozz')

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
imap(',g', '<Plug>(emmet-expand-abbr)', 'silent')

-- Plugin: vim-startify
nmap('<F6>', ':Startify<CR>', 'silent')

-- Plugin: coc.nvim
nmap('<leader>,c', ':CocConfig<CR>', 'silent')
-- nmap('<F12>', '<Plug>(coc-definition)', 'silent')
nmap('<leader>,n', '<Plug>(coc-diagnostic-prev)<CR>zz', 'silent')
nmap('<leader>,m', '<Plug>(coc-diagnostic-next)<CR>zz', 'silent')
nmap('<leader>,o', ':call CocAction("runCommand", "tsserver.organizeImports")<CR>', 'silent')
-- nmap('<leader>ck', show_documentation(), 'silent')
-- nmap('<space>f', '<Plug>(coc-format-selected)', 'silent')
-- nmap('gi', '<Plug>(coc-implementation)', 'silent')
-- nmap('gr', '<Plug>(coc-references)', 'silent')
-- nmap('<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', 'silent')

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
nmap('<leader>,;', '<cmd>lua require("telescope.builtin").find_files({ hidden=true })<cr>', 'silent')
nmap('<leader>,j', '<cmd>lua require("telescope.builtin").live_grep()<cr>', 'silent')
nmap('<leader>,l', '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<cr>', 'silent')
nmap('<leader>,k', '<cmd>lua require("telescope.builtin").file_browser({ cwd = vim.fn.expand("%:p:h"), hidden=true })<cr>', 'silent')
nmap('<leader>,b', '<cmd>lua require("telescope.builtin").buffers({ sort_lastused=true, default_selection_index=2 })<cr>', 'silent')
nmap('<leader>,h', '<cmd>lua require("telescope.builtin").help_tags()<cr>', 'silent')

-- Git blame
nmap('<leader>b', ':ToggleBlameLine<CR>', 'silent')

-- Diffview
nmap('<leader>,d', ':DiffviewOpen<CR>', 'silent')
nmap('<leader>,s', ':DiffviewClose<CR>', 'silent')
nmap('<leader>,p', ':DiffviewToggleFiles<CR>', 'silent')
nmap('<leader>,f', ':DiffviewFileHistory<CR>', 'silent')

-- Plugin: any-jump
nmap('<F12>', ':AnyJump<CR>', 'silent')
nmap('<F8>', ':AnyJumpLastResults<CR>', 'silent')

-- Plugin: nvim-spectre
-- open plugin -> set smaller pane -> switch pane side
nnoremap('<leader>,i', ':lua require("spectre").open()<CR><Space>60<C-w><<CR><C-w>r', 'silent')
vnoremap('<leader>,i', ':lua require("spectre").open_visual()<CR><CR><Space>60<C-w><<CR><C-w>r', 'silent')

-- Miscellaneous
nmap('<leader>\\', ':w|:source %|:PaqInstall<CR>', 'silent')
nmap('<leader>=', ':e! ~/.config/nvim/init.lua<CR>', 'silent')
nmap('<leader>n', ':enew<CR>', 'silent')
nmap('<leader><cr>', ':nohl<CR><C-L>', 'silent')

-- Vim profiling
nmap('<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>', 'silent')
nmap('<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>', 'silent')

