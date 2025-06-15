local M = {}
local virtual_lines_enabled = false

M.config = function()
  vim.lsp.config('ts_ls', {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  })

  local base_on_attach = vim.lsp.config.eslint.on_attach
  vim.lsp.config('eslint', {
    on_attach = function(client, bufnr)
      if not base_on_attach then
        return
      end

      base_on_attach(client, bufnr)
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        command = 'LspEslintFixAll',
      })
    end,
    settings = {
      codeActionOnSave = {
        enable = true,
        mode = 'all',
      },
    },
  })

  vim.lsp.config('gopls', {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  })

  vim.diagnostic.config {
    float = {
      source = 'always',
      border = 'rounded',
      focus = false,
    },
    severity_sort = true,
    virtual_text = false,
  }

  -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  --   border = 'single',
  -- })
  -- vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  --   border = 'single',
  -- })
  -- require('lspconfig.ui.windows').default_options = {
  --   border = 'single',
  -- }
end

M.start = function()
  vim.lsp.enable 'ts_ls'
  vim.lsp.enable 'eslint'
  vim.lsp.enable 'quick_lint_js'
  vim.lsp.enable 'html'
  vim.lsp.enable 'jsonls'
  vim.lsp.enable 'gopls'
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'K', function()
    vim.lsp.buf.hover { border = 'rounded', max_height = 25, max_width = 120 }
  end, opts)
  vim.keymap.set('n', 'gK', function()
    virtual_lines_enabled = not virtual_lines_enabled
    if virtual_lines_enabled then
      vim.diagnostic.config { virtual_lines = true }
    else
      vim.diagnostic.config { virtual_lines = false }
    end
  end, opts)
  vim.keymap.set('n', 'L', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
  end, opts)
  vim.keymap.set('n', 'B', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'go', function()
    vim.lsp.buf.code_action { context = { only = { 'source.addMissingImports.ts' } }, apply = true }
  end, opts)
end

return {
  'neovim/nvim-lspconfig',
  config = function()
    M.config()
    M.start()
  end,
}
