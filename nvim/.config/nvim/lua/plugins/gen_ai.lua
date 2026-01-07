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

M.setup_sidekick = function()
  return {
    'folke/sidekick.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    lazy = false,
    priority = 100,
    opts = {
      debug = true, -- Enable debug logging
      -- Next Edit Suggestions (NES) configuration
      nes = {
        enabled = true,
        keys = {
          accept = '<M-l>', -- Alt+L to accept suggestion
          reject = '<M-h>', -- Alt+H to reject suggestion
          next = '<M-]>', -- Alt+] for next suggestion
          prev = '<M-[>', -- Alt+[ for previous suggestion
        },
      },
      -- CLI integration for Cursor
      cli = {
        enabled = true,
        default = 'cursor', -- Set cursor as default CLI tool
        tools = {
          cursor = {
            cmd = { 'cursor', 'agent' },
            name = 'Cursor',
          },
        },
        keys = {
          toggle = '<leader>sct', -- Toggle CLI window
          send = '<leader>scs', -- Send selection to CLI
          focus = '<leader>scf', -- Focus CLI window
        },
        window = {
          position = 'right',
          size = 80,
        },
      },
    },
    keys = {
      -- NES keybindings
      { '<leader>snu', '<cmd>Sidekick nes update<cr>', desc = 'NES: Update suggestion' },
      { '<leader>sne', '<cmd>Sidekick nes enable<cr>', desc = 'NES: Enable' },
      { '<leader>snd', '<cmd>Sidekick nes disable<cr>', desc = 'NES: Disable' },
      { '<leader>snc', '<cmd>Sidekick nes clear<cr>', desc = 'NES: Clear' },
      -- CLI keybindings
      { '<leader>sct', '<cmd>Sidekick cli toggle<cr>', desc = 'CLI: Toggle' },
      { '<leader>scs', '<cmd>Sidekick cli send msg="{selection}"<cr>', mode = 'v', desc = 'CLI: Send selection' },
      { '<leader>scf', '<cmd>Sidekick cli focus<cr>', desc = 'CLI: Focus' },
      { '<leader>sch', '<cmd>Sidekick cli hide<cr>', desc = 'CLI: Hide' },
    },
    config = function(_, opts)
      -- Configure native Copilot LSP with sign-in support
      vim.lsp.config('copilot', {
        cmd = { 'copilot-language-server', '--stdio' },
        root_markers = { '.git' },
        filetypes = { '*' },
        single_file_support = true,
        init_options = {
          editorInfo = {
            name = 'Neovim',
            version = tostring(vim.version()),
          },
          editorPluginInfo = {
            name = 'Neovim',
            version = tostring(vim.version()),
          },
        },
        settings = {
          telemetry = {
            telemetryLevel = 'all',
          },
        },
        on_attach = function(client, bufnr)
          -- Create LspCopilotSignIn command
          vim.api.nvim_buf_create_user_command(bufnr, 'LspCopilotSignIn', function()
            client:request('signIn', vim.empty_dict(), function(err, result)
              if err then
                vim.notify(err.message, vim.log.levels.ERROR)
                return
              end
              if result.command then
                local code = result.userCode
                local command = result.command
                vim.fn.setreg('+', code)
                vim.fn.setreg('*', code)
                local continue = vim.fn.confirm(
                  'Copied your one-time code to clipboard.\\nOpen the browser to complete the sign-in process?',
                  '&Yes\\n&No'
                )
                if continue == 1 then
                  client:exec_cmd(command, { bufnr = bufnr }, function(cmd_err, cmd_result)
                    if cmd_err then
                      vim.notify(cmd_err.message, vim.log.levels.ERROR)
                      return
                    end
                    if cmd_result.status == 'OK' then
                      vim.notify('Signed in as ' .. cmd_result.user .. '.')
                    end
                  end)
                end
              end
              if result.status == 'PromptUserDeviceFlow' then
                vim.notify('Enter your one-time code ' .. result.userCode .. ' in ' .. result.verificationUri)
              elseif result.status == 'AlreadySignedIn' then
                vim.notify('Already signed in as ' .. result.user .. '.')
              end
            end)
          end, { desc = 'Sign in Copilot with GitHub' })
        end,
      })

      vim.lsp.enable 'copilot'

      -- Setup sidekick with options
      require('sidekick').setup(opts)

      -- Create an autocommand to ensure Copilot attaches to all buffers
      vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
        pattern = '*',
        callback = function(args)
          local bufnr = args.buf
          if vim.bo[bufnr].buftype == '' then
            vim.lsp.start {
              name = 'copilot',
              cmd = { 'copilot-language-server', '--stdio' },
            }
          end
        end,
      })
    end,
  }
end

return {
  M.setup_supermaven(),
  -- M.setup_sidekick(),
  -- M.setup_minuet(),
}
