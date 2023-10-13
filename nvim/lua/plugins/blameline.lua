local v = require('vimp')
local g = vim.g

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>,b', ':GitBlameToggle<CR>')
end

return M
