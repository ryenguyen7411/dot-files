local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  local notes = '~/notes'
  local curl = notes .. '/curl.sh'
  local output = notes .. '/output/output.json'

  local visual = '{V}'

  local add_quotes = ':s/\\v "(.*)"/ \'"\'"\\1"\'"\'/ge<CR>gv' .. ':s/\\v--data-raw \'(.*)\'/--data-raw "\'"\'\\1\'"\'"/ge<CR>gv'
  local add_echo = ':s/\\vcurl/echo curl/g<CR>'
  local quickrun = ':QuickRun -outputter file:name=' .. output .. ':append=0<CR>'
  local show_formatted_output = ':vs ' .. output .. '<CR>gfgg|:w<CR>'

  -- 1. QuickRun save to output, 2. vsplit output file, 3. format then save
  vim.keymap.set('n', ']\\', visual .. add_quotes .. add_echo .. ':noh<CR>' .. visual .. quickrun .. 'ju' .. show_formatted_output, { silent = true })
  vim.keymap.set('n', '\\', quickrun .. 'j' .. show_formatted_output, { silent = true })
end

return M
