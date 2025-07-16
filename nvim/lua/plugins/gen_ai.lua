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
  local packages = {
    {
      'olimorris/codecompanion.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        -- codecompanion extensions
        'ravitemer/codecompanion-history.nvim',
        -- 'Davidyz/VectorCode',
      },
      event = 'VeryLazy',
      opts = {
        strategies = {
          chat = {
            adapter = 'copilot',
            model = 'gemini-2.5-pro', -- "gemini-2.0-flash-001", "gpt-4o", "claude-3.5-sonnet", "gemini-2.5-pro", "claude-3.7-sonnet", "o3-mini", "claude-3.7-sonnet-thought", "o1", "o4-mini", "claude-sonnet-4",
            keymaps = {
              close = {
                modes = { n = '<C-c>', i = '<C-c>' },
                opts = {},
              },
            },
            opts = {
              completion_provider = 'default', -- blink|cmp|coc|default
            },
            tools = {
              ['next_edit_suggestion'] = {
                opts = {
                  --- the default is to open in a new tab, and reuse existing tabs
                  --- where possible
                  ---@type string|fun(path: string):integer?
                  jump_action = 'tabnew',
                },
              },
            },
            send = {
              callback = function(chat)
                vim.cmd 'stopinsert'
                chat:submit()
                chat:add_buf_message { role = 'llm', content = '' }
              end,
              index = 1,
              description = 'Send',
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
          diff = {
            enabled = true,
            close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
            layout = 'vertical', -- vertical|horizontal split for default provider
            opts = { 'internal', 'filler', 'closeoff', 'algorithm:patience', 'followwrap', 'linematch:120' },
            provider = 'mini_diff', -- default|mini_diff
          },
        },
        log_level = 'ERROR',
        extensions = {
          history = {
            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = 'gh',
              -- Keymap to save the current chat manually (when auto_save is disabled)
              save_chat_keymap = 'sc',
              -- Save all chats by default (disable to save only manually using 'sc')
              auto_save = true,
              -- Number of days after which chats are automatically deleted (0 to disable)
              expiration_days = 0,
              -- Picker interface (auto resolved to a valid picker)
              picker = 'snacks', --- ("telescope", "snacks", "fzf-lua", or "default")
              -- Customize picker keymaps (optional)
              picker_keymaps = {
                rename = { n = 'r', i = '<M-r>' },
                delete = { n = 'd', i = '<M-d>' },
                duplicate = { n = '<C-y>', i = '<C-y>' },
              },
              ---Automatically generate titles for new chats
              auto_generate_title = true,
              title_generation_opts = {
                ---Adapter for generating titles (defaults to current chat adapter)
                adapter = nil, -- "copilot"
                ---Model for generating titles (defaults to current chat model)
                model = nil, -- "gpt-4o"
                ---Number of user prompts after which to refresh the title (0 to disable)
                refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                ---Maximum number of times to refresh the title (default: 3)
                max_refreshes = 3,
              },
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = true,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              ---Directory path to save the chats
              dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
              ---Enable detailed logging for history extension
              enable_logging = false,
              ---Optional filter function to control which chats are shown when browsing
              chat_filter = nil, -- function(chat_data) return boolean end
            },
          },
          -- vectorcode = {
          --   ---@type VectorCode.CodeCompanion.ExtensionOpts
          --   opts = {
          --     tool_group = {
          --       -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
          --       enabled = true,
          --       -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
          --       -- if you use @vectorcode_vectorise, it'll be very handy to include
          --       -- `file_search` here.
          --       extras = {},
          --       collapse = false, -- whether the individual tools should be shown in the chat
          --     },
          --     tool_opts = {
          --       ---@type VectorCode.CodeCompanion.ToolOpts
          --       ['*'] = {},
          --       ---@type VectorCode.CodeCompanion.LsToolOpts
          --       ls = {},
          --       ---@type VectorCode.CodeCompanion.VectoriseToolOpts
          --       vectorise = {},
          --       ---@type VectorCode.CodeCompanion.QueryToolOpts
          --       query = {
          --         max_num = { chunk = -1, document = -1 },
          --         default_num = { chunk = 50, document = 10 },
          --         include_stderr = false,
          --         use_lsp = false,
          --         no_duplicate = true,
          --         chunk_mode = false,
          --         ---@type VectorCode.CodeCompanion.SummariseOpts
          --         summarise = {
          --           ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
          --           enabled = false,
          --           adapter = nil,
          --           query_augmented = true,
          --         },
          --       },
          --       files_ls = {},
          --       files_rm = {},
          --     },
          --   },
          -- },
        },
      },
      config = function(_, opts)
        local spinner = require 'plugins.codecompanion.spinner'
        spinner:init()

        -- Setup the entire opts table
        require('codecompanion').setup(opts)
      end,
    },
    -- {
    --   'Davidyz/VectorCode',
    --   version = '*',
    --   -- build = 'uv tool upgrade vectorcode', -- This helps keeping the CLI up-to-date
    --   dependencies = { 'nvim-lua/plenary.nvim' },
    --   opts = {
    --     cli_cmds = {
    --       vectorcode = 'vectorcode',
    --     },
    --     ---@type VectorCode.RegisterOpts
    --     async_opts = {
    --       debounce = 10,
    --       events = { 'BufWritePost', 'InsertEnter', 'BufReadPost' },
    --       exclude_this = true,
    --       n_query = 1,
    --       notify = false,
    --       -- query_cb = require('vectorcode.utils').make_surrounding_lines_cb(-1),
    --       run_on_register = false,
    --     },
    --     async_backend = 'default', -- or "lsp"
    --     exclude_this = true,
    --     n_query = 1,
    --     notify = true,
    --     timeout_ms = 5000,
    --     on_setup = {
    --       update = false, -- set to true to enable update when `setup` is called.
    --       lsp = false,
    --     },
    --     sync_log_env_var = false,
    --   },
    -- },
  }

  -- vim.keymap.set('n', ',.', '<cmd>CodeCompanionChat Toggle<CR>', { noremap = true, silent = true })
  -- vim.keymap.set('n', ",'", '<cmd>CodeCompanion<CR>', {})
  -- vim.keymap.set('v', ",'", ":'<,'>CodeCompanion<CR>", {})
  -- vim.keymap.set({ 'n', 'v' }, ',\\', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
  -- vim.g.codecompanion_auto_tool_mode = true

  return packages
end

M.setup_opencode_integration = function()
  local packages = {
    'sudo-tee/opencode.nvim',
    config = function()
      require('opencode').setup {
        default_global_keymaps = false,
        ui = {
          window_width = 0.25,
          output = {
            tools = {
              show_output = false,
            },
          },
        },
      }
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'OXY2DEV/markview.nvim' },
    },
  }

  vim.keymap.set('n', ',.', '<cmd>Opencode<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ',I', '<cmd>OpencodeOpenInputNewSession<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ',0', '<cmd>OpencodeConfigureProvider<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ',9', '<cmd>OpencodeModeSelect<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', ',\\', '<cmd>OpencodeSelectSession<CR>', { noremap = true, silent = true })

  return packages
end

return {
  M.setup_copilot(),
  -- M.setup_copilot_chat(),
  M.setup_supermaven(),
  unpack(M.setup_code_companion()),
  M.setup_opencode_integration(),
}
