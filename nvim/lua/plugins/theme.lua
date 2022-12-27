local cmd = vim.cmd
local g = vim.g
local v = require('vimp')

local M = {}

function augroup(name, autocmds)
  cmd('augroup ' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    cmd('autocmd ' .. autocmd)
  end
  cmd('augroup END')
end

M.setup = function()
  M.tokyonight()
end

M.tokyonight = function()
  require("tokyonight").setup({
    transparent = true,
    on_colors = function(c)
      c.border = c.border_highlight
    end,
    on_highlights = function(hl, c)
      hl.rainbowcol1 = { fg = c.red1 }
      hl.rainbowcol2 = { fg = c.orange }
      hl.rainbowcol3 = { fg = '#e0d60d' }
      hl.rainbowcol4 = { fg = c.teal }
      hl.rainbowcol5 = { fg = '#326bc7' }
      hl.rainbowcol6 = { fg = c.blue1 }
      hl.rainbowcol7 = { fg = c.purple }

      hl['@variable'] = hl['@property']
      hl['@keyword.operator'] = hl['@keyword']
      hl['@constant.builtin'] = hl['@constant']
--       hl['@namespace'] = hl['@constructor']
--       hl['@string.regex'] = hl['@string']
    end,
  })

  g.lightline = {
    colorscheme = 'tokyonight'
  }

  local transparents = {
    "Normal",
    "NormalNC",
    "Comment",
    "Constant",
    "Special",
    "Identifier",
    "Statement",
    "PreProc",
    "Type",
    "Underlined",
    "Todo",
    "String",
    "Function",
    "Conditional",
    "Repeat",
    "Operator",
    "Structure",
    "LineNr",
    "NonText",
    "SignColumn",
    "CursorLineNr",
    "EndOfBuffer",

    'NormalFloat',
    'FloatBorder',
    'TelescopeNormal',
    'TelescopeBorder',
    'TelescopeMultiSelection',
  }

  for _, part in pairs(transparents) do
    cmd('au VimEnter * highlight ' .. part .. ' ctermbg=NONE guibg=NONE')
  end

  vim.cmd('colorscheme tokyonight')
end

-- M.colorye = function()
--   cmd('set termguicolors')

--   M.highlight_base()
--   M.highlight_treesitter()

--   M.highlight_rainbow()

--   g.colors_name = 'colorye'
--   cmd('colorscheme colorye')
-- end

-- M.color_palette = function()
--   return {
--     red = '#DA4167',
--     green = '#38b000',
--     yellow = '#ffee32',
--     blue = '#0466c8',
--     magenta = '#ff499e',
--     cyan = '#56cfe1',
--     orange = '#FFB100',
--     violet = '#c200fb',

--     black = '#000000',
--     gray1 = '#181818',
--     gray2 = '#252525',
--     gray3 = '#3b3b3b',
--     gray4 = '#5c5c5c',
--     gray5 = '#777777',
--     gray6 = '#b9b9b9',
--     gray7 = '#dedede',
--     white = '#ffffff',
--     none = 'NONE',

--     normal = {'nocombine,NONE', 'nocombine,NONE'}
--   }
-- end

-- M.highlight_base = function()
--   local c = M.color_palette()

--   M.color('Normal', c.none, c.gray6, c.normal)
--   M.color('NormalFloat', c.none, c.gray6, c.normal)
--   M.color('LineNr', c.none, c.gray4, c.normal)
--   M.color('Cursor', c.none, c.gray3, c.normal)
--   M.color('CursorColumn', c.gray3, c.none, c.normal)
--   M.color('CursorLine', c.gray3, c.none, c.normal)
--   M.color('CursorLineNr', c.gray3, c.gray5, c.normal)
-- end

-- M.highlight_treesitter = function()
--   local c = M.color_palette()

--   M.color('@string', c.none, c.orange, c.normal)
--   M.color('@constant', c.none, c.orange, c.normal)
--   M.color('@variable', c.none, c.orange, c.normal)

--   M.color('@keyword', c.none, c.magenta, c.normal)
--   M.color('@keyword.function', c.none, c.cyan, c.normal)
--   M.color('@function.call', c.none, c.cyan, c.normal)

--   M.color('@include', c.none, c.green, c.normal)
--   M.color('@constructor', c.none, c.green, c.normal)
-- end

-- M.highlight_rainbow = function()
--   local c = M.color_palette()

--   M.color('rainbowcol1', c.none, c.red, c.normal)
--   M.color('rainbowcol2', c.none, c.orange, c.normal)
--   M.color('rainbowcol3', c.none, c.yellow, c.normal)
--   M.color('rainbowcol4', c.none, c.green, c.normal)
--   M.color('rainbowcol5', c.none, c.blue, c.normal)
--   M.color('rainbowcol6', c.none, c.magenta, c.normal)
--   M.color('rainbowcol7', c.none, c.violet, c.normal)
-- end

-- M.color = function (group, bg, fg, attr)
--   cmd('highlight ' .. group .. ' ' ..
--     'guibg=' .. bg .. ' guifg=' .. fg .. ' ' ..
--     'gui=' .. attr[1] .. ' guisp=' .. attr[2])
-- end

-- M.color_link = function (from, to)
--   cmd('highlight! link ' .. from .. ' ' .. to)
-- end

return M
