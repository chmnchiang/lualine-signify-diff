-- Copied form:
-- https://github.com/hoob3rt/lualine.nvim/blob/master/lua/lualine/components/diff.lua
local utils = require 'lualine.utils.utils'
local highlight = require 'lualine.highlight'

local M = require('lualine.component'):extend()

local default_options = {
  colored = true,
  symbols = { added = '+', modified = '!', removed = '-' },
  diff_color = {
    added = {
      fg = utils.extract_highlight_colors('SignifySignAdd', 'fg') or '#90ee90',
    },
    modified = {
      fg = utils.extract_highlight_colors('SignifySignChange', 'fg') or '#f0e130',
    },
    removed = {
      fg = utils.extract_highlight_colors('SignifySignDelete', 'fg') or '#ff0038',
    },
  },
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  if self.options.colored then
    self.highlights = {
      added = highlight.create_component_highlight_group(
        self.options.diff_color.added,
        'diff_added',
        self.options
      ),
      modified = highlight.create_component_highlight_group(
        self.options.diff_color.modified,
        'diff_modified',
        self.options
      ),
      removed = highlight.create_component_highlight_group(
        self.options.diff_color.removed,
        'diff_removed',
        self.options
      ),
    }
  end
end

function M:update_status()
  local colors = {}
  if self.options.colored then
    for name, highlight_name in pairs(self.highlights) do
      colors[name] = highlight.component_format_highlight(highlight_name)
    end
  end

  local diff_fn = vim.fn['sy#repo#get_stats']
  if diff_fn == nil then
    return ''
  end
  local diff = diff_fn()
  local result = {}

  for i, name in ipairs {'added', 'modified', 'removed'} do
    if diff[i] <= 0 then goto continue end
    if self.options.colored then
      table.insert(result, colors[name] .. self.options.symbols[name] .. diff[i])
    else
      table.insert(result, self.options.symbols[name] .. M.diff[i])
    end
    ::continue::
  end

  if #result > 0 then
    return table.concat(result, ' ')
  else
    return ''
  end
end

return M
