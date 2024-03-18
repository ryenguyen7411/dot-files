local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', ',.', '<cmd>CopilotChatToggle<CR>', {})
  vim.keymap.set('n', ',,', '<cmd>CopilotChatReset<CR>', {})
end

return M
