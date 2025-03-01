local M = {}

M.mapping = function()
  vim.keymap.set('n', '<F6>', ':Startify<CR>', { silent = true })
end

return {
  'mhinz/' .. 'vim-startify',
  config = function()
    M.mapping()
    -- Plugin: vim-startify
    g.startify_change_to_dir = 0
  end,
}
