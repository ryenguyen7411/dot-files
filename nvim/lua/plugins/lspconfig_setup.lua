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
    root_dir = function(fname)
      if lspconfig.util.root_pattern('.vue-project')(fname) then
        return false
      else
        return lspconfig.util.root_pattern('package.json')(fname)
      end
    end,
    single_file_support = false,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  })
  lspconfig.eslint.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[ augroup LspEslint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> EslintFixAll
      augroup END ]])
      M.attach(client, bufnr)
    end,
    settings = {
      codeActionOnSave = {
        enable = true,
        mode = "all"
      },
    },
  })
  lspconfig.quick_lint_js.setup({})
  lspconfig.stylelint_lsp.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[ augroup LspStylelint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END ]])
      M.attach(client, bufnr)
    end,
    settings = {
      stylelintplus = {
        autoFixOnFormat = true,
        autoFixOnSave = true,
      },
    },
  })
  lspconfig.volar.setup{
    on_attach = function(client, bufnr)
      vim.cmd([[ augroup LspVolar
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END ]])
      M.attach(client, bufnr)
    end,
    root_dir = lspconfig.util.root_pattern('.vue-project'),
    single_file_support = false,
    filetypes = {'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}
  }

  lspconfig.html.setup {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
  lspconfig.jsonls.setup({
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  })
  lspconfig.dartls.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[
      augroup LspFlutter
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END
      ]])

      M.attach(client, bufnr)
    end,
  })
  lspconfig.vimls.setup{
    on_attach = function(client, bufnr)
      require("aerial").on_attach(client, bufnr)
      M.attach(client, bufnr)
    end,
  }
  lspconfig.intelephense.setup({
    on_attach = function(client, bufnr)
      vim.cmd([[
      augroup PhpLint
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
      augroup END
      ]])
      M.attach(client, bufnr)
    end,
  })

  require('lspconfig.ui.windows').default_options = {
    border = "single"
  }
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "single"
    }
  )

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = "single"
    }
  )

  vim.diagnostic.config{
    float={border="single"}
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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrev<CR>', {})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNext<CR>', {})
end

M.mapping = function()
  -- vim.api.nvim_set_keymap('n', '<leader>bu', ':LspStop<CR>:LspStart<CR>', { silent = true })
end

return M
