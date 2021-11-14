local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  v.imap({'silent'}, ',g', '<Plug>(emmet-expand-abbr)')
end

return M
