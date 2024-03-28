local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', '<F6>', ':Startify<CR>', { silent = true })
end

return M
