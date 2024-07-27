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

  vim.g.copilot_workspace_folders = { '~/projects/be/bizops', '~/projects/be/bizops-micro', '~/projects/be/finops' }

  return packages
end

M.setup_copilot_chat = function()
  local packages = {
    'ryenguyen7411/' .. 'CopilotChat.nvim',
    branch = 'develop',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
    },
    config = function()
      local select = require 'CopilotChat.select'

      require('CopilotChat').setup {
        prompts = {
          ReviewDiff = {
            prompt = '/COPILOT_REVIEWDIFF Review the selected code.',
            selection = select.clipboard,
          },
          FixLang = 'Please correct any grammar and spelling errors, improve the grammar and wording of the following text.',
        },
        window = {
          layout = 'float',
          width = 0.7,
          height = 0.7,
        },
        mappings = {
          complete = {
            detail = 'Use <C-h> for options.',
            insert = '<C-h>',
          },
        },
        show_help = false,
        auto_follow_cursor = false,
        highlight_selection = false,
        context = 'buffers',
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
      require('supermaven-nvim').setup {}
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
