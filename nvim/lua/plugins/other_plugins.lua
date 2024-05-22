return {
  { 'nvim-lua/' .. 'plenary.nvim', priority = 1000, lazy = false },
  { 'nvim-lua/' .. 'popup.nvim', priority = 1000, lazy = false },

  -- TO BE UPDATED
  {
    'ryenguyen7411/' .. 'any-jump.vim',
    keys = {
      { '<F12>', '<cmd>AnyJump<CR>', desc = 'AnyJump' },
      { '<F8>', '<cmd>AnyJumpLastResults<CR>', desc = 'AnyJumpLastResults' },
    },
  },

  {
    'mattn/' .. 'emmet-vim',
    event = 'BufRead',
    config = function()
      require('configs.emmet').setup()
    end,
  },

  { 'tpope/' .. 'vim-commentary', event = 'BufRead' },
  {
    'thinca/' .. 'vim-quickrun',
    event = 'BufRead',
    config = function()
      require('configs.quickrun').setup()
    end,
  },
  { 'tpope/' .. 'vim-repeat', event = 'BufRead' },
  { 'tpope/' .. 'vim-surround', event = 'BufRead' },
  {
    'will133/' .. 'vim-dirdiff',
    keys = {
      { '<space>,d', '<cmd>DirDiff<CR>', desc = 'DirDiff' },
    },
    cmd = { 'DirDiff' },
  },
  { 'justinmk/' .. 'vim-sneak', event = 'BufRead' },
  {
    'LunarVim/' .. 'bigfile.nvim',
    event = 'BufRead',
    opts = {},
  },
  {
    'folke/' .. 'todo-comments.nvim',
    event = 'BufRead',
    keys = {
      { '<space>a', '<cmd>TodoTelescope<CR>', desc = 'TodoTelescope' },
    },
    opts = {
      keywords = {
        EPIC = { signs = false },
        TASK = { signs = false, color = 'info' },
        DONE = { signs = false, color = 'hint' },
        HIGH = { signs = false, color = 'warning' },
        VITAL = { signs = false, color = 'error' },
        --
        TODO = { icon = ' ', color = 'info' },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    },
  },
  {
    'stevearc/' .. 'conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    config = function()
      require('configs.formatter').setup()
    end,
  },
  {
    'm4xshen/' .. 'hardtime.nvim',
    event = 'BufRead',
    dependencies = {
      'MunifTanjim/' .. 'nui.nvim',
      'nvim-lua/' .. 'plenary.nvim',
    },
    opts = {
      allow_different_key = true,
      max_count = 3,
      disabled_keys = {
        ['<Up>'] = { 'n', 'x' },
        ['<Down>'] = { 'n', 'x' },
        ['<Left>'] = { 'n', 'x' },
        ['<Right>'] = { 'n', 'x' },
      },
      disabled_filetypes = {
        'TelescopePrompt',
        'copilot-chat',
        'checkhealth',
        'help',
        'lazy',
        'any-jump',
      },
    },
  },
  {
    'MeanderingProgrammer/' .. 'markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('render-markdown').setup {}
    end,
  },
  -- {
  --   'dgagn/' .. 'diagflow.nvim',
  --   event = 'LspAttach',
  --   opts = {
  --     max_width = 120,
  --     scope = 'line',
  --     toggle_event = { 'InsertEnter', 'InsertLeave' },
  --     show_borders = true,
  --   },
  -- },
  {
    'OlegGulevskyy/' .. 'better-ts-errors.nvim',
    dependencies = {
      'MunifTanjim/' .. 'nui.nvim',
    },
    opts = {
      keymaps = {
        toggle = 'B',
      },
    },
  },
}
