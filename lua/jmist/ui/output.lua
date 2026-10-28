-- Output view: build command header plus a scrollable log stream.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"
local util = require "jmist.util"

local M = {}

M.LIST_OFFSET = 2

local LEVELS = {
  info = { icon = icons.info, hl = "JmistMuted" },
  warn = { icon = icons.warning, hl = "JmistWarn" },
  error = { icon = icons.error, hl = "JmistError" },
  success = { icon = icons.check, hl = "JmistOk" },
  cmd = { icon = icons.chevron_right, hl = "JmistCommand" },
  dim = { icon = " ", hl = "JmistDim" },
}

local function status_parts(status)
  if status == "completed" then
    return icons.check_circle, "JmistOk"
  elseif status == "running" then
    return icons.clock, "JmistInfo"
  elseif status == "failed" then
    return icons.error, "JmistError"
  end

  return icons.clock, "JmistMuted"
end

M.lines = function()
  local width = state.content_width
  local height = state.body_height
  local output = state.output or {}
  local log_lines = output.lines or {}
  local total = #log_lines
  local visible = math.max(1, height - M.LIST_OFFSET)
  local scroll = util.clamp(state.scroll, 0, math.max(0, total - visible))

  local status_icon, status_hl = status_parts(output.status)

  local lines = {
    c.row(width, {
      { icons.terminal, "JmistAccent" },
      { "  " .. (output.command or "No command yet"), "JmistCommand" },
    }, {
      { status_icon, status_hl },
      { " " .. (output.status or "idle"), "JmistMuted" },
      { "  ·  ", "JmistDim" },
      { icons.clock, "JmistMuted" },
      { " " .. (output.elapsed or "-"), "JmistMuted" },
    }),
    c.separator(width),
  }

  for index = scroll + 1, math.min(total, scroll + visible) do
    local entry = log_lines[index]
    local meta = LEVELS[entry.level] or LEVELS.info
    local text = entry.text or ""

    if text == "" then
      lines[#lines + 1] = c.blank(width)
    else
      local shown = c.truncate(text, width - 3)
      lines[#lines + 1] = {
        { " ", "JmistDim" },
        { meta.icon, meta.hl },
        { " ", "JmistDim" },
        { shown, meta.hl },
      }
    end
  end

  return c.finish(lines, height, width)
end

return M
