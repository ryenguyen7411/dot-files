local g = vim.g

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', '<leader>,b', ':GitBlameToggle<CR>', { silent = true })
end

return M
