local M = {}

M.js_formatter = function(bufnr)
  if vim.fs.root(bufnr, { '.oxfmtrc.json' }) then
    return { 'oxfmt' }
  end
  if vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc', '.biome.json', '.biome.jsonc' }) then
    return { 'biome' }
  end
  return { 'prettierd', 'prettier', stop_after_first = true }
end

M.setup_formatter = function()
  require('conform').setup {
    formatters_by_ft = {
      javascript = M.js_formatter,
      javascriptreact = M.js_formatter,
      typescript = M.js_formatter,
      typescriptreact = M.js_formatter,
      vue = M.js_formatter,
      astro = M.js_formatter,
      css = M.js_formatter,
      html = M.js_formatter,
      json = M.js_formatter,
      jsonc = M.js_formatter,
      graphql = M.js_formatter,
      lua = { 'stylua' },
    },
    formatters = {
      oxfmt = {
        command = require('conform.util').from_node_modules 'oxfmt',
        args = { '--stdin-filepath', '$FILENAME' },
        stdin = true,
      },
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
