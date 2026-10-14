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
        provider = 'openai_compatible',
        virtualtext = {
          auto_trigger_ft = { '*' },
          keymap = {
            accept = '<C-m>',
            accept_line = '<C-l>',
            prev = '<C-j> ',
            next = '<C-k>',
            -- accept_line = '<S-Tab>',
            -- accept_n_lines = '<A-z>',
            -- prev = '<A-[>',
            -- next = '<A-]>',
            -- dismiss = '<Esc>',
          },
        },
        provider_options = {
          openai_compatible = {
            model = 'code-completetion-plan',
            end_point = 'https://9router.ryeai.app/v1/chat/completions',
            api_key = 'AI_AUTH_TOKEN',
            name = 'RyeAI',
            stream = true,
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
    event = 'VeryLazy',
    opts = {
      -- Next Edit Suggestions (NES): Cursor-Tab-style multi-line edits, powered by Copilot
      nes = {
        enabled = true,
        debounce = 100,
      },
      cli = {
        win = {
          layout = 'right',
          split = { width = 80 },
        },
        tools = {
          cursor = { cmd = { 'cursor', 'agent' } },
        },
      },
    },
    keys = {
      -- <Tab>: jump to / apply next edit suggestion -> accept Copilot ghost text -> literal <Tab>
      {
        '<Tab>',
        function()
          if require('sidekick').nes_jump_or_apply() then
            return
          end
          if vim.lsp.inline_completion.get() then
            return
          end
          return '<Tab>'
        end,
        mode = 'i',
        expr = true,
        desc = 'AI: Next edit / accept suggestion',
      },
      {
        '<M-]>',
        function()
          vim.lsp.inline_completion.select { count = 1 }
        end,
        mode = 'i',
        desc = 'AI: Next inline suggestion',
      },
      {
        '<M-[>',
        function()
          vim.lsp.inline_completion.select { count = -1 }
        end,
        mode = 'i',
        desc = 'AI: Previous inline suggestion',
      },
      -- NES
      {
        '<leader>snn',
        function()
          require('sidekick').nes_jump_or_apply()
        end,
        desc = 'NES: Jump / apply',
      },
      { '<leader>snu', '<cmd>Sidekick nes update<cr>', desc = 'NES: Update suggestion' },
      { '<leader>sne', '<cmd>Sidekick nes enable<cr>', desc = 'NES: Enable' },
      { '<leader>snd', '<cmd>Sidekick nes disable<cr>', desc = 'NES: Disable' },
      { '<leader>snc', '<cmd>Sidekick nes clear<cr>', desc = 'NES: Clear' },
      -- CLI (Cursor agent)
      {
        '<leader>sct',
        function()
          require('sidekick.cli').toggle { name = 'cursor', focus = true }
        end,
        desc = 'CLI: Toggle',
      },
      {
        '<leader>scs',
        function()
          require('sidekick.cli').send { name = 'cursor', msg = '{selection}' }
        end,
        mode = 'x',
        desc = 'CLI: Send selection',
      },
      {
        '<leader>scf',
        function()
          require('sidekick.cli').focus { name = 'cursor' }
        end,
        desc = 'CLI: Focus',
      },
      {
        '<leader>sch',
        function()
          require('sidekick.cli').hide { name = 'cursor' }
        end,
        desc = 'CLI: Hide',
      },
    },
    -- Runs at startup (not on VeryLazy) so Copilot also attaches to the buffer opened via `nvim <file>`
    init = function()
      -- Copilot via Neovim's native LSP. Base config (incl. :LspCopilotSignIn / :LspCopilotSignOut)
      -- ships with nvim-lspconfig; requires `copilot-language-server` on PATH (see Brewfile).
      vim.lsp.config('copilot', {
        settings = {
          telemetry = { telemetryLevel = 'off' },
        },
      })
      vim.lsp.enable 'copilot'

      -- Native ghost-text completions (Neovim 0.12+)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('copilot_inline_completion', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method('textDocument/inlineCompletion', args.buf) then
            vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end,
    config = function(_, opts)
      require('sidekick').setup(opts)
    end,
  }
end

return {
  M.setup_supermaven(), -- Sunset by Cursor; still works for some accounts — toggle if needed
  -- M.setup_sidekick(),
  -- M.setup_minuet(),
}
