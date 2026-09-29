--- Shared Snacks picker chrome (vscode layout + input keys) for fd/rg and fff backends.
local M = {}

M.vscode_chrome = function()
  return {
    layout = { preset = 'vscode' },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
          ['<C-f>'] = { 'toggle_focus', mode = { 'n', 'i' } },
        },
      },
      list = {
        keys = {
          ['<C-f>'] = 'toggle_focus',
        },
      },
    },
  }
end

M.snacks_files = function()
  return vim.tbl_deep_extend('force', M.vscode_chrome(), {
    hidden = true,
    ignored = true,
    args = {
      '-FHIL',
      '--type=f',
      '--color=never',
      '--strip-cwd-prefix',
      '--no-ignore',
      '--ignore-file',
      vim.fn.expand '~/.config/fd/.fdignore',
    },
    filter = { cwd = true },
    formatters = {
      file = {
        filename_first = true,
        truncate = 100,
      },
    },
  })
end

M.snacks_grep = function()
  return vim.tbl_deep_extend('force', M.vscode_chrome(), {
    hidden = true,
    ignored = true,
    args = {
      '-FHLSn.',
      '--color=never',
      '--column',
      '--no-heading',
      '--sort-files',
      '--trim',
      '--no-ignore',
      '--ignore-file',
      vim.fn.expand '~/.config/rg/.rgignore',
    },
    formatters = {
      file = {
        filename_first = true,
        truncate = 40,
      },
    },
  })
end

M.fff_files = function()
  return vim.tbl_deep_extend('force', M.vscode_chrome(), {
    formatters = {
      file = {
        filename_first = true,
        truncate = 100,
      },
    },
  })
end

M.fff_grep = function()
  return vim.tbl_deep_extend('force', M.vscode_chrome(), {
    formatters = {
      file = {
        filename_first = true,
        truncate = 40,
      },
    },
  })
end

return M
