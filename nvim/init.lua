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
    'f-person/' .. 'git-blame.nvim', event='BufRead',
    config = function()
      require('plugins.blameline').setup()
    end
  },

  {
    'lukas-reineke/' .. 'indent-blankline.nvim', event='BufRead',
    main = 'ibl',
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

  { 'nvim-tree/' .. 'nvim-web-devicons' },

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

  -- { 'm4xshen/' .. 'hardtime.nvim', opts = {} },

  { 'will133/' .. 'vim-dirdiff' },

  { 'justinmk/' .. 'vim-sneak' },

  { 'github/' .. 'copilot.vim' },

  {
    'LunarVim/' .. 'bigfile.nvim',
    opts = {},
  },

  {
    "tris203/hawtkeys.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    }
  },

  {
    'RaafatTurki/' .. 'corn.nvim',
    config = function()
      require('corn').setup({
        item_preprocess_func = function(item)
          return item
        end,
        blacklisted_modes = { 'i' },
      })
    end,
  },

  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   branch = "canary",
  --   dependencies = {
  --     { "github/copilot.vim" }, -- or github/copilot.vim
  --     { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
  --     { "nvim-telescope/telescope.nvim" }, -- for telescope help actions (optional)
  --   },
  --   opts = {
  --     debug = true, -- Enable debugging
  --     -- See Configuration section for rest
  --   },
  --   -- See Commands section for default commands if you want to lazy load on them
  -- },
})

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
