-- Dependencies view: a fixed-height table with selection, hover and scrolling.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"
local table_view = require "jmist.ui.table"
local util = require "jmist.util"

local M = {}

M.LIST_OFFSET = 2

local VERSION_W = 12
local SCOPE_W = 10
local KIND_W = 10

local function header_line(name_width)
  return {
    { "  ", "JmistTableHeader" },
    { c.fit("Dependency", name_width), "JmistTableHeader" },
    { " ", "JmistTableHeader" },
    { c.fit("Version", VERSION_W), "JmistTableHeader" },
    { c.fit("Scope", SCOPE_W), "JmistTableHeader" },
    { c.fit("Kind", KIND_W), "JmistTableHeader" },
  }
end

local function dependency_line(dep, index, mode, name_width)
  local kind_hl = dep.kind == "direct" and "JmistDirect" or "JmistMuted"
  local name = c.ellipsize(dep.group .. ":" .. dep.artifact, name_width)

  local line = {
    { table_view.icon(mode), table_view.icon_hl(mode) },
    { " ", table_view.hl(mode, nil) },
    { c.fit(name, name_width), table_view.hl(mode, nil) },
    { " ", table_view.hl(mode, nil) },
    { c.fit(dep.version, VERSION_W), table_view.hl(mode, "JmistValue") },
    { c.fit(dep.scope, SCOPE_W), table_view.hl(mode, "JmistScope") },
    { c.fit(dep.kind, KIND_W), table_view.hl(mode, kind_hl) },
  }

  local hover = table_view.hover("dep", index)

  for _, fragment in ipairs(line) do
    fragment[3] = {
      click = function()
        require("jmist.actions").select_dependency(index)
      end,
      hover = hover,
    }
  end

  return line
end

M.lines = function()
  local width = state.content_width
  local height = state.body_height
  local total = #state.dependencies
  local visible = math.max(1, height - M.LIST_OFFSET)
  local selected = util.clamp(state.selected, 1, math.max(1, total))
  local scroll = util.clamp_scroll(state.scroll, selected, visible, total)
  local name_width = math.max(10, width - 35)

  local lines = {
    header_line(name_width),
    table_view.separator(width, {
      kind = "dep",
      can_prev = scroll > 0,
      can_next = scroll + visible < total,
    }),
  }

  if total == 0 then
    lines[#lines + 1] = {
      { "  " .. icons.info, "JmistMuted" },
      { "  No dependencies found", "JmistMuted" },
    }
  else
    for index = scroll + 1, math.min(total, scroll + visible) do
      local mode = table_view.mode("dep", index, index == selected)
      lines[#lines + 1] = dependency_line(state.dependencies[index], index, mode, name_width)
    end
  end

  return c.finish(lines, height, width)
end

return M
