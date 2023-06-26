local v = require('vimp')
local cmd = vim.cmd
local M = {}

M.setup = function()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      use_languagetree = true,
    },
    autotag = {
      enable = true,
    },
    rainbow = {
      enable = true,
      query = {
        javascript = 'rainbow-tags-react',
        tsx = 'rainbow-tags-react',
      },
    },
    context_commentstring = {
      enable = true
    },
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    }
  }
  M.rainbow()
  M.mapping()
end

M.mapping = function()
  v.nmap({'silent'}, '<leader><leader>', ':if exists("g:syntax_on")<Bar>syntax off<Bar>else<Bar>syntax on<Bar>endif<CR>|:TSToggle highlight<CR>|:TSToggle rainbow<CR>')
end

M.rainbow = function()
	cmd('highlight TSRainbowRed     guifg=#db4b4b')
	cmd('highlight TSRainbowOrange  guifg=#ff9e64')
	cmd('highlight TSRainbowYellow  guifg=#e0d60d')
	cmd('highlight TSRainbowGreen   guifg=#1abc9c')
	cmd('highlight TSRainbowCyan    guifg=#2ac3de')
	cmd('highlight TSRainbowBlue    guifg=#326bc7')
	cmd('highlight TSRainbowViolet  guifg=#9d7cd8')
end

return M
