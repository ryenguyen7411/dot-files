local lspconfig = require 'lspconfig'
local M = {}

M.setup = function()
  vim.diagnostic.config {
    float = {
      source = 'always',
      border = 'rounded',
      focus = false,
    },
    severity_sort = true,
    virtual_text = false,
  }

  -- vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
  --   require('ts-error-translator').translate_diagnostics(err, result, ctx, config)
  --   vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
  -- end

  lspconfig.tsserver.setup {
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

  M.mapping()
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  local inlay_hints_enabled = false
  function toggle_inlay_hints()
    inlay_hints_enabled = not inlay_hints_enabled
    vim.lsp.inlay_hint.enable(inlay_hints_enabled)
  end

  vim.keymap.set('n', 'L', '<cmd>lua toggle_inlay_hints()<CR>', opts)
  vim.keymap.set('n', 'F', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
  vim.keymap.set('n', 'gB', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
end

M.mapping = function() end

return M
