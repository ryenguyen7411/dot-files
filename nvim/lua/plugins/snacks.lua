function noop() end

return {
  'ryenguyen7411/snacks.nvim',
  branch = 'develop',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      sections = {
        { section = 'header' },
        {
          pane = 2,
          section = 'terminal',
          cmd = 'colorscript -e square',
          height = 5,
          padding = 1,
        },
        { section = 'keys', gap = 1, padding = 1 },
        { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        {
          pane = 2,
          icon = ' ',
          title = 'Git Status',
          section = 'terminal',
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = 'git status --short --branch --renames',
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = 'startup' },
      },
    },
    explorer = { enable = true },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      stages = 'fade_in_slide_out',
      render = 'compact',
      background_colour = 'FloatShadow',
      timeout = 3000,
      top_down = false,
    },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
          layout = { preset = 'vscode' },
          args = { '--ignore-file', vim.fn.expand '~/.config/fd/.fdignore' },
          win = {
            input = {
              keys = {
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              },
            },
          },
        },
        grep = {
          hidden = true,
          ignored = true,
          layout = { preset = 'vscode' },
          args = { '--ignore-file', vim.fn.expand '~/.config/rg/.rgignore' },
          win = {
            input = {
              keys = {
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              },
            },
          },
        },
        projects = {
          finder = 'recent_projects',
          format = 'file',
          dev = { '~/dev', '~/projects' },
          confirm = 'load_session',
          patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'package.json', 'Makefile' },
          win = {
            preview = { minimal = true },
            input = {
              keys = {
                -- every action will always first change the cwd to the project
                ['<c-e>'] = { { 'cd', 'picker_explorer' }, mode = { 'n', 'i' } },
                ['<c-f>'] = { { 'cd', 'picker_files' }, mode = { 'n', 'i' } },
                ['<c-g>'] = { { 'cd', 'picker_grep' }, mode = { 'n', 'i' } },
                ['<c-r>'] = { { 'cd', 'picker_recent' }, mode = { 'n', 'i' } },
                ['<c-w>'] = { { 'cd' }, mode = { 'n', 'i' } },
              },
            },
          },
          -- dev = { '~/dev', '~/projects' },
          -- confirm = 'load_session',
          -- layout = { preset = 'vscode' },
          -- patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'package.json', 'Makefile' },
          -- win = {
          --   input = {
          --     keys = {
          --       ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
          --     },
          --   },
          -- },
        },
        smart = {
          hidden = true,
          ignored = true,
          layout = { preset = 'vscode' },
          args = { '--ignore-file', vim.fn.expand '~/.config/fd/.fdignore' },
          filter = { cwd = true },
          win = {
            input = {
              keys = {
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              },
            },
          },
        },
        buffers = {
          focus = 'list', -- focus on list to start with normal mode
          current = false, -- exclude current buffer
        },
        explorer = {
          hidden = true,
          ignored = false,
          layout = { preset = 'vscode' },
          matcher = { fuzzy = true },
          args = { '--ignore-file', vim.fn.expand '~/.config/fd/.fdignore' },
          win = {
            list = {
              keys = {
                ['<BS>'] = 'explorer_up',
                ['<CR>'] = 'confirm_and_close',
                ['o'] = 'confirm_and_close',
                ['l'] = 'confirm_and_refocus',
                ['a'] = 'explorer_add',
                ['d'] = 'explorer_del',
                ['r'] = 'explorer_rename',
                ['c'] = 'explorer_copy',
                ['m'] = 'explorer_move',
                ['y'] = { 'explorer_yank', mode = { 'n', 'x' } },
                ['p'] = 'explorer_paste',
                ['u'] = 'explorer_update',
                ['L'] = 'toggle_ignored',
                ['H'] = 'toggle_hidden',
                ['<leader>/'] = 'picker_grep',
                ['<c-t>'] = 'tcd', -- change directory
                ['<Esc>'] = { 'close', mode = { 'n', 'i' } },

                ['h'] = noop, -- close directory
                ['P'] = noop,
                ['<c-c>'] = noop,
                ['.'] = noop,
                ['Z'] = noop,
                [']g'] = noop,
                ['[g'] = noop,
                [']d'] = noop,
                ['[d'] = noop,
                [']w'] = noop,
                ['[w'] = noop,
                [']e'] = noop,
                ['[e'] = noop,
              },
            },
          },
        },
      },
    },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = {
      toggles = {
        dim = false,
      },
    },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  keys = {
    { 'zp', '<cmd>lua Snacks.zen()<CR>', desc = 'Toggle Zen Mode' },

    { '<leader>h', '<cmd>lua Snacks.picker.files()<CR>', desc = 'Find Files' },
    { '<leader>j', '<cmd>lua Snacks.picker.grep()<CR>', desc = 'Grep' },
    { '<leader>b', '<cmd>lua Snacks.picker.buffers()<CR>', desc = 'Buffers' },
    { '<leader>;', '<cmd>lua Snacks.picker.smart()<CR>', desc = 'Smart Find Files' },
    { '<leader>k', '<cmd>lua Snacks.explorer()<CR>', desc = 'File Explorer' },
    { "<leader>'", '<cmd>lua Snacks.picker.resume()<CR>', desc = 'Resume' },

    { '<leader>i', '<cmd>lua Snacks.picker.files({ cwd = "~/notes" })<CR>', desc = 'Find Notes' },
    -- { '<leader>l', '<cmd>lua Snacks.picker.projects()<CR>', desc = 'Projects' },

    -- stylua: ignore start
    -- Top Pickers & Explorer

    -- { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    -- { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    -- { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    -- -- find
    -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    -- { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    -- -- git
    -- { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    -- { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    -- { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
    -- { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    -- { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    -- { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
    -- { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
    -- -- Grep
    -- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    -- { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    -- { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    -- { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    -- -- search
    -- { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    -- { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    -- { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    -- { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    -- { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    -- { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    -- { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    -- { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    -- { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    -- { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    -- { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    -- { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    -- { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    -- { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    -- { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    -- { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    -- { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    -- { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    -- { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
    -- { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    -- -- LSP
    -- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    -- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    -- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    -- { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    -- { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    -- -- Other
    -- { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    -- { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    -- { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    -- { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    -- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    -- { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    -- { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    -- { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    -- { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
    -- { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
    -- { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    -- { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    -- stylua: ignore
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle
          .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
          :map '<leader>uc'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
        Snacks.toggle.inlay_hints():map '<leader>uh'
        Snacks.toggle.indent():map '<leader>ug'
        Snacks.toggle.dim():map '<leader>uD'
      end,
    })
  end,
}
