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
        context = { 'buffers', 'files', 'filenames' },
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

  -- vim.keymap.set('n', ',.', '<cmd>CopilotChatToggle<CR>', {})
  -- vim.keymap.set('n', ',,', '<cmd>CopilotChatStop<CR>', {})

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

M.setup_code_companion = function()
  local package = {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      strategies = {
        chat = {
          adapter = 'copilot',
          model = 'claude-sonnet-4',
          keymaps = {
            close = {
              modes = { n = '<C-c>', i = '<C-c>' },
              opts = {},
            },
          },
        },
        inline = {
          adapter = 'copilot',
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
          prompt = 'Prompt ', -- Prompt used for interactive LLM calls
          provider = 'snacks', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
        },
        chat = {
          icons = {
            pinned_buffer = ' ',
            watched_buffer = '👀 ',
          },
          window = {
            layout = 'float',
            height = 0.7,
            width = 0.7,
          },
          auto_scroll = false,
        },
      },
      log_level = 'ERROR',
    },
  }

  vim.keymap.set('n', ',.', '<cmd>CodeCompanionChat Toggle<CR>', {})
  vim.keymap.set('n', ",'", '<cmd>CodeCompanion<CR>', {})
  vim.keymap.set('v', ",'", ":'<,'>CodeCompanion<CR>", {})

  return package
end

-- M.setup_nes = function()
--   return {
--     'Xuyuanp/nes.nvim',
--     event = 'VeryLazy',
--     keys = {
--       {
--         'H',
--         function()
--           local function debug_log(msg)
--             vim.notify('[DEBUG] ' .. tostring(msg), vim.log.levels.DEBUG)
--           end

--           debug_log 'Debug log message here'
--           require('nes').get_suggestion()
--         end,
--         desc = '[Nes] get suggestion',
--       },
--       {
--         '<leader>H',
--         function()
--           require('nes').apply_suggestion(0, { jump = true, trigger = true })
--         end,
--         desc = '[Nes] apply suggestion',
--       },
--     },
--     dependencies = {
--       'nvim-lua/plenary.nvim',
--     },
--     opts = {},
--   }
-- end

return {
  M.setup_copilot(),
  -- M.setup_copilot_chat(),
  M.setup_supermaven(),
  M.setup_code_companion(),
  -- M.setup_nes(),
}
