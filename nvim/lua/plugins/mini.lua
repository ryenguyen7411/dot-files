return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      require('mini.ai').setup()
      require('mini.comment').setup()
      require('mini.move').setup {
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = '<',
          right = '>',
          down = '<M-j>',
          up = '<M-k>',

          -- Move current line in Normal mode
          line_left = '<',
          line_right = '>',
          line_down = '<M-j>',
          line_up = '<M-k>',
        },
        -- Options which control moving behavior
        options = {
          -- Automatically reindent selection during linewise vertical move
          reindent_linewise = false,
        },
      }
      require('mini.diff').setup()
      require('mini.splitjoin').setup {
        mappings = {
          toggle = 'gs',
        },
      }
      require('mini.surround').setup {
        custom_surroundings = {
          ['('] = { output = { left = '( ', right = ' )' } },
          ['['] = { output = { left = '[ ', right = ' ]' } },
          ['{'] = { output = { left = '{ ', right = ' }' } },
          ['<'] = { output = { left = '< ', right = ' >' } },
        },
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',
          update_n_lines = '',
        },
        search_method = 'cover_or_next',
      }
      require('mini.jump').setup()

      -- Remap adding surrounding to Visual mode selection
      vim.keymap.del('x', 'ys')
      vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true, silent = true })
      vim.keymap.set('n', 'yss', 'yss', { noremap = false })
    end,
  },
}
