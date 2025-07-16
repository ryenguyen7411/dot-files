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

  require('markview').setup {
    preview = {
      filetypes = { 'markdown', 'codecompanion', 'opencode_output', 'opencode_input' },
      ignore_buftypes = {},
      modes = { 'n', 'i', 'no', 'c' },
      hybrid_modes = { 'i' },

      -- This is nice to have
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2
          vim.wo[win].conecalcursor = 'nc'
        end,
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
      { 'OXY2DEV/markview.nvim' },
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
  {
    'andymass/vim-matchup',
    init = function()
      -- modify your configuration vars here
      vim.g.matchup_treesitter_stopline = 500

      -- or call the setup function provided as a helper. It defines the
      -- configuration vars for you
      require('match-up').setup {
        treesitter = {
          stopline = 500,
        },
      }
    end,
    -- or use the `opts` mechanism built into `lazy.nvim`. It calls
    -- `require('match-up').setup` under the hood
    ---@type matchup.Config
    opts = {
      treesitter = {
        stopline = 500,
      },
    },
  },
}
