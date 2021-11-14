local v = require('vimp')

local M = {}

M.setup = function()
  require('spectre').setup {
    find_engine = {
      ['rg'] = {
        cmd = "rg",
        args = {
          '--hidden',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case'
        },
      },
    },
    is_insert_mode = true,
  }

  M.mapping()
end

M.mapping = function()
  -- open plugin -> set smaller pane -> switch pane side
  v.nnoremap({'silent'}, '<leader>i', ':lua require("spectre").open()<CR><Space>60<C-w><<CR><C-w>r')
  v.vnoremap({'silent'}, '<leader>i', ':lua require("spectre").open_visual()<CR><CR><Space>60<C-w><<CR><C-w>r')
end

return M
