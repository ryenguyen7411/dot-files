return {
  { 'nvim-lua/' .. 'plenary.nvim', priority = 1000, lazy = false },
  { 'nvim-lua/' .. 'popup.nvim', priority = 1000, lazy = false },

  -- TO BE UPDATED
  {
    'mattn/' .. 'emmet-vim',
    event = 'BufRead',
    config = function()
      vim.keymap.set('i', '<C-j>', '<Plug>(emmet-expand-abbr)', { noremap = false })
    end,
  },

  -- { 'tpope/' .. 'vim-commentary', event = 'BufRead' },
  { 'tpope/' .. 'vim-repeat', event = 'BufRead' },
  -- { 'tpope/' .. 'vim-surround', event = 'BufRead' },
  { 'justinmk/' .. 'vim-sneak', event = 'BufRead' },
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
        'codecompanion',
        'toggleterm',
      },
    },
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
      require('curl').setup {
        -- default_flags = { '-i' },
      }
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
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
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup {}
    end,
  },
  {
    'HakonHarnes/img-clip.nvim',
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = '[Image]($FILE_PATH)',
          use_absolute_path = true,
        },
      },
    },
  },
  {
    'tpope/vim-abolish',
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      vim.api.nvim_create_autocmd('TermEnter', {
        pattern = 'term://*toggleterm#*',
        callback = function()
          vim.keymap.set('t', '<C-t>', '<cmd>ToggleTerm<CR>', { silent = true, buffer = true })
        end,
      })

      vim.keymap.set('n', '<C-t>', '<cmd>ToggleTerm direction=vertical size=60<CR>', { silent = true })

      require('toggleterm').setup {}
    end,
  },
  {
    'djoshea/vim-autoread',
  },
}
