local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.keymap.set('i', '<C-j>', '<Plug>(emmet-expand-abbr)', { noremap = false })
end

return M
