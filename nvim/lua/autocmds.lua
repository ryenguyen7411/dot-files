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

augroup(
  'vimrc-sync-fromstart',
  { 'au BufEnter * :syntax sync maxlines=200' }
)
-- augroup('au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif')

cmd('au TextYankPost * lua vim.highlight.on_yank {on_visual = false}')
cmd('au BufRead,BufNewFile *.hbs set filetype=html')
cmd('au FileType scss setl iskeyword+=@-@')
cmd('au FileType javascriptreact setl commentstring={/*\\ %s\\ */}')

cmd('au VimEnter * cd %:p:h')
