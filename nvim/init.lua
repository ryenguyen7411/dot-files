vim.g.mapleader = ' '

local ensure_lazy = function()
  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)
end

local lazy_bootstrap = ensure_lazy()

require('lazy').setup 'plugins'

require 'settings' -- lua/settings.lua
require 'autocmds' -- lua/autocmds.lua
require 'mappings' -- lua/mappings.lua
