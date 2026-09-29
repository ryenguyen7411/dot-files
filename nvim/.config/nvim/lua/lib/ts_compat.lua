-- Compatibility shim: nvim-treesitter (frozen `master` branch) registers its custom predicates and directives with
-- `all = false`, an option Neovim removed in 0.11+. Handlers now receive a list of nodes per capture instead of a
-- single node, which crashes `get_node_text` while resolving markdown injections. Re-register them here.
local M = {}

local function single_node(match, capture_id)
  local nodes = match[capture_id]
  if type(nodes) == 'table' then
    return nodes[#nodes]
  end
  return nodes
end

function M.setup()
  if vim.fn.has 'nvim-0.11' ~= 1 then
    return
  end

  local query = require 'vim.treesitter.query'
  -- Ensure the plugin registered its handlers first, so ours win with force = true
  pcall(require, 'nvim-treesitter.query_predicates')
  local opts = { force = true }

  local html_script_type_languages = {
    ['importmap'] = 'json',
    ['module'] = 'javascript',
    ['application/ecmascript'] = 'javascript',
    ['text/ecmascript'] = 'javascript',
  }
  local injection_language_aliases = {
    ex = 'elixir',
    pl = 'perl',
    sh = 'bash',
    uxn = 'uxntal',
    ts = 'typescript',
  }

  query.add_predicate('nth?', function(match, _, _, pred)
    local node = single_node(match, pred[2])
    local index = tonumber(pred[3])
    if node and index and node:parent() and node:parent():named_child_count() > index then
      return node:parent():named_child(index) == node
    end
    return false
  end, opts)

  query.add_predicate('is?', function(match, _, bufnr, pred)
    local node = single_node(match, pred[2])
    if not node then
      return true
    end
    local _, _, kind = require('nvim-treesitter.locals').find_definition(node, bufnr)
    return vim.tbl_contains({ unpack(pred, 3) }, kind)
  end, opts)

  query.add_predicate('kind-eq?', function(match, _, _, pred)
    local node = single_node(match, pred[2])
    if not node then
      return true
    end
    return vim.tbl_contains({ unpack(pred, 3) }, node:type())
  end, opts)

  query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
    local node = single_node(match, pred[2])
    if not node then
      return
    end
    local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
    local configured = html_script_type_languages[type_attr_value]
    if configured then
      metadata['injection.language'] = configured
    else
      local parts = vim.split(type_attr_value, '/', {})
      metadata['injection.language'] = parts[#parts]
    end
  end, opts)

  query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
    local node = single_node(match, pred[2])
    if not node then
      return
    end
    local alias = vim.treesitter.get_node_text(node, bufnr):lower()
    local filetype = vim.filetype.match { filename = 'a.' .. alias }
    metadata['injection.language'] = filetype or injection_language_aliases[alias] or alias
  end, opts)

  query.add_directive('downcase!', function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = single_node(match, id)
    if not node then
      return
    end
    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ''
    metadata[id] = metadata[id] or {}
    metadata[id].text = string.lower(text)
  end, opts)
end

return M
