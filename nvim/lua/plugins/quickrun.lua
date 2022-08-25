local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  local notes = '~/notes'
  local curl = notes .. '/curl.sh'
  local output = notes .. '/output/output.json'

  local visual = '{V}'
  local add_quotes = ':s/\\v "(.*)"/ \'"\'"\\1"\'"\'/g<CR>'
  local add_echo = ':s/\\vcurl/echo curl/g<CR>'
  local quickrun = ':QuickRun -outputter file:name=' .. output .. ':append=0<CR>'
  local show_formatted_output = ':vs ' .. output .. '<CR>gfgg|:w<CR>'

  -- 1. QuickRun save to output, 2. vsplit output file, 3. format then save
  v.nmap({'silent'}, ']\\', visual .. add_quotes .. 'gv' .. add_echo .. ':noh<CR>\\')
  v.nmap({'silent'}, '\\', visual .. quickrun .. show_formatted_output)
end

return M
