local M = {}
local virtual_lines_enabled = false

M.config = function()
  local ts_on_attach = function(client, bufnr)
    M.attach(client, bufnr)
  end

  vim.lsp.config('tsc', {
    on_attach = ts_on_attach,
  })

  vim.lsp.config('ts_ls', {
    on_attach = ts_on_attach,
    root_dir = function(bufnr, on_dir)
      -- TypeScript 7 native LSP (`tsc --lsp`) owns oxfmt projects; see lsp/tsc.lua
      if vim.fs.root(bufnr, { '.oxfmtrc.json' }) then
        return
      end
      local root = vim.fs.root(bufnr, { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' })
      if root then
        on_dir(root)
      end
    end,
  })

  vim.lsp.config('gopls', {
    on_attach = function(client, bufnr)
      M.attach(client, bufnr)
    end,
  })

  vim.diagnostic.config {
    float = {
      source = 'always',
      border = 'rounded',
      focus = false,
    },
    severity_sort = true,
    virtual_text = false,
  }

  -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  --   border = 'single',
  -- })
  -- vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  --   border = 'single',
  -- })
  -- require('lspconfig.ui.windows').default_options = {
  --   border = 'single',
  -- }
end

-- Run Node-based servers on fnm's default Node, not the one fnm switched to from a project's `.nvmrc`
-- (e.g. finops pins Node 10, which can't parse ts_ls / eslint / oxlint)
M.use_default_node = function(name)
  local fnm_dir = vim.env.FNM_DIR or vim.fs.normalize '~/.local/share/fnm'
  local node_bin = vim.fs.joinpath(fnm_dir, 'aliases/default/bin')
  if not vim.uv.fs_stat(node_bin) then
    return
  end
  local path = node_bin .. ':' .. vim.env.PATH

  local cmd = vim.lsp.config[name].cmd
  if type(cmd) ~= 'function' then
    vim.lsp.config(name, { cmd_env = { PATH = path } })
    return
  end
  -- Function cmds spawn without `cmd_env`, so swap PATH just for the (synchronous) spawn
  vim.lsp.config(name, {
    cmd = function(dispatchers, config)
      local saved = vim.env.PATH
      vim.env.PATH = path
      local ok, client = pcall(cmd, dispatchers, config)
      vim.env.PATH = saved
      if not ok then
        error(client)
      end
      return client
    end,
  })
end

M.start = function()
  for _, name in ipairs { 'ts_ls', 'tsc', 'eslint', 'html', 'jsonls', 'oxlint' } do
    M.use_default_node(name)
  end

  vim.lsp.enable 'ts_ls'
  vim.lsp.enable 'tsc'
  vim.lsp.enable 'eslint'
  vim.lsp.enable 'html'
  vim.lsp.enable 'jsonls'
  vim.lsp.enable 'gopls'
  vim.lsp.enable 'oxlint'
end

M.attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'K', function()
    vim.lsp.buf.hover { border = 'rounded', max_height = 25, max_width = 120 }
  end, opts)
  vim.keymap.set('n', 'gK', function()
    virtual_lines_enabled = not virtual_lines_enabled
    if virtual_lines_enabled then
      vim.diagnostic.config { virtual_lines = true }
    else
      vim.diagnostic.config { virtual_lines = false }
    end
  end, opts)
  vim.keymap.set('n', 'L', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
  end, opts)
  vim.keymap.set('n', 'B', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'go', function()
    vim.lsp.buf.code_action { context = { only = { 'source.addMissingImports.ts' } }, apply = true }
  end, opts)
end

return {
  'neovim/nvim-lspconfig',
  config = function()
    M.config()
    M.start()
  end,
}
