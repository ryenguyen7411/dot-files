local M = {}

M.setup = function()
  require('nvim-highlight-colors').setup {
    render = 'virtual',
  }
end

M.mapping = function() end

return M
