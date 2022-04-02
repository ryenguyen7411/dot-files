local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  local notes = '~/notes'
  local curl = notes .. '/curl.sh'
  local output = notes .. '/output.json'

  -- Curl Runner
  v.nnoremap({'silent'}, '<leader>p', function ()
    local path = vim.fn.expand('%:p:h')
    if string.find(path, '/notes') then
      vim.cmd('lua require("telescope.builtin").live_grep({ cwd="' .. notes .. '" })')
    else
      vim.cmd('tabnew ' .. curl)
    end
  end)

  -- 1. QuickRun save to output, 2. vsplit output file, 3. format then save
  v.vmap({'silent'}, '<CR>', ':QuickRun -outputter file:name=' .. output .. ':append=0<CR>|:vs ' .. output .. '<CR>|gfgg|:w<CR>')
end

return M
