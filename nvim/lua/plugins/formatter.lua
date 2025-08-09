local M = {}

M.setup_formatter = function()
  require('conform').setup {
    formatters_by_ft = {
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      vue = { 'prettierd', 'prettier', stop_after_first = true },
      astro = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
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
        require('conform').format { async = true, timeout_ms = 10000, lsp_fallback = false }
        vim.cmd 'silent write'
      end,
      desc = 'Format + Save buffer',
    },
  },
  config = function()
    M.setup_formatter()
  end,
}
