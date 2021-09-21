-- Copied form:
-- https://github.com/hoob3rt/lualine.nvim/blob/master/lua/lualine/components/diff.lua
local utils = require 'lualine.utils.utils'
local highlight = require 'lualine.highlight'

local SignifyDiff = require('lualine.component'):new()

SignifyDiff.default_colors = {
  added = '#f0e130',
  removed = '#90ee90',
  modified = '#ff0038'
}

SignifyDiff.new = function(self, options, child)
  local new_instance = self._parent:new(options, child or SignifyDiff)
  local default_symbols = {added = '+', modified = '!', removed = '-'}
  new_instance.options.symbols =
    vim.tbl_extend('force', default_symbols, new_instance.options.symbols or {})
  if new_instance.options.colored == nil then
    new_instance.options.colored = true
  end
  if not new_instance.options.color_added then
    new_instance.options.color_added =
      utils.extract_highlight_colors('DiffAdd', 'fg')
      or SignifyDiff.default_colors.added
  end
  if not new_instance.options.color_modified then
    new_instance.options.color_modified =
      utils.extract_highlight_colors('DiffChange', 'fg')
      or SignifyDiff.default_colors.modified
  end
  if not new_instance.options.color_removed then
    new_instance.options.color_removed =
      utils.extract_highlight_colors('DiffDelete', 'fg')
      or SignifyDiff.default_colors.removed
  end

  if new_instance.options.colored then
    new_instance.highlights = {
      added = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_added}, 'diff_added',
          new_instance.options),
      modified = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_modified}, 'diff_modified',
          new_instance.options),
      removed = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_removed}, 'diff_removed',
          new_instance.options)
    }
  end

  return new_instance
end

SignifyDiff.update_status = function(self)

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
      table.insert(result, self.options.symbols[name] .. SignifyDiff.diff[i])
    end
    ::continue::
  end

  if #result > 0 then
    return table.concat(result, ' ')
  else
    return ''
  end
end

return SignifyDiff
