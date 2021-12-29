local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<F12>', ':AnyJump<CR>')
  v.nmap({'silent'}, '<F8>', ':AnyJumpLastResults<CR>')
end

return M
