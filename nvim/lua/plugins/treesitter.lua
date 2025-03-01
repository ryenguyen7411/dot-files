local M = {}

M.setup_treesitter = function()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      use_languagetree = true,
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
    },
  }

  vim.g.skip_ts_context_commentstring_module = true

  vim.keymap.set(
    'n',
    '<space><space>',
    ':if exists("g:syntax_on")<Bar>syntax off<Bar>else<Bar>syntax on<Bar>endif<CR>|:TSToggle highlight<CR>|:TSToggle rainbow<CR>',
    { silent = true }
  )
end

M.setup_autotag = function()
  require('nvim-ts-autotag').setup {
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false, -- Auto close on trailing </
    },
    -- Also override individual filetype configs, these take priority.
    -- Empty by default, useful if one of the "opts" global settings
    -- doesn't work well in a specific filetype
    per_filetype = {
      ['html'] = {
        enable_close = false,
      },
    },
  }
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    build = ':TSUpdate',
    dependencies = {
      { 'JoosepAlviste/nvim-ts-context-commentstring' },
    },
    config = function()
      M.setup_treesitter()
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'BufRead',
    config = function()
      M.setup_autotag()
    end,
  },
  {
    'windwp/' .. 'nvim-autopairs',
    event = 'BufRead',
    opts = {},
  },
}
