local g = vim.g
local o = vim.o

vim.api.nvim_set_hl(0, 'ExtraWhitespace', { bg = '#ffc777' })
local function set_whitespace_match(pattern)
  local excluded_filetypes = {
    '',
    'noice',
    'snacks_dashboard',
  }

  local current_ft = vim.bo.filetype
  vim.fn.clearmatches()

  for _, ft in ipairs(excluded_filetypes) do
    if current_ft == ft then
      return
    end
  end
  if pattern ~= 'NONE' then
    vim.fn.matchadd('ExtraWhitespace', pattern)
  end
end

local whitespace_group = vim.api.nvim_create_augroup('HighlightExtraWhitespace', { clear = true })

vim.api.nvim_create_autocmd({ 'VimEnter', 'BufWinEnter' }, {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    set_whitespace_match '\\s\\+$'
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    set_whitespace_match '\\s\\+$'
  end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  group = whitespace_group,
  pattern = '*',
  callback = function()
    set_whitespace_match 'NONE'
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
    vim.highlight.on_yank {}
  end,
})

-- Set filetype=html for specific extensions
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.hbs', '*.cshtml' },
  callback = function()
    vim.bo.filetype = 'html'
  end,
})

-- Keep cursor position after yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    if vim.v.event.operator == 'y' and vim.b.cursorPreYank then
      vim.api.nvim_win_set_cursor(0, vim.b.cursorPreYank)
      vim.b.cursor_pre_yank = nil
    end
  end,
})
