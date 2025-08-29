local M = {}

M.setup_supermaven = function()
  return {
    'supermaven-inc/supermaven-nvim',
    event = 'BufRead',
    config = function()
      require('supermaven-nvim').setup {
        -- disable annoying startup message
        log_level = 'off',
      }
    end,
  }
end

M.setup_minuet = function()
  return {
    'milanglacier/minuet-ai.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('minuet').setup {
        provider = 'codestral', -- Default provider with good performance
        request_timeout = 3,
        context_window = 16000,
        throttle = 1000,
        debounce = 400,
        n_completions = 3,
        add_single_line_entry = true,
        notify = 'warn',
        provider_options = {
          codestral = {
            optional = {
              max_tokens = 256,
              stop = { '\n\n' },
            },
          },
        },
        -- Virtual text configuration (optional)
        virtualtext = {
          auto_trigger_ft = {}, -- Add filetypes you want auto-completion for
          keymap = {
            accept = '<A-A>',
            accept_line = '<A-a>',
            accept_n_lines = '<A-z>',
            prev = '<A-[>',
            next = '<A-]>',
            dismiss = '<A-e>',
          },
        },
      }
    end,
  }
end

return {
  M.setup_supermaven(),
  -- M.setup_minuet(),
}
