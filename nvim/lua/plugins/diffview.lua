local M = {}

M.setup = function()
  local cb = require('diffview.config').diffview_callback
  local actions = require("diffview.actions")

  require('diffview').setup{
    use_icons = false,
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        layout = "diff3_horizontal",
        disable_diagnostics = true,
      },
    },
    key_bindings = {
      view = {
        ['<Leader>r'] = actions.focus_files,
      },
      file_panel = {
        ['o']         = actions.focus_entry,
        ['<Leader>r'] = '<Cmd>DiffviewClose<CR>',
      },
      file_history_panel = {
        ['o']         = actions.focus_entry,
        ['p']         = actions.open_in_diffview,
        ['<Leader>r'] = '<Cmd>DiffviewClose<CR>',
      },
    }
  }

  M.mapping()
end

M.mapping = function()
  vim.api.nvim_set_keymap('n', '<leader>r', ':DiffviewOpen<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', '<leader>f', ':DiffviewFileHistory %<CR>', { silent = true })
end

return M
