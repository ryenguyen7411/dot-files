local M = {}

M.setup = function()
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      use_languagetree = true,
    },
    autotag = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
      max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
    },
    context_commentstring = {
      enable = true
    },
  }
end

return M
