require('paq') {
  "savq/paq-nvim"; -- Let Paq manage itself

  'jiangmiao/auto-pairs';
  {'neoclide/coc.nvim', branch='release'};
  'mattn/emmet-vim';
  'Yggdroot/indentLine';
  'itchyny/lightline.vim';
  -- 'windwp/nvim-autopairs';
  -- 'neovim/nvim-lspconfig';
  {'nvim-treesitter/nvim-treesitter', run=':TSUpdate'};
  'windwp/nvim-ts-autotag';
  'JoosepAlviste/nvim-ts-context-commentstring';
  'p00f/nvim-ts-rainbow';
  'nvim-lua/plenary.nvim';
  'nvim-lua/popup.nvim';
  'nvim-telescope/telescope.nvim';
  'nvim-telescope/telescope-project.nvim';
  'tomasiser/vim-code-dark';
  'tpope/vim-commentary';
  'tpope/vim-fugitive';
  'tpope/vim-repeat';
  'mhinz/vim-startify';
  'tpope/vim-surround';
  'tveskag/nvim-blame-line';
  'ThePrimeagen/vim-be-good';
}

local previewers = require('telescope.previewers')
local bad_files = function (filepath)
  local _bad = { 'metadata/.*%.json', 'html2pdf.bundle.min' } -- Put all filetypes that slow you down in this array
  for _, v in ipairs(_bad) do
    if filepath:match(v) then
      return false
    end
  end
  return true
end

local preview_maker = function (filepath, bufnr, opts)
  opts = opts or {}
  if opts.use_ft_detect == nil then opts.use_ft_detect = true end
  opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
  previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

-- Setup Telescope
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--hidden',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    file_ignore_patterns = {
      ".git/",
    },
    buffer_previewer_maker = preview_maker,
  },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_mru = true,
      mappings = {
        i = {
          ["<c-d>"] = "delete_buffer",
        },
        n = {
          ["<c-d>"] = "delete_buffer",
        }
      }
    }
  },
  extensions = {
    project = {
      hidden_files = true
    }
  }
}

-- Setup Treesitter
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
  },
}

require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true
  }
}

-- require('nvim-autopairs').setup()
-- require('lspconfig').tsserver.setup{}

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
