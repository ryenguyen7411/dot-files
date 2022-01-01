local v = require('vimp')

local M = {}

M.setup = function()
  require("indent_blankline").setup {
    show_current_context = true,
  }
end

return M

