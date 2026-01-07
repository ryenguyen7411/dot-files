local g = vim.g

local M = {}

M.setup_diffview = function()
  local actions = require 'diffview.actions'

  require('diffview').setup {
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
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

return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen' },
    keys = {
      { '<space>r', '<cmd>DiffviewOpen<CR>', desc = 'DiffviewOpen' },
      { '<space>f', '<cmd>DiffviewFileHistory %<CR>', desc = 'DiffviewFileHistory' },
    },
    config = function()
      M.setup_diffview()
    end,
  },
  {
    'f-person/git-blame.nvim',
    event = 'BufRead',
    keys = {
      { '<space>,b', '<cmd>GitBlameToggle<CR>', desc = 'GitBlameToggle' },
    },
    opts = {
      enabled = false,
      message_template = ' <summary> • <date> • <author> • <<sha>>',
      date_format = '%m-%d-%Y %H:%M:%S',
      virtual_text_column = 1,
    },
  },
}
