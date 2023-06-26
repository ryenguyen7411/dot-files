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
    'ryenguyen7411/' .. 'any-jump.vim', event='BufRead',
    config = function()
      require('plugins.anyjump').setup()
    end
  },

  {
    'sindrets/' .. 'diffview.nvim', event='VimEnter',
    config = function()
      require('plugins.diffview').setup()
    end
  },

  {
    'mattn/' .. 'emmet-vim', event='BufRead',
    config = function()
      require('plugins.emmet').setup()
    end
  },

  {
    'lukas-reineke/' .. 'indent-blankline.nvim', event='BufRead',
    config = function()
      require('plugins.indent_blankline').setup()
    end
  },

  { 'itchyny/' .. 'lightline.vim' },

  {
    'windwp/' .. 'nvim-autopairs', event='BufRead',
    config = function()
      require('plugins.autopair').setup()
    end
  },

  {
    'tveskag/' .. 'nvim-blame-line', event='BufRead',
    config = function()
      require('plugins.blameline').setup()
    end
  },

  {
    'neovim/' .. 'nvim-lspconfig',
    config = function()
      require('plugins.lspconfig_setup').setup()
    end
  },

  {
    'nvim-treesitter/' .. 'nvim-treesitter', build=':TSUpdate', event='VimEnter',
    config = function()
      require('plugins.treesitter').setup()
    end
  },

  {'windwp/' .. 'nvim-ts-autotag', event='BufRead'},

  {'JoosepAlviste/' .. 'nvim-ts-context-commentstring', event='BufRead'},

  {'HiPhish/' .. 'nvim-ts-rainbow2', event='BufRead'},

  {
    'nvim-telescope/' .. 'telescope.nvim', event='VimEnter',
    dependencies = {
      {'nvim-telescope/' .. 'telescope-file-browser.nvim'},
      {'nvim-telescope/' .. 'telescope-fzf-native.nvim', build='make'},
      {'nvim-telescope/' .. 'telescope-project.nvim'},
    },
    config = function()
      require('plugins.telescope').setup()
    end
  },

  {
    'folke/' .. 'tokyonight.nvim', priority=1000, lazy=false,
    config = function()
      require('plugins.theme').tokyonight()
    end
  },

  { 'tpope/' .. 'vim-commentary', event='BufRead' },

  {
    'mhinz/' .. 'vim-startify',
    config = function()
      require('plugins.startify').setup()
    end
  },

  {
    'thinca/' .. 'vim-quickrun',
    config = function()
      require('plugins.quickrun').setup()
    end
  },

  {'tpope/' .. 'vim-repeat', event='BufRead'},

  {'tpope/' .. 'vim-surround', event='BufRead'},

  { 'svermeulen/' .. 'vimpeccable' },
}, {
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
