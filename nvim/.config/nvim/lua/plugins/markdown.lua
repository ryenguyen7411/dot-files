local M = {}

--- Converted image (PNG) for the mermaid/math/image block under the cursor.
--- Waits for Snacks' conversion (mmdc, magick) when it is not cached yet.
---@param callback fun(file: string)
local function with_image_file_at_cursor(callback)
  Snacks.image.doc.at_cursor(function(src)
    if not src then
      return vim.notify('No image under the cursor', vim.log.levels.INFO)
    end
    local image = Snacks.image.image.new(src)
    vim.wait(15000, function()
      return image:ready() or image:failed()
    end, 50)
    if not image:ready() then
      return vim.notify('Image conversion failed or timed out', vim.log.levels.ERROR)
    end
    callback(image.file)
  end)
end

M.setup_image_keymaps = function(buf)
  -- Zoom: open the rendered diagram in the system viewer (Preview on macOS).
  -- Overrides the built-in `zi` (toggle folding) in markdown buffers only.
  vim.keymap.set('n', 'zi', function()
    with_image_file_at_cursor(function(file)
      vim.ui.open(file)
    end)
  end, { buffer = buf, desc = 'Open image/diagram in system viewer' })
end

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'mdc' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {
      file_types = { 'markdown', 'mdc' },
      code = {
        -- 'hide' conceals the closing fence line, which is where snacks.image anchors the rendered
        -- mermaid/math image. Virtual lines on a concealed line are hidden, so the image never shows.
        border = 'thin',
        -- snacks.image renders and conceals these blocks; skip the label/border/background decorations
        disable = { 'mermaid' },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'mdc' },
        callback = function(event)
          M.setup_image_keymaps(event.buf)
        end,
      })
    end,
  },
}
