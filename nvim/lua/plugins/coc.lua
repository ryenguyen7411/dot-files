local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>,c', ':CocConfig<CR>')
  -- v.nmap({'silent'}, '<leader>o', ':call CocAction("runCommand", "tsserver.organizeImports")<CR>')
end

return M
