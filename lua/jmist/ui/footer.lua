-- Bottom bar: contextual key hints and a transient status message.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"

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

  local left = c.join(c.icon(icons.key, "JmistDim"), c.text("  ", "JmistDim"), c.key_hints(hints))

  local right

  if state.status then
    right = c.join(
      c.icon(state.status.icon or icons.info, state.status.hl or "JmistInfo"),
      c.text(" " .. state.status.text, state.status.hl or "JmistInfo")
    )
  else
    right = c.join(c.icon(icons.check_circle, "JmistOk"), c.text(" ready", "JmistMuted"))
  end

  return {
    c.separator(width),
    c.row(width, left, right),
  }
end

return M
