local g = vim.g

local M = {}

M.setup_colorscheme = function()
  require('tokyonight').setup {
    transparent = true,
    on_colors = function(c)
      c.border = c.border_highlight
    end,
    on_highlights = function(hl, c)
      hl['@variable'] = { fg = c.blue1 }
      hl['@variable.builtin'] = { fg = c.blue1 }

      hl['Conditional'] = { fg = c.magenta }
      hl['Repeat'] = { fg = c.magenta }

      hl['LineNr'] = { fg = '#565f89' }
      hl['LineNrAbove'] = { fg = '#565f89' }
      hl['LineNrBelow'] = { fg = '#565f89' }
    end,
  }

  g.lightline = {
    colorscheme = 'tokyonight',
  }

  local transparents = {
    'Normal',
    'NormalNC',
    'Comment',
    'Constant',
    'Special',
    'Identifier',
    'Statement',
    'PreProc',
    'Type',
    'Underlined',
    'Todo',
    'String',
    'Function',
    'Conditional',
    'Repeat',
    'Operator',
    'Structure',
    'LineNr',
    'NonText',
    'SignColumn',
    'CursorLineNr',
    'EndOfBuffer',

    'NormalFloat',
    'FloatBorder',
    'TelescopeNormal',
    'TelescopeBorder',
    'TelescopeMultiSelection',
  }

  for _, part in pairs(transparents) do
    vim.cmd('au VimEnter * highlight ' .. part .. ' ctermbg=NONE guibg=NONE')
  end

  vim.cmd 'colorscheme tokyonight'
end

M.setup_highlightcolor = function()
  return {
    'brenoprata10/nvim-highlight-colors',
    event = 'BufRead',
    config = function()
      require('nvim-highlight-colors').setup {
        render = 'virtual',
      }
    end,
  }
end

M.setup_rainbow_delimiters = function()
  return {
    'HiPhish/rainbow-delimiters.nvim',
    event = 'BufRead',
    config = function()
      vim.cmd 'highlight RainbowDelimiterRed     guifg=#db4b4b'
      vim.cmd 'highlight RainbowDelimiterOrange  guifg=#ff9e64'
      vim.cmd 'highlight RainbowDelimiterYellow  guifg=#e0d60d'
      vim.cmd 'highlight RainbowDelimiterGreen   guifg=#1abc9c'
      vim.cmd 'highlight RainbowDelimiterCyan    guifg=#2ac3de'
      vim.cmd 'highlight RainbowDelimiterBlue    guifg=#326bc7'
      vim.cmd 'highlight RainbowDelimiterViolet  guifg=#9d7cd8'

      local rainbow_delimiters = require 'rainbow-delimiters'

      require('rainbow-delimiters.setup').setup {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        priority = {
          [''] = 110,
          lua = 210,
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  }
end

return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      M.setup_colorscheme()
    end,
  },
  M.setup_highlightcolor(),
  M.setup_rainbow_delimiters(),

  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    main = 'ibl',
    opts = {},
  },
  { 'itchyny/lightline.vim' },
  { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },
}
