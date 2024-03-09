local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.api.nvim_set_keymap('i', '<C-j>', '<Plug>(emmet-expand-abbr)', { noremap = false })
end

return M
