local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', '<F12>', ':AnyJump<CR>', { silent = true })
  vim.keymap.set('n', '<F8>', ':AnyJumpLastResults<CR>', { silent = true })
end

return M
