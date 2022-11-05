local v = require('vimp')

local M = {}

M.setup = function ()
  local actions = require("telescope.actions")
  local fb_actions = require "telescope".extensions.file_browser.actions
  local previewers = require('telescope.previewers')

  local preview_maker = function (filepath, bufnr, opts)
    local bad_files = function (filepath)
      local _bad = { 'metadata/.*%.json', 'html2pdf.bundle.min' } -- Put all filetypes that slow you down in this array
      for _, v in ipairs(_bad) do
        if filepath:match(v) then
          return false
        end
      end
      return true
    end

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
        '-FHLSn.',
        '--color=never',
        '--column',
        '--no-heading',
        '--sort-files',
        '--trim',
        '--no-ignore',
        '--ignore-file',
        os.getenv("HOME") .. '/.config/rg/.rgignore',
      },
      file_ignore_patterns = {
        '.git/',
      },
      buffer_previewer_maker = preview_maker,
      preview = {
        mime_hook = function(filepath, bufnr, opts)
          local split_path = vim.split(filepath:lower(), '.', { plain = true })
          local ext = split_path[#split_path]

          if vim.tbl_contains({ 'png', 'jpg', 'jpeg' }, ext) then
            local term = vim.api.nvim_open_term(bufnr, {})
            local function send_output(_, data, _)
              for _, d in ipairs(data) do
                vim.api.nvim_chan_send(term, d .. '\r\n')
              end
            end

            vim.fn.jobstart(
              { 'catimg', '-w 150', filepath },
              { on_stdout = send_output, stdout_buffered = true }
            )
          else
            require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
          end
        end
      },
      mappings = {
        i = {
          ["<esc>"] = actions.close,
        },
      },
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
        find_command = {
          'fd',
          '-FHIL',
          '--type=f',
          '--color=never',
          '--strip-cwd-prefix',
          '--no-ignore',
          '--ignore-file',
          os.getenv("HOME") .. '/.config/fd/.fdignore',
        },
      },
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
      file_browser = {
        mappings = {
          ['i'] = {
            ['<C-e>'] = fb_actions.create,
            ['<C-r>'] = fb_actions.rename,
            ['<C-p>'] = fb_actions.move,
            ['<C-y>'] = fb_actions.copy,
            ['<C-d>'] = fb_actions.remove,
          },
        }
      }
    }
  }
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('file_browser')
  require('telescope').load_extension('aerial')
  -- require('telescope').load_extension('live_grep_args')

  M.mapping()
end

M.mapping = function()
  local notes = '~/notes'

  v.nnoremap({'silent'}, '<leader>;', function ()
    local path = vim.fn.expand('%:p:h')
    if string.find(path, '/notes') then
      vim.cmd('lua require("telescope.builtin").find_files({ cwd = "' .. notes .. '", prompt_title = "Find curl" })')
    else
      vim.cmd('lua require("telescope.builtin").find_files()')
      -- vim.cmd('Easypick find_files')
    end
  end)
  v.nnoremap({'silent'}, '<leader>j', function ()
    local path = vim.fn.expand('%:p:h')
    if string.find(path, '/notes') then
      vim.cmd('lua require("telescope.builtin").live_grep({ cwd = "' .. notes .. '", prompt_title = "Search curl"})')
    else
      vim.cmd('lua require("telescope.builtin").live_grep()')
    end
  end)
  v.nnoremap({'silent'}, '<leader>p', function ()
    local path = vim.fn.expand('%:p:h')
    vim.cmd('lua require("telescope.builtin").find_files({ cwd = "' .. notes .. '", default_text = ".sh", prompt_title = "Select curl" })')
  end)

  v.nmap({'silent'}, '<leader>l', '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<cr>')
  v.nmap({'silent'}, '<leader>k', '<cmd>lua require("telescope").extensions.file_browser.file_browser({ cwd = vim.fn.expand("%:p:h"), hidden=true, dir_icon="", respect_gitignore=false, grouped=true })<cr>')
  v.nmap({'silent'}, '<leader>b', '<cmd>lua require("telescope.builtin").buffers({ default_selection_index=2 })<cr>')
  v.nmap({'silent'}, '<leader>\'', '<cmd>Telescope resume<cr>')
  v.nmap({'silent'}, '<leader>a', '<cmd>Telescope aerial<CR>')
end

return M

