local M = {}

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
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      'gcF',
      function()
        vim.lsp.buf.format()
        vim.cmd 'silent write'
      end,
      desc = 'Format + Save buffer',
    },
  },
  config = function()
    M.setup_formatter()
  end,
}
