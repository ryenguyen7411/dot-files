local M = {}

M.setup_copilot = function()
  local packages = {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        enabled = false,
      },
    },
  }

  return packages
end

M.setup_copilot_chat = function()
  local packages = {
    'CopilotC-Nvim/' .. 'CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
    },
    build = 'make tiktoken',
    config = function()
      local select = require 'CopilotChat.select'

      require('CopilotChat').setup {
        model = 'claude-sonnet-4',
        context = { 'buffers', 'filenames' },
        window = {
          layout = 'float',
          width = 0.7,
          height = 0.7,
        },
        show_help = false,
        auto_follow_cursor = false,
        highlight_selection = false,
        highlight_headers = false,
        log_level = 'error',

        prompts = {
          ReviewDiff = {
            prompt = '/COPILOT_REVIEWDIFF Review the selected code.',
            selection = select.clipboard,
          },
          FixLang = 'Please correct any grammar and spelling errors, improve the grammar and wording of the following text.',
        },
        mappings = {
          complete = {
            detail = 'Use <C-h> for options.',
            insert = '<C-h>',
          },
        },
      }
    end,
  }

  vim.keymap.set('n', ',.', '<cmd>CopilotChatToggle<CR>', {})
  vim.keymap.set('n', ',,', '<cmd>CopilotChatStop<CR>', {})

  return packages
end

M.setup_supermaven = function()
  return {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {
        -- disable annoying startup message
        log_level = 'off',
      }
    end,
  }
end

M.setup_codeium = function()
  vim.g.codeium_manual = true
  vim.g.codeium_disable_bindings = true
  vim.keymap.set('n', ',.', '<cmd>call codeium#Chat()<CR>', {})

  return {
    'Exafunction/codeium.vim',
    event = 'BufEnter',
  }
end

return {
  M.setup_copilot(),
  M.setup_copilot_chat(),
  M.setup_supermaven(),
  -- M.setup_codeium(),
}
