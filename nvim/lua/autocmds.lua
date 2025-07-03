-- Highlight trailing whitespace except in excluded filetypes
local excluded_filetypes = { '', 'noice', 'snacks_dashboard' }
local function should_highlight_whitespace()
  local ft = vim.bo.filetype
  for _, ex in ipairs(excluded_filetypes) do
    if ft == ex then
      return false
    end
  end
  return true
end

local function highlight_trailing_whitespace(enable)
  vim.fn.clearmatches()
  if enable and should_highlight_whitespace() then
    vim.fn.matchadd('ExtraWhitespace', '\\s\\+$')
  end
end

vim.api.nvim_set_hl(0, 'ExtraWhitespace', { bg = '#ffc777' })
local ws_group = vim.api.nvim_create_augroup('HighlightExtraWhitespace', { clear = true })

vim.api.nvim_create_autocmd({ 'VimEnter', 'BufWinEnter', 'InsertLeave' }, {
  group = ws_group,
  pattern = '*',
  callback = function()
    highlight_trailing_whitespace(true)
  end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  group = ws_group,
  pattern = '*',
  callback = function()
    highlight_trailing_whitespace(false)
  end,
})

-- Change directory to current file's parent directory on VimEnter
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    vim.cmd 'cd %:p:h'
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Set filetype=html for specific extensions
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.hbs', '*.cshtml' },
  callback = function()
    vim.bo.filetype = 'html'
  end,
})

-- Keep cursor position after yank (if previously saved)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator == 'y' and vim.b.cursorPreYank then
      vim.api.nvim_win_set_cursor(0, vim.b.cursorPreYank)
      vim.b.cursorPreYank = nil
    end
  end,
})

-- Go: Organize imports and format before save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format { async = false }
  end,
})
