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
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      M.attach(client, bufnr)
    end,
    handlers = {['textDocument/publishDiagnostics'] = function(...) end}
  })
  lspconfig.eslint.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[
      augroup LspEslint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> EslintFixAll
      augroup END
      ]])

      M.attach(client, bufnr)
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
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
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
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END
      ]])

      M.attach(client, bufnr)
    end,
  })
  lspconfig.jsonls.setup({
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  })
  lspconfig.vimls.setup{
    on_attach = function(client, bufnr)
      require("aerial").on_attach(client, bufnr)
      M.attach(client, bufnr)
    end,
  }

  M.mapping()
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gn', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gm', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g.', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrev<CR>', {})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNext<CR>', {})
end

M.mapping = function()
  v.nmap({'silent'}, '<leader>u', '<cmd>LspStop<CR>|<cmd>LspStart<CR>|<cmd>LspInfo<CR>')
end

return M
