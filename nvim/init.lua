local ensure_lazy = function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

local lazy_bootstrap = ensure_lazy()

require('lazy').setup({
  { 'nvim-lua/' .. 'plenary.nvim', priority=1000, lazy=false },
  { 'nvim-lua/' .. 'popup.nvim', priority=1000, lazy=false },
  {
    'folke/' .. 'tokyonight.nvim', priority=1000, lazy=false,
    config = function()
      require('plugins.theme').tokyonight()
    end,
  },
  {
    'mhinz/' .. 'vim-startify',
    config = function()
      require('plugins.startify').setup()
    end
  },
  { 'itchyny/' .. 'lightline.vim' },
  {
    'ryenguyen7411/' .. 'any-jump.vim',
    keys = {
      { '<F12>', '<cmd>AnyJump<CR>', desc = 'AnyJump' },
      { '<F8>', '<cmd>AnyJumpLastResults<CR>', desc = 'AnyJumpLastResults' },
    },
  },
  {
    'sindrets/' .. 'diffview.nvim',
    keys = {
      { '<space>r', '<cmd>DiffviewOpen<CR>', desc = 'DiffviewOpen' },
      { '<space>f', '<cmd>DiffviewFileHistory %<CR>', desc = 'DiffviewFileHistory' },
    },
    config = function()
      require('plugins.diffview').setup()
    end,
  },
  {
    'mattn/' .. 'emmet-vim', event='BufRead',
    config = function()
      require('plugins.emmet').setup()
    end,
  },
  {
    'f-person/' .. 'git-blame.nvim',
    keys = {
      { '<space>,b', '<cmd>GitBlameToggle<CR>', desc = 'GitBlameToggle' },
    },
  },
  {
    'lukas-reineke/' .. 'indent-blankline.nvim', event='BufRead',
    main = 'ibl', opts = {},
  },
  {
    'windwp/' .. 'nvim-autopairs', event='BufRead',
    opts = {},
  },
  {
    'neovim/' .. 'nvim-lspconfig', event='VeryLazy',
    config = function()
      require('plugins.lspconfig_setup').setup()
    end
  },
  {
    'nvim-treesitter/' .. 'nvim-treesitter', event='VeryLazy',
    build=':TSUpdate',
    dependencies = {
      {'JoosepAlviste/' .. 'nvim-ts-context-commentstring'},
    },
    config = function()
      require('plugins.treesitter').setup()
    end,
  },
  { 'windwp/' .. 'nvim-ts-autotag', event='BufRead' },
  { 'HiPhish/' .. 'nvim-ts-rainbow2', event='BufRead' },
  { 'nvim-tree/' .. 'nvim-web-devicons', event='VeryLazy' },
  {
    'nvim-telescope/' .. 'telescope.nvim', event='VeryLazy',
    dependencies = {
      {'nvim-telescope/' .. 'telescope-file-browser.nvim'},
      {'nvim-telescope/' .. 'telescope-fzf-native.nvim', build='make'},
      {'nvim-telescope/' .. 'telescope-project.nvim'},
    },
    config = function()
      require('plugins.telescope').setup()
    end
  },
  { 'tpope/' .. 'vim-commentary', event='BufRead' },
  {
    'thinca/' .. 'vim-quickrun', event='BufRead',
    config = function()
      require('plugins.quickrun').setup()
    end
  },
  { 'tpope/' .. 'vim-repeat', event='BufRead' },
  { 'tpope/' .. 'vim-surround', event='BufRead' },
  { 'will133/' .. 'vim-dirdiff' },
  { 'justinmk/' .. 'vim-sneak', event='BufRead' },
  {
    'github/' .. 'copilot.vim',
    config = function()
      require('plugins.copilot').setup()
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = "canary",
    opts = {},
  },
  {
    'LunarVim/' .. 'bigfile.nvim', event='BufRead',
    opts = {},
  },
  {
    'RaafatTurki/' .. 'corn.nvim', event='BufRead',
    config = function()
      require('corn').setup({
        item_preprocess_func = function(item)
          return item
        end,
        blacklisted_modes = { 'i' },
      })
    end,
  },
  {
    'folke/todo-comments.nvim', event='BufRead',
    keys = {
      { '<space>a', '<cmd>TodoTelescope<CR>', desc = 'TodoTelescope' },
    },
    opts = {},
  },

  {
    'brenoprata10/' .. 'nvim-highlight-colors',
    config = function()
      require('plugins.highlight_colors').setup()
    end,
  }

  -- { 'm4xshen/' .. 'hardtime.nvim', opts = {} },
})

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
