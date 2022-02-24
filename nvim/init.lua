local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup({ function(use)
  -- Packer can manage itself
  use { 'wbthomason/' .. 'packer.nvim' }

  use { 'nvim-lua/' .. 'plenary.nvim' }
  use { 'nvim-lua/' .. 'popup.nvim' }

  use {
    'ryenguyen7411/' .. 'any-jump.vim',
    branch='develop', event='BufRead',
    config = function()
      require('plugins.anyjump').setup()
    end
  }

  use {
    'sindrets/' .. 'diffview.nvim',
    event='VimEnter',
    config = function()
      require('plugins.diffview').setup()
    end
  }

  use {
    'mattn/' .. 'emmet-vim',
    event='BufRead',
    config = function()
      require('plugins.emmet').setup()
    end
  }

  use {
    'lukas-reineke/' .. 'indent-blankline.nvim',
    event='BufRead',
    config = function()
      require('plugins.indent_blankline').setup()
    end
  }

  use { 'itchyny/' .. 'lightline.vim' }

  -- use {
  --   'echasnovski/' .. 'mini.nvim', branch = 'stable',
  --   config = function()
  --     require('plugins.mini').setup()
  --   end
  -- }

  use {
    'windwp/' .. 'nvim-autopairs',
    event='BufRead',
    config = function()
      require('plugins.autopair').setup()
    end
  }

  use {
    'tveskag/' .. 'nvim-blame-line',
    event='BufRead',
    config = function()
      require('plugins.blameline').setup()
    end
  }

  use { 'jose-elias-alvarez/' .. 'nvim-lsp-ts-utils', event='VimEnter' }

  use {
    'neovim/' .. 'nvim-lspconfig',
    after = { 'nvim-lsp-ts-utils' },
    config = function()
      require('plugins.lspconfig_setup').setup()
    end
  }

  use {
    'nvim-pack/' .. 'nvim-spectre',
    event='VimEnter',
    config = function()
      require('plugins.spectre').setup()
    end
  }

  use {
    'nvim-treesitter/' .. 'nvim-treesitter',
    commit = '668de0951a36ef17016074f1120b6aacbe6c4515',
    run=':TSUpdate', event='VimEnter',
    config = function()
      require('plugins.treesitter').setup()
    end
  }

  use {'windwp/' .. 'nvim-ts-autotag', event='BufRead'}

  use {'JoosepAlviste/' .. 'nvim-ts-context-commentstring', event='BufRead'}

  use {'p00f/' .. 'nvim-ts-rainbow', event='BufRead'}

  use {'nvim-telescope/' .. 'telescope-file-browser.nvim', event='VimEnter'}

  use {'nvim-telescope/' .. 'telescope-fzf-native.nvim', run='make', event='VimEnter'}

  use {'nvim-telescope/' .. 'telescope-project.nvim', event='VimEnter'}

  use {
    'nvim-telescope/' .. 'telescope.nvim',
    after = { 'telescope-project.nvim', 'telescope-file-browser.nvim', 'telescope-fzf-native.nvim' },
    config = function()
      require('plugins.telescope').setup()
    end
  }

  use {
    'RRethy/nvim-base16',
    config = function()
      require('plugins.themer').setup()
    end
  }

  use { 'folke/' .. 'tokyonight.nvim' }

  use { 'tpope/' .. 'vim-commentary', event='BufRead' }

  use {
    'mhinz/' .. 'vim-startify',
    config = function()
      require('plugins.startify').setup()
    end
  }

  use {
    'thinca/' .. 'vim-quickrun',
    config = function()
      require('plugins.quickrun').setup()
    end
  }

  use {'tpope/' .. 'vim-repeat', event='BufRead'}

  use {'tpope/' .. 'vim-surround', event='BufRead'}

  use { 'svermeulen/' .. 'vimpeccable' }

  -- Automatically set up your configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end,
config = {
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'single' })
    end
  }
}})

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua

