vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath }
  vim.fn.system { 'git', '-C', lazypath, 'checkout', 'tags/stable' } -- last stable release
end
vim.opt.rtp:prepend(lazypath)

-- require('lazy').setup 'plugins'
require('lazy').setup {
  spec = {
    { import = 'plugins' },
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        '2html_plugin',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'matchit',
        'tar',
        'tarPlugin',
        'rplugin',
        'rrhelper',
        'spellfile_plugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
      },
    },
  },
}
require 'settings' -- lua/settings.lua
require 'autocmds' -- lua/autocmds.lua
require 'mappings' -- lua/mappings.lua
