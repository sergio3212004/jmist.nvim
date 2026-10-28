-- Tab bar. Each tab is clickable and switches the body view.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"

local M = {}

M.HEIGHT = 2

local TABS = {
  { id = "dependencies", label = "Dependencies", icon = icons.dependency },
  { id = "search", label = "Search", icon = icons.search },
  { id = "output", label = "Output", icon = icons.terminal },
}

M.lines = function()
  local width = state.content_width
  local line = {}

  for index, tab in ipairs(TABS) do
    local active = state.tab == tab.id

    line[#line + 1] = {
      " " .. tab.icon .. "  " .. tab.label .. " ",
      active and "JmistTabActive" or "JmistTabInactive",
      {
        click = function()
          require("jmist.actions").set_tab(tab.id)
        end,
      },
    }

    if index < #TABS then
      line[#line + 1] = { "   ", "JmistDim" }
    end
  end

  return {
    line,
    c.separator(width),
  }
end

return M
