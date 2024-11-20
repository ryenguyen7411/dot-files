local M = {}

M.setup_typescript_lsp = function()
  local lspconfig = require 'lspconfig'

  lspconfig.ts_ls.setup {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      M.attach(client, bufnr)
    end,
    root_dir = function(fname)
      if lspconfig.util.root_pattern '.vue-project'(fname) then
        return false
      else
        return lspconfig.util.root_pattern 'package.json'(fname)
      end
    end,
    single_file_support = false,
    filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx', 'javascript', 'javascriptreact', 'javascript.jsx' },
    init_options = {
      preferences = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
        importModuleSpecifierPreference = 'non-relative',
      },
    },
  }
  lspconfig.eslint.setup {
    on_attach = function(client, bufnr)
      vim.cmd [[ augroup LspEslint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> EslintFixAll
      augroup END ]]
      M.attach(client, bufnr)
    end,
    settings = {
      codeActionOnSave = {
        enable = true,
        mode = 'all',
      },
    },
  }
  lspconfig.quick_lint_js.setup {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
end

M.setup_other_lsp = function()
  local lspconfig = require 'lspconfig'

  lspconfig.stylelint_lsp.setup {
    on_attach = function(client, bufnr)
      vim.cmd [[ augroup LspStylelint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END ]]
      M.attach(client, bufnr)
    end,
    settings = {
      stylelintplus = {
        autoFixOnFormat = true,
        autoFixOnSave = true,
      },
    },
  }
  lspconfig.volar.setup {
    on_attach = function(client, bufnr)
      vim.cmd [[ augroup LspVolar
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END ]]
      M.attach(client, bufnr)
    end,
    root_dir = lspconfig.util.root_pattern '.vue-project',
    single_file_support = false,
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    init_options = {
      preferences = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
        importModuleSpecifierPreference = 'non-relative',
      },
    },
  }
  lspconfig.html.setup {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
  lspconfig.jsonls.setup {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
  lspconfig.dartls.setup {
    on_attach = function(client, bufnr)
      vim.cmd [[
      augroup LspFlutter
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END
      ]]

      M.attach(client, bufnr)
    end,
  }
  lspconfig.vimls.setup {
    on_attach = function(client, bufnr)
      require('aerial').on_attach(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
  lspconfig.intelephense.setup {
    on_attach = function(client, bufnr)
      vim.cmd [[
      augroup PhpLint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END
      ]]
      M.attach(client, bufnr)
    end,
  }
  lspconfig.astro.setup {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  local inlay_hints_enabled = false
  function toggle_inlay_hints()
    inlay_hints_enabled = not inlay_hints_enabled
    vim.lsp.inlay_hint.enable(inlay_hints_enabled)
  end

  vim.keymap.set('n', 'L', '<cmd>lua toggle_inlay_hints()<CR>', opts)
  vim.keymap.set('n', 'gF', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
  vim.keymap.set('n', 'B', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.keymap.set('n', '<F12>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)

  vim.keymap.set(
    'n',
    'go',
    '<cmd>lua vim.lsp.buf.code_action({ context = { only = { "source.addMissingImports.ts" } }, apply = true })<CR>',
    opts
  )
end

M.setup_lspconfig = function()
  require('mason-lspconfig').setup {}

  vim.diagnostic.config {
    float = {
      source = 'always',
      border = 'rounded',
      focus = false,
    },
    severity_sort = true,
    virtual_text = false,
  }

  require('lspconfig.ui.windows').default_options = {
    border = 'single',
  }
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = 'single',
  })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = 'single',
  })

  M.setup_typescript_lsp()
  M.setup_other_lsp()
end

M.setup_formatter = function()
  require('conform').setup {
    formatters_by_ft = {
      javascript = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      typescript = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      vue = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      astro = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      css = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      html = { 'prettier_d_slim', 'prettier', stop_after_first = true },
      lua = { 'stylua' },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  }
end

return {
  {
    'williamboman/mason.nvim',
    event = 'VeryLazy',
    keys = {
      { 'g<CR>', '<cmd>Mason<CR>', desc = 'MasonOpen' },
    },
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup {
        ui = {
          border = 'single',
          width = 0.7,
          height = 0.7,
        },
      }

      M.setup_lspconfig()
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    config = function()
      M.setup_formatter()
    end,
  },
  {
    'OlegGulevskyy/better-ts-errors.nvim',
    event = 'BufRead',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = {
      keymaps = {
        toggle = 'gB',
      },
    },
  },
}
