local M = {}

M.setup = function()
  require('conform').setup {
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { { 'prettierd', 'prettier' } },
      javascriptreact = { { 'prettierd', 'prettier' } },
      typescript = { { 'prettierd', 'prettier' } },
      typescriptreact = { { 'prettierd', 'prettier' } },
      vue = { { 'prettierd', 'prettier' } },
      astro = { { 'prettierd', 'prettier' } },
      css = { { 'prettierd', 'prettier' } },
      html = { { 'prettierd', 'prettier' } },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  }
end

M.mapping = function() end

return M
