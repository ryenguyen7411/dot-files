local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>,c', ':CocConfig<CR>')
  -- v.nmap({'silent'}, '<F12>', '<Plug>(coc-definition)')
  v.nmap({'silent'}, 'gi', '<Plug>(coc-definition)')
  v.nmap({'silent'}, 'gn', '<Plug>(coc-diagnostic-prev)<CR>zz')
  v.nmap({'silent'}, 'gm', '<Plug>(coc-diagnostic-next)<CR>zz')
  v.nmap({'silent'}, '<leader>o', ':call CocAction("runCommand", "tsserver.organizeImports")<CR>')
  v.vmap({'silent'}, 'gf', '<Plug>(coc-format-selected)')
  -- v.nmap('<leader>ck', show_documentation())
  -- v.nmap('<space>f', '<Plug>(coc-format-selected)')
  -- v.nmap('gi', '<Plug>(coc-implementation)')
  -- v.nmap('gr', '<Plug>(coc-references)')
  -- v.nmap('<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')

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
end

return M
