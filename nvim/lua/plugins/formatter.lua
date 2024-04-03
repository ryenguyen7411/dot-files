local M = {}

M.setup = function()
  require('conform').setup {
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      vue = { 'prettier' },
      astro = { 'prettier' },
      css = { 'prettier' },
      html = { 'prettier' },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  }
end

M.mapping = function() end

return M
