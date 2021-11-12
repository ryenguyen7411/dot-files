local M = {}

M.setup = function ()
  local previewers = require('telescope.previewers')
  local bad_files = function (filepath)
    local _bad = { 'metadata/.*%.json', 'html2pdf.bundle.min' } -- Put all filetypes that slow you down in this array
    for _, v in ipairs(_bad) do
      if filepath:match(v) then
        return false
      end
    end
    return true
  end

  local preview_maker = function (filepath, bufnr, opts)
    opts = opts or {}
    if opts.use_ft_detect == nil then opts.use_ft_detect = true end
    opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
  end

  -- Setup Telescope
  require('telescope').setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--hidden',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case'
      },
      file_ignore_patterns = {
        ".git/",
      },
      buffer_previewer_maker = preview_maker,
      disable_devicons = true
    },
    pickers = {
      buffers = {
        show_all_buffers = true,
        sort_mru = true,
        mappings = {
          i = {
            ["<c-d>"] = "delete_buffer",
          },
          n = {
            ["<c-d>"] = "delete_buffer",
          }
        }
      },
      find_files = {
        disable_devicons = true
      },
      file_browser = {
        disable_devicons = true
      },
      live_grep = {
        disable_devicons = true
      }
    },
    extensions = {
      project = {
        hidden_files = true
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
    }
  }
  require('telescope').load_extension('fzf')
end

return M
