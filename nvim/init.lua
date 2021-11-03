require('paq') {
  "savq/paq-nvim"; -- Let Paq manage itself

  'nvim-lua/plenary.nvim';
  'nvim-lua/popup.nvim';

  'itchyny/lightline.vim';
  'JoosepAlviste/nvim-ts-context-commentstring';
  'mattn/emmet-vim';
  'mhinz/vim-startify';
  {'neoclide/coc.nvim', branch='release'};
  -- 'neovim/nvim-lspconfig';
  'nvim-telescope/telescope.nvim';
  'nvim-telescope/telescope-project.nvim';
  {'nvim-treesitter/nvim-treesitter', run=':TSUpdate'};
  'p00f/nvim-ts-rainbow';
  'tomasiser/vim-code-dark';
  'tpope/vim-commentary';
  'tpope/vim-fugitive';
  'tpope/vim-repeat';
  'tpope/vim-surround';
  'tveskag/nvim-blame-line';
  'Yggdroot/indentLine';
  'windwp/nvim-autopairs';
  'windwp/nvim-ts-autotag';

  'folke/tokyonight.nvim';
  'sindrets/diffview.nvim';
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
    disable_devicons = true
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
    },
    find_files = {
      disable_devicons = true
    },
    file_browser = {
      disable_devicons = true
    },
    live_grep = {
      disable_devicons = true
    }
  },
  extensions = {
    project = {
      hidden_files = true
    },
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
  context_commentstring = {
    enable = true
  },
}

local npairs = require'nvim-autopairs'
local Rule   = require'nvim-autopairs.rule'
npairs.setup {
  check_ts = true,
  map_cr = true,
  ignored_next_char = "[%w%.]"
}
npairs.add_rules {
  Rule(' ', ' ')
    :with_pair(function (opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
  Rule('( ', ' )')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
      end)
      :use_key(')'),
  Rule('{ ', ' }')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
      end)
      :use_key('}'),
  Rule('[ ', ' ]')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
      end)
      :use_key(']')
}

require'diffview'.setup{
  use_icons = false
}

-- require('lspconfig').tsserver.setup{}

require('settings')    -- lua/settings.lua
require('autocmds')    -- lua/autocmds.lua
require('mappings')    -- lua/mappings.lua
