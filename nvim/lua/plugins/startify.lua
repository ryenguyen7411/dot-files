local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.api.nvim_set_keymap('n', '<F6>', ':Startify<CR>', { silent = true })
end

return M
