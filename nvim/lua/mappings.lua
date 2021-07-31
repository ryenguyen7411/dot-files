local cmd = vim.cmd
local g = vim.g
local map = vim.api.nvim_set_keymap

g.mapleader = ' '

map('n', 'j', 'gjzz', {})
map('n', 'k', 'gkzz', {})
map('x', 'j', 'gjzz', {})
map('x', 'k', 'gkzz', {})
map('n', '<C-j>', '5j', {})
map('n', '<C-k>', '5k', {})
map('x', '<C-j>', '5j', {})
map('x', '<C-k>', '5k', {})

map('n', '#', '#zz', {})
map('n', '*', '*zz', {})
map('n', 'n', 'nzz', {})
map('n', 'N', 'Nzz', {})
map('n', 'G', 'Gzz', {})

map('n', '{', '{zz', {})
map('n', '}', '}zz', {})
map('x', '{', '{zz', {})
map('x', '}', '}zz', {})

-- Map redo to U (undo is u)
map('n', 'U', '<C-R>', { noremap=true })

-- Yank to Vim + OS clipboard
map('n', 'y', '"*y', { noremap=true })
map('x', 'y', '"*y', { noremap=true })

-- Fast save / quit
map('n', '<leader>w', ':w!<CR>', { silent=true })
map('n', '<leader>qq', ':bp|bd #<CR>', { silent=true })
map('n', '<leader><BS>', ':%bdelete!<CR>', { silent=true, noremap=true })

-- Visual mode: shifting > and <, move line up and down
map('v', '<', '<gv', {})
map('v', '>', '>gv', {})
map('v', 'J', ':m \'>+1<CR>gv=gvzz', {})
map('v', 'K', ':m \'<-2<CR>gv=gvzz', {})

-- Split resize current pane
map('n', 'zh', '<C-w>h', {})
map('n', 'zl', '<C-w>l', {})
map('n', 'zj', ' 5<C-w><', {})
map('n', 'zk', ' 5<C-w>>', {})
map('n', 'zb', '<C-w>=', {})
map('n', 'zn', ':vs<CR> ,;', { silent=true })
map('n', 'zm', '<C-w>q', {})

-- Expand emmet
map('i', ',g', '<C-Y>,', { silent=true })

-- Fold / unfold code
map('v', 'zf', 'zfzz', {})
map('v', 'zo', 'zozz', {})

-- -- Go to normal mode if k is preceded by j.
-- map('i', '<expr>k' EscapeInsertOrNot(), {})
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

-- Telescope
map('n', '<leader>,;', '<cmd>lua require("telescope.builtin").find_files({ hidden=true })<cr>', { silent=true })
map('n', '<leader>,j', '<cmd>lua require("telescope.builtin").live_grep()<cr>', { silent=true })
map('n', '<leader>,l', '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<cr>', { silent=true })
map('n', '<leader>,k', '<cmd>lua require("telescope.builtin").file_browser({ cwd = vim.fn.expand("%:p:h"), hidden=true })<cr>', { silent=true })
map('n', '<leader>,b', '<cmd>lua require("telescope.builtin").buffers({ sort_lastused=true, default_selection_index=2 })<cr>', { silent=true })
map('n', '<leader>fa', '<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<cr>', { silent=true })
map('n', '<leader>fh', '<cmd>lua require("telescope.builtin").help_tags()<cr>', { silent=true })

-- GoTo code navigation.
map('n', '<F12>', '<Plug>(coc-definition)', { silent=true })
map('n', 'gi', '<Plug>(coc-implementation)', { silent=true })
map('n', 'gr', '<Plug>(coc-references)', { silent=true })
map('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { silent=true })
map('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent=true })
map('n', ']g', '<Plug>(coc-diagnostic-next)', { silent=true })
map('n', '<space>f', '<Plug>(coc-format-selected)', { silent=true })
map('x', '<space>f', '<Plug>(coc-format-selected)', { silent=true })
-- map('n', 'K', show_documentation(), { silent=true })
map('n', '<leader>o', ':call CocAction("runCommand", "tsserver.organizeImports")<CR>', { silent=true })

function show_documentation()
  local filetype = vim.bo.filetype
  if filetype == "vim" or filetype == "help" then
    vim.api.nvim_command("h " .. vim.fn.expand("<cword>"))
  elseif vim.fn["coc#rpc#ready"]() then
    vim.fn.CocActionAsync("doHover")
  else
    vim.api.nvim_command(
      "!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>")
    )
  end
end

-- Miscellaneous
map('n', '<leader>\\', ':w|:source %|:PaqInstall<CR>', { silent=true })
map('n', '<leader>=', ':e! ~/.config/nvim/init.lua<CR>', { silent=true })
map('n', '<leader>n', ':enew<CR>', { silent=true })
map('n', '<leader><cr>', ':nohl<CR><C-L>', { silent=true })

-- Git blame
map('n', '<leader>b', ':ToggleBlameLine<CR>', { silent=true })

-- Vim profiling
map('n', '<leader>vp', ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>', { silent=true })
map('n', '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>', { silent=true })
