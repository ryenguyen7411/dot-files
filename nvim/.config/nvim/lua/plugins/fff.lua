local picker_presets = require 'lib.picker_presets'

return {
  {
    'dmtrKovalenko/fff',
    lazy = false,
    build = function()
      require('fff.download').download_or_build_binary()
    end,
    cmd = { 'FFFScan', 'FFFHealth', 'FFFSnacks' },
    opts = {
      lazy_sync = true,
      db_path = vim.fn.stdpath 'cache' .. '/fff_nvim',
    },
  },
  {
    'madmaxieee/fff-snacks.nvim',
    dependencies = {
      'dmtrKovalenko/fff',
      { 'ryenguyen7411/snacks.nvim', branch = 'develop' },
    },
    ---@type fff_snacks.Config
    opts = {
      find_files = picker_presets.fff_files(),
      live_grep = picker_presets.fff_grep(),
      grep_word = picker_presets.fff_grep(),
    },
    keys = {
      {
        '<leader>fF',
        function()
          require('fff-snacks').grep_word()
        end,
        mode = { 'n', 'x' },
        desc = 'FFF grep word/selection (Snacks UI)',
      },
    },
  },
}
