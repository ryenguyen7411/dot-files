local M = {}

M.setup = function()
  local cb = require('diffview.config').diffview_callback
  require('diffview').setup{
    use_icons = false,
    file_panel = {
      ['<cr>']          = cb('focus_entry'),
      ['o']             = cb('focus_entry'),
      ['<2-LeftMouse>'] = cb('focus_entry'),
    },
    file_history_panel = {
      ['<cr>']          = cb('focus_entry'),
      ['o']             = cb('focus_entry'),
      ['<2-LeftMouse>'] = cb('focus_entry'),
    },
  }
end

return M
