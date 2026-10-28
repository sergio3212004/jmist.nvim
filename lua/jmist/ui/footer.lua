-- Bottom bar: contextual key hints or hover details, plus a status message.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"
local table_view = require "jmist.ui.table"

local M = {}

M.HEIGHT = 2

local KEY_HINTS = {
  dependencies = {
    { "j/k", "move" },
    { "⏎", "details" },
    { "/", "search" },
    { "r", "refresh" },
    { "q", "quit" },
  },
  search = {
    { "j/k", "move" },
    { "⏎", "install" },
    { "/", "query" },
    { "h/l", "tabs" },
    { "q", "quit" },
  },
  output = {
    { "j/k", "scroll" },
    { "y", "copy" },
    { "r", "rerun" },
    { "q", "quit" },
  },
}

M.lines = function()
  local width = state.content_width
  local hints = KEY_HINTS[state.tab] or KEY_HINTS.dependencies

  local right

  if state.status then
    right = c.join(
      c.icon(state.status.icon or icons.info, state.status.hl or "JmistInfo"),
      c.text(" " .. state.status.text, state.status.hl or "JmistInfo")
    )
  else
    right = c.join(c.icon(icons.check_circle, "JmistOk"), c.text(" ready", "JmistMuted"))
  end

  local left
  local detail = table_view.detail()

  if detail then
    local available = width - c.width(right) - 1

    if available > 0 then
      left = c.clip(detail, available)
    end
  end

  if not left then
    left = c.join(c.icon(icons.key, "JmistDim"), c.text("  ", "JmistDim"), c.key_hints(hints))
  end

  return {
    c.separator(width),
    c.row(width, left, right),
  }
end

return M
