local M = {}

M.setup = function()
  local select = require 'CopilotChat.select'

  require('CopilotChat').setup {
    prompts = {
      -- Code related prompts
      -- Explain = 'Please explain how the following code works.',
      -- Review = 'Please review the following code and provide suggestions for improvement.',
      -- Tests = 'Please explain how the selected code works, then generate unit tests for it.',
      -- Refactor = 'Please refactor the following code to improve its clarity and readability.',
      -- FixError = 'Please explain the error in the following text and provide a solution.',
      -- Naming = 'Please provide better names for the following variables and functions.',
      -- Documentation = 'Please provide documentation for the following code.',
      -- Commit = {
      --   prompt = 'Write commit message for the change with commitizen convention',
      --   selection = function(source)
      --     return select.gitdiff(source, true)
      --   end,
      -- },
      -- -- Text related prompts
      -- Summarize = 'Please summarize the following text.',
      -- FixLang = 'Please correct any grammar and spelling errors, improve the grammar and wording of the following text.',
      -- Concise = 'Please rewrite the following text to make it more concise.',
    },
    auto_follow_cursor = false,
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
  }

  M.mapping()
end

M.mapping = function()
  function copilot_chat_input()
    local input = vim.fn.input 'Quick Chat: '
    if input ~= '' then
      require('CopilotChat').ask(input, { context = 'buffers' })
    end
  end

  function copilot_chat_context()
    -- require('CopilotChat').toggle { selection = require('CopilotChat.select').buffer }
    -- testing for sometime
    require('CopilotChat').toggle { context = 'buffers' }
  end

  vim.keymap.set('n', ',/', '<cmd>lua copilot_chat_input()<CR>', {})
  vim.keymap.set('n', ',.', '<cmd>lua copilot_chat_context()<CR>', {})
  vim.keymap.set('n', ',,', '<cmd>CopilotChatStop<CR>', {})
end

return M
