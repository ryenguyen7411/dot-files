local v = require('vimp')
local lspconfig = require('lspconfig')

local M = {}

M.setup = function()
  vim.diagnostic.config({
    float = {
      source = 'always',
      border = 'rounded',
      focus = false,
    },
    severity_sort = true,
    virtual_text = false,
  })
  vim.cmd('autocmd CursorHold * lua vim.diagnostic.open_float()')

  lspconfig.tsserver.setup({
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false

      local ts_utils = require('nvim-lsp-ts-utils')
      ts_utils.setup({})
      ts_utils.setup_client(client)

      M.attach(client, bufnr)
    end,
    handlers = {['textDocument/publishDiagnostics'] = function(...) end}
  })
  lspconfig.eslint.setup({
    on_attach = function(client)
      vim.cmd([[
      augroup LspEslint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> EslintFixAll
      augroup END
      ]])
    end,
    settings = {
      codeActionOnSave = {
        enable = true,
        mode = "all"
      },
    },
  })
  lspconfig.stylelint_lsp.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[
      augroup LspStylelint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      augroup END
      ]])
      M.attach(client, bufnr)
    end,
    settings = {
      stylelintplus = {
        autoFixOnFormat = true,
        autoFixOnSave = true,
      },
    },
  })
  lspconfig.dartls.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[
      augroup FlutterFormat
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      augroup END
      ]])
      M.attach(client, bufnr)
    end,
  })

  M.mapping()
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gn', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gm', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g.', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
end

M.mapping = function()
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>o', '<cmd>TSLspOrganize<CR>', opts)
  v.nmap({'silent'}, '<leader>o', '<cmd>TSLspOrganize<CR>')
  v.nmap({'silent'}, '<leader>u', '<cmd>LspStop<CR>|<cmd>LspStart<CR>|<cmd>LspInfo<CR>')
end

return M
