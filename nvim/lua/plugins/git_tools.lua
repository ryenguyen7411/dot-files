local M = {}

M.setup_diffview = function()
  return {
    'sindrets/diffview.nvim',
    keys = {
      { '<space>r', '<cmd>DiffviewOpen<CR>', desc = 'DiffviewOpen' },
      { '<space>f', '<cmd>DiffviewFileHistory %<CR>', desc = 'DiffviewFileHistory' },
    },
    cmd = { 'DiffviewOpen' },
    config = function()
      require('diffview').setup(M.config_diffview())
      M.mapping()
    end,
  }
end

M.config_diffview = function()
  local actions = require 'diffview.actions'

  return {
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
end

M.mapping = function()
  -- vim.keymap.set('n', '<leader>r', '<cmd>DiffviewOpen<CR>', { silent = true })
  vim.keymap.set('n', '<leader>f', '<cmd>DiffviewFileHistory %<CR>', { silent = true })
end

return {
  M.setup_diffview(),
  {
    'f-person/git-blame.nvim',
    keys = {
      { '<space>,b', '<cmd>GitBlameToggle<CR>', desc = 'GitBlameToggle' },
    },
    opts = {},
  },
}
