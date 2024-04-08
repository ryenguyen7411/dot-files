local M = {}

function find_files()
  local notes = '~/notes'

  local path = vim.fn.expand '%:p:h'
  if string.find(path, '/notes') then
    vim.cmd('lua require("telescope.builtin").find_files({ cwd = "' .. notes .. '", prompt_title = "Find notes" })')
  else
    vim.cmd 'lua require("telescope.builtin").find_files()'
  end
end
function live_grep()
  local notes = '~/notes'

  local path = vim.fn.expand '%:p:h'
  if string.find(path, '/notes') then
    vim.cmd('lua require("telescope.builtin").live_grep({ cwd = "' .. notes .. '", prompt_title = "Search notes"})')
  else
    vim.cmd 'lua require("telescope.builtin").live_grep()'
  end
end
function select_curl()
  local notes = '~/notes'

  local path = vim.fn.expand '%:p:h'
  vim.cmd(
    'lua require("telescope.builtin").find_files({ cwd = "'
      .. notes
      .. '", default_text = ".md", prompt_title = "Select notes" })'
  )
end

M.setup = function()
  local actions = require 'telescope.actions'
  local fb_actions = require('telescope').extensions.file_browser.actions
  local previewers = require 'telescope.previewers'

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
        os.getenv 'HOME' .. '/.config/rg/.rgignore',
      },
      file_ignore_patterns = {
        -- '.git/',
      },
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

            vim.fn.jobstart({ 'viu', filepath }, { on_stdout = send_output, stdout_buffered = true })
          else
            require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
          end
        end,
      },
      mappings = {
        i = {
          ['<esc>'] = actions.close,
        },
      },
    },
    pickers = {
      buffers = {
        show_all_buffers = true,
        sort_mru = true,
        mappings = {
          i = {
            ['<c-d>'] = 'delete_buffer',
          },
          n = {
            ['<c-d>'] = 'delete_buffer',
          },
        },
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
          os.getenv 'HOME' .. '/.config/fd/.fdignore',
        },
      },
    },
    extensions = {
      project = {
        hidden_files = true,
        -- sync_with_nvim_tree = true
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
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
        },
        hidden = true,
        respect_gitignore = false,
        dir_icon = '',
        grouped = true,
        select_buffer = true,
        display_stat = false,
      },
    },
  }
  require('telescope').load_extension 'fzf'
  require('telescope').load_extension 'file_browser'
  require('telescope').load_extension 'project'

  M.mapping()
end

M.mapping = function()
  vim.keymap.set('n', '<leader>;', '<cmd>lua find_files()<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>j', '<cmd>lua live_grep()<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<leader>p', '<cmd>lua select_curl()<CR>', { noremap = true, silent = true })

  vim.keymap.set(
    'n',
    '<leader>l',
    '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<CR>',
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>k',
    '<cmd>lua require("telescope").extensions.file_browser.file_browser({ cwd = vim.fn.expand("%:p:h") })<CR>',
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>b',
    '<cmd>lua require("telescope.builtin").buffers({ default_selection_index=2 })<CR>',
    { noremap = true, silent = true }
  )
  vim.keymap.set('n', "<leader>'", '<cmd>Telescope resume<CR>', { noremap = true, silent = true })
end

return M
