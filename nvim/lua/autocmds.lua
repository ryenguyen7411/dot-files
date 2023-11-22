local g = vim.g
local o = vim.o

function augroup(name, autocmds)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
      vim.cmd(autocmd)
  end
  vim.cmd('augroup END')
end

vim.cmd('au VimEnter * cd %:p:h')
vim.cmd('au TextYankPost * lua vim.highlight.on_yank {on_visual = false}')

augroup('HighlightExtraWhitespace', {
  'highlight ExtraWhitespace guibg=#ffc777',
  'au VimEnter * match ExtraWhitespace /\\s\\+$/',
  'au InsertLeave * match ExtraWhitespace /\\s\\+$/',
  'au InsertEnter * match NONE /\\s\\+$/',
})

vim.cmd('au BufEnter *.hbs set filetype=html')
vim.cmd('au BufEnter *.cshtml set filetype=html')

-- -- disable syntax highlighting in big files
-- function DisableSyntaxTreesitter()
--   print("Big file, disabling syntax, treesitter and folding")
--   if vim.fn.exists(':TSToggle') then
--     vim.cmd('TSToggle highlight')
--     vim.cmd('TSToggle rainbow')
--   end

--   vim.cmd('syntax off')
-- end

-- vim.cmd('augroup BigFileDisable')
-- vim.cmd('autocmd!')
-- vim.cmd('autocmd BufReadPre,FileReadPre * if getfsize(expand("%")) > 1000 * 1024 | :lua DisableSyntaxTreesitter() | endif')
-- vim.cmd('augroup END')
