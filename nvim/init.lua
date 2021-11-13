local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  use 'mhinz/vim-startify'
  use 'itchyny/lightline.vim'
  use 'folke/tokyonight.nvim'
  use 'svermeulen/vimpeccable'

  use {
    'nvim-telescope/telescope.nvim', cmd='Telescope',
    requires = {
      {'nvim-telescope/telescope-project.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', run='make'},
    },
    setup = function()
      require('plugins.telescope').setup()
    end
  }
  use {
    'nvim-treesitter/nvim-treesitter', run=':TSUpdate',
    after='telescope.nvim',
    setup = function()
      require('plugins.treesitter').setup()
    end
  }

  use {'JoosepAlviste/nvim-ts-context-commentstring', event='BufRead'}
  use {'neoclide/coc.nvim', branch='release', event='BufRead'}
  use {'p00f/nvim-ts-rainbow', event='BufRead'}
  use {'tpope/vim-commentary', event='BufRead'}
  use {'tpope/vim-repeat', event='BufRead'}
  use {'tpope/vim-surround', event='BufRead'}
  use {'Yggdroot/indentLine', event='BufRead'}
  use {
    'windwp/nvim-autopairs', event='BufRead',
    setup = function()
      require('plugins.autopair').setup()
    end
  }
  use {
    'windwp/nvim-spectre', event='BufRead',
    setup = function()
      require('spectre').setup()
    end
  }
  use {'windwp/nvim-ts-autotag', event='BufRead'}
  use {'mattn/emmet-vim', event='InsertEnter'}

  use {'tveskag/nvim-blame-line', cmd='ToggleBlameLine'}
  use {
    'sindrets/diffview.nvim', cmd={'DiffviewOpen','DiffviewFileHistory'},
    setup = function()
      require('plugins.diffview').setup()
    end
  }
  use 'ryenguyen7411/any-jump.vim'

  -- use {
  --   'neovim/nvim-lspconfig',
  --   'williamboman/nvim-lsp-installer',
  -- }

  -- 'neovim/nvim-lspconfig'
  -- use 'tomasiser/vim-code-dark'
  -- use 'tpope/vim-fugitive'

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
