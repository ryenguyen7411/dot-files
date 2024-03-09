local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.api.nvim_set_keymap('n', '<F12>', ':AnyJump<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', '<F8>', ':AnyJumpLastResults<CR>', { silent = true })
end

return M
