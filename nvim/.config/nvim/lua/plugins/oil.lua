return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    skip_confirm_for_simple_edits = true,
    delete_to_trash = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      max_width = 0.6,
      max_height = 0.6,
      get_win_title = function()
        return 'Oil'
      end,
    },
  },
  keys = {
    { '<leader>o', '<cmd>lua require("oil").open_float()<CR>', desc = 'Oil' },
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
