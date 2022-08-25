local v = require('vimp')

local M = {}

M.setup = function()
  local cb = require('diffview.config').diffview_callback
  require('diffview').setup{
    use_icons = false,
    enhanced_diff_hl = true,
    key_bindings = {
      view = {
        ['<Leader>r'] = cb('focus_files'),
      },
      file_panel = {
        ['o']          = cb('focus_entry'),
        ['<Leader>r'] = '<Cmd>DiffviewClose<Cr>',
      },
      file_history_panel = {
        ['o']          = cb('focus_entry'),
        ['<Leader>r'] = '<Cmd>DiffviewClose<Cr>',
      },
    }
  }

  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>r', ':DiffviewOpen<CR>')
  v.nmap({'silent'}, '<leader>f', ':DiffviewFileHistory %<CR>')
end

return M
