local cmd = vim.cmd
local g = vim.g
local o = vim.o

function augroup(name, autocmds)
  cmd('augroup ' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
      cmd(autocmd)
  end
  cmd('augroup END')
end

augroup('PackerAutoCompile', {
  'autocmd BufWritePost init.lua luafile %',
  'autocmd BufWritePost init.lua PackerCompile',
})

cmd('au VimEnter * cd %:p:h')
cmd('au TextYankPost * lua vim.highlight.on_yank {on_visual = false}')

augroup('HighlightExtraWhitespace', {
  'highlight ExtraWhitespace guibg=#ffc777',
  'au VimEnter * match ExtraWhitespace /\\s\\+$/',
  'au InsertLeave * match ExtraWhitespace /\\s\\+$/',
  'au InsertEnter * match NONE /\\s\\+$/',
})

cmd('au BufEnter *.hbs set filetype=html')
cmd('au BufEnter *.cshtml set filetype=html')
