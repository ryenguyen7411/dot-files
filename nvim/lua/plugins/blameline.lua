local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>,b', ':ToggleBlameLine<CR>')
end

return M
