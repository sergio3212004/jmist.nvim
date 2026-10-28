-- Floating window geometry and options.

local config = require "jmist.config"

local M = {}

--- @return table { width, height, opts }
M.main = function()
  local cfg = config.get()
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight

  local width = math.floor(editor_width * cfg.size.width / 100)
  local height = math.floor(editor_height * cfg.size.height / 100)

  width = math.min(math.max(width, cfg.min_width), math.max(20, editor_width - 4))
  height = math.min(math.max(height, cfg.min_height), math.max(10, editor_height - 4))

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((editor_height - height) / 2),
    col = math.floor((editor_width - width) / 2),
    style = "minimal",
    border = cfg.border,
    zindex = cfg.zindex,
  }

  if cfg.border and cfg.border ~= "none" then
    opts.title = " jmist "
    opts.title_pos = "left"
  end

  if cfg.winblend and cfg.winblend > 0 then
    opts.winblend = cfg.winblend
  end

  return { width = width, height = height, opts = opts }
end

return M
