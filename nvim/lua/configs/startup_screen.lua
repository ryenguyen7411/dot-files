local M = {}

M.mapping = function()
  vim.keymap.set('n', '<F6>', ':Startify<CR>', { silent = true })
end

return {
  'mhinz/' .. 'vim-startify',
  config = function()
    M.mapping()
  end,
}
