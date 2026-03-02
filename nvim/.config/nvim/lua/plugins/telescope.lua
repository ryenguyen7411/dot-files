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

local previews = {
  mime_hook = function(filepath, bufnr, opts)
    local is_image = function(filepath)
      local image_extensions = { 'png', 'jpg', 'jpeg' } -- Supported image formats
      local split_path = vim.split(filepath:lower(), '.', { plain = true })
      local extension = split_path[#split_path]
      return vim.tbl_contains(image_extensions, extension)
    end
    if is_image(filepath) then
      local term = vim.api.nvim_open_term(bufnr, {})
      local function send_output(_, data, _)
        for _, d in ipairs(data) do
          vim.api.nvim_chan_send(term, d .. '\r\n')
        end
      end
      vim.fn.jobstart({
        'catimg',
        filepath, -- Terminal image viewer command
      }, { on_stdout = send_output, stdout_buffered = true, pty = true })
    else
      require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
    end
  end,
}

M.mapping = function()
  -- vim.keymap.set('n', '<leader>;', '<cmd>lua find_files()<CR>', { noremap = true, silent = true })
  -- vim.keymap.set('n', '<leader>j', '<cmd>lua live_grep()<CR>', { noremap = true, silent = true })
  -- vim.keymap.set('n', '<leader>i', '<cmd>lua select_curl()<CR>', { noremap = true, silent = true })

  vim.keymap.set(
    'n',
    '<leader>l',
    '<cmd>lua require("telescope").extensions.project.project{ display_type="full" }<CR>',
    { noremap = true, silent = true }
  )
  -- vim.keymap.set(
  --   'n',
  --   '<leader>k',
  --   '<cmd>lua require("telescope").extensions.file_browser.file_browser({ cwd = vim.fn.expand("%:p:h") })<CR>',
  --   { noremap = true, silent = true }
  -- )
  -- vim.keymap.set(
  --   'n',
  --   '<leader>b',
  --   '<cmd>lua require("telescope.builtin").buffers({ default_selection_index=2 })<CR>',
  --   { noremap = true, silent = true }
  -- )
  -- vim.keymap.set('n', "<leader>'", '<cmd>Telescope resume<CR>', { noremap = true, silent = true })
end

-- Telescope commented out - fully replaced by snacks.nvim picker
-- Re-enable if something breaks in your workflow
--
-- return {
--   'nvim-telescope/' .. 'telescope.nvim',
--   event = 'VeryLazy',
--   dependencies = {
--     { 'nvim-telescope/' .. 'telescope-file-browser.nvim' },
--     { 'nvim-telescope/' .. 'telescope-fzf-native.nvim', build = 'make' },
--     { 'nvim-telescope/' .. 'telescope-project.nvim' },
--   },
--   config = function()
--     ...
--     M.mapping()
--   end,
-- }
return {}
