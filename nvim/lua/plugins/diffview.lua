local M = {}

M.setup = function()
  local cb = require('diffview.config').diffview_callback
  local actions = require 'diffview.actions'

  require('diffview').setup {
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        layout = 'diff3_horizontal',
        disable_diagnostics = true,
      },
    },
    key_bindings = {
      view = {
        ['<leader><CR>'] = '<cmd>DiffviewRefresh<CR>',
        ['<leader>r'] = '<cmd>DiffviewFocusFiles<CR>',
      },
      file_panel = {
        ['o'] = actions.focus_entry,
        ['<leader>r'] = '<cmd>DiffviewClose<CR>',
      },
      file_history_panel = {
        ['o'] = actions.focus_entry,
        ['p'] = actions.open_in_diffview,
        ['<leader>r'] = '<cmd>DiffviewClose<CR>',
      },
    },
  }

  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', '<leader>r', '<cmd>DiffviewOpen<CR>', { silent = true })
  vim.keymap.set('n', '<leader>f', '<cmd>DiffviewFileHistory %<CR>', { silent = true })
end

return M
