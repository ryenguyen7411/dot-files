---@type vim.lsp.Config
return {
  cmd = { 'tsgo', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json' },
  root_dir = function(bufnr, on_dir)
    if not vim.fs.root(bufnr, { '.oxfmtrc.json' }) then return end
    local root = vim.fs.root(bufnr, { 'tsconfig.json', 'package.json', '.git' })
    if root then on_dir(root) end
  end,
}
