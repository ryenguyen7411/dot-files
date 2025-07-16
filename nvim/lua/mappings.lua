-- ============================================================================
-- NAVIGATION
-- ============================================================================

-- Better j/k navigation for wrapped lines
vim.keymap.set('n', 'j', "(v:count ? 'j' : 'gj')", { expr = true })
vim.keymap.set('n', 'k', "(v:count ? 'k' : 'gk')", { expr = true })

-- Enhanced scrolling
vim.keymap.set('n', '<C-d>', '10<C-d>', { silent = true })
vim.keymap.set('n', '<C-u>', '10<C-u>', { silent = true })
vim.keymap.set({ 'n', 'x' }, '<C-j>', '6gj', { silent = true })
vim.keymap.set({ 'n', 'x' }, '<C-k>', '6gk', { silent = true })

-- Center cursor after search/jump
vim.keymap.set('n', '#', '#zz', { silent = true })
vim.keymap.set('n', '*', '*zz', { silent = true })
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })
vim.keymap.set('n', 'G', 'Gzz', { silent = true })
vim.keymap.set({ 'n', 'x' }, '{', '{zz', { silent = true })
vim.keymap.set({ 'n', 'x' }, '}', '}zz', { silent = true })

-- Better line end navigation (exclude trailing whitespace)
vim.keymap.set({ 'n', 'x' }, '$', 'g_', { silent = true })

-- Buffer navigation
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { silent = true })

-- ============================================================================
-- EDITING & TEXT MANIPULATION
-- ============================================================================

-- Map redo to U (undo is u)
vim.keymap.set('n', 'U', '<C-R>', { silent = true })

-- Clipboard integration
vim.keymap.set('n', 'YY', 'gg"*yG', { silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, 'y', function()
  vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
  return '"*y'
end, { expr = true, silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, 'd', '"*d', { silent = true, noremap = true })
vim.keymap.set({ 'n', 'x' }, 'x', '"*x', { silent = true, noremap = true })
vim.keymap.set('x', 'p', '"_dP', { silent = true, noremap = true })

-- Quick save/quit
vim.keymap.set('n', '<leader>w', ':w!<CR>', { silent = true })
vim.keymap.set('n', '<leader>ư', ':w!<CR>', { silent = true })
vim.keymap.set('n', '<leader>qq', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('i', ':w', '<Esc>:w<CR>', { silent = true })

-- Search within visual selection
vim.keymap.set('x', '/', '<Esc>/\\%V')

-- Code folding
vim.keymap.set('v', 'zf', 'zfzz', { silent = true })
vim.keymap.set('v', 'zo', 'zozz', { silent = true })
vim.keymap.set('n', 'zo', 'zozz', { silent = true })

-- ============================================================================
-- WINDOW & SPLIT MANAGEMENT
-- ============================================================================

-- Window navigation
vim.keymap.set('n', 'zh', '<C-w>h', { silent = true })
vim.keymap.set('n', 'zl', '<C-w>l', { silent = true })
vim.keymap.set('n', 'zj', '<C-w>j', { silent = true })
vim.keymap.set('n', 'zk', '<C-w>k', { silent = true })

-- Window resizing
vim.keymap.set('n', 'z<BS>', '<Space>15<C-w><', { silent = true })
vim.keymap.set('n', 'z<CR>', '<Space>15<C-w>>', { silent = true })
vim.keymap.set('n', 'zb', '<C-w>=', { silent = true })

-- Split creation
vim.keymap.set('n', 'z|', ':vsplit<CR>', { silent = true })
vim.keymap.set('n', 'z-', ':split<CR>', { silent = true })

-- Close window with terminal confirmation
local function close_window()
  local would_close_vim = function()
    local win_count = vim.fn.winnr '$'
    local has_qf = vim.fn.getqflist({ winid = 0 }).winid ~= 0
    local has_loclist = vim.fn.getloclist(0, { winid = 0 }).winid ~= 0
    local has_float = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        has_float = true
        break
      end
    end
    local tab_count = vim.fn.tabpagenr '$'
    return win_count == 1 and not has_qf and not has_loclist and not has_float and tab_count == 1
  end

  local has_terminal = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
      has_terminal = true
      break
    end
  end

  if has_terminal and would_close_vim() then
    local choice = vim.fn.confirm('Terminal buffer(s) open:', 'Close &Window\n&Cancel', 2)
    if choice == 1 then
      vim.cmd 'quit'
    end
  else
    vim.cmd 'quit'
  end
end
vim.keymap.set('n', 'zm', close_window, { silent = true })

-- ============================================================================
-- BUFFER MANAGEMENT
-- ============================================================================

-- Close all buffers with terminal confirmation
local function close_all_buffers()
  local has_terminal = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
      has_terminal = true
      break
    end
  end

  if has_terminal then
    local choice = vim.fn.confirm('Terminal buffer(s) open:', 'Close except termina&Ls\nClose &All\n&Cancel', 1)
    if choice == 1 then
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype ~= 'terminal' then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    elseif choice == 2 then
      vim.cmd ':%bdelete!'
    end
  else
    vim.cmd ':%bdelete!'
  end
end
vim.keymap.set('n', '0\\', close_all_buffers, { silent = true })

-- ============================================================================
-- MISCELLANEOUS
-- ============================================================================

vim.keymap.set('n', '<leader>n', ':enew<CR>', { silent = true })
vim.keymap.set('n', 'gT', ':Inspect<CR>', { silent = true })
vim.keymap.set('n', '<Esc>', ':nohl<CR>:ccl<CR><C-l>:echo<CR>', { silent = true })
vim.keymap.set('n', 'gb', "<cmd>echo expand('%:p')<CR>", { silent = true })
vim.keymap.set('n', '00', 'ggdG:w<CR><C-w>q', { silent = true, noremap = true })

-- ============================================================================
-- DEBUG & PROFILING
-- ============================================================================

vim.keymap.set(
  'n',
  '<leader>vp',
  ':profile start ~/profile.nvim.log<CR>:profile func *<CR>:profile file *<CR>',
  { silent = true }
)
vim.keymap.set('n', '<leader>vs', ':profile pause<CR>:e! ~/profile.nvim.log<CR>', { silent = true })

-- ============================================================================
-- REGISTER PRESETS
-- ============================================================================

vim.fn.setreg('h', 'ysa"}ysi})icx\27')
