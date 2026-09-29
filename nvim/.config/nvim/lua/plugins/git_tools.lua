local M = {}

M.setup_gitsigns = function()
  require('gitsigns').setup {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map('n', ']h', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.nav_hunk 'next'
        end)
        return '<Ignore>'
      end, 'Git next hunk')

      map('n', '[h', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.nav_hunk 'prev'
        end)
        return '<Ignore>'
      end, 'Git prev hunk')

      map({ 'n', 'v' }, '<leader>hp', gs.preview_hunk, 'Git preview hunk')
      map('n', '<leader>hs', gs.stage_hunk, 'Git stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Git reset hunk')
      map('n', '<leader>hS', gs.stage_buffer, 'Git stage buffer')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Git undo stage hunk')
      map('n', '<leader>hR', gs.reset_buffer, 'Git reset buffer')
    end,
  }
end

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
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      M.setup_gitsigns()
    end,
  },
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
