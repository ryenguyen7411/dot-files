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

cmd [[
augroup Packer
  autocmd!
  autocmd BufWritePost init.lua luafile %
  autocmd BufWritePost init.lua PackerCompile
augroup end
]]

cmd('au VimEnter * cd %:p:h')
cmd('au TextYankPost * lua vim.highlight.on_yank {on_visual = false}')

cmd('au VimEnter * match TODO /\\s\\+$/')
cmd('au InsertLeave * match TODO /\\s\\+$/')
cmd('au InsertEnter * match NONE /\\s\\+$/')

cmd('au BufEnter *.hbs set filetype=html')
cmd('au BufEnter *.cshtml set filetype=html')
