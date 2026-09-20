--- TypeScript 7+ native compiler LSP (`tsc --lsp`).
--- Replaces preview `tsgo` from `@typescript/native-preview`.
---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = 'tsc'
    if config and config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin/tsc')
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json' },
  root_dir = function(bufnr, on_dir)
    if not vim.fs.root(bufnr, { '.oxfmtrc.json' }) then
      return
    end
    local root = vim.fs.root(bufnr, { 'tsconfig.json', 'package.json', '.git' })
    if root then
      on_dir(root)
    end
  end,
}
