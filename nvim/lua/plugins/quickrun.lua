local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  local notes = '~/notes'
  local curl = notes .. '/curl.sh'
  local output = notes .. '/output/output.json'

  -- Curl Runner
  v.nnoremap({'silent'}, '<leader>p', function ()
    local path = vim.fn.expand('%:p:h')
    if string.find(path, '/notes') then
      vim.cmd('lua require("telescope.builtin").live_grep({ cwd = "' .. notes .. '", default_text = vim.fn.getline(".") })')
    else
      vim.cmd('tabnew ' .. curl)
    end
  end)

  -- 1. QuickRun save to output, 2. vsplit output file, 3. format then save
  v.nmap({'silent'}, '\\', '{V}|:QuickRun -outputter file:name=' .. output .. ':append=0<CR>|:vs ' .. output .. '<CR>gfgg|:w<CR>')
  v.nmap({'silent'}, ']\\', '{V}|:QuickRun -outputter file:name=' .. output .. ':append=0<CR>|:vs ' .. output .. '<CR>:w<CR>')
end

return M
