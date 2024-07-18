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
        -- TASK
        EPIC = { signs = false },
        TASK = { signs = false, color = 'info' },
        DONE = { signs = false, color = 'hint' },
        HIGH = { signs = false, color = 'warning' },
        VITAL = { signs = false, color = 'error' },
        -- STOCK
        BUY = { signs = false, color = 'hint' },
        SELL = { signs = false, color = 'error' },
        -- NORMAL
        TODO = { icon = ' ', color = 'info' },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
        TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
    },
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
  {
    'folke/zen-mode.nvim',
    keys = {
      { 'zp', '<cmd>ZenMode<CR>', desc = 'ZenMode' },
    },
    cmd = { 'ZenMode' },
    opts = {},
  },
  {
    'oysandvik94/curl.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { 'co', '<cmd>CurlOpen global<CR>', desc = 'CurlOpen' },
      { 'cp', '<cmd>CurlClose<CR>', desc = 'CurlClose' },
    },
    config = function()
      require('curl').setup {}
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
}
