local v = require('vimp')

local M = {}

M.setup = function()
  M.mapping()
end

M.mapping = function()
  -- Curl Runner
  v.nnoremap({'silent'}, '<leader>p', function ()
    local path = vim.fn.expand('%:p:h')
    if string.find(path, '/notes') then
      vim.cmd('lua require("telescope.builtin").live_grep({ cwd="~/notes" })')
    else
      vim.cmd('tabnew ~/notes/curl.sh')
    end
  end)

  v.vmap({'silent'}, '<CR>', ':QuickRun<CR><C-w>l')
  v.vmap({'silent'}, 'rr', ':QuickRun<CR>')
end

return M
