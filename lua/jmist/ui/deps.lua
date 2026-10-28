-- Dependencies view: a fixed-height table with selection and scrolling.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"
local util = require "jmist.util"

local M = {}

M.LIST_OFFSET = 2

local VERSION_W = 12
local SCOPE_W = 10
local KIND_W = 10

local SELECTION_HL = {
  JmistAccent = "JmistSelIcon",
  JmistMuted = "JmistSelMuted",
  JmistValue = "JmistSelValue",
  JmistScope = "JmistSelScope",
  JmistDirect = "JmistSelDirect",
}

local function column_hl(selected, base)
  if not selected then
    return base or "Normal"
  end

  return SELECTION_HL[base] or "JmistSelText"
end

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

local function dependency_line(dep, index, selected, name_width)
  local kind_hl = dep.kind == "direct" and "JmistDirect" or "JmistMuted"
  local name = c.ellipsize(dep.group .. ":" .. dep.artifact, name_width)

  local line = {
    { selected and icons.chevron_right or icons.package, column_hl(selected, nil) },
    { " ", column_hl(selected, nil) },
    { c.fit(name, name_width), column_hl(selected, nil) },
    { " ", column_hl(selected, nil) },
    { c.fit(dep.version, VERSION_W), column_hl(selected, "JmistValue") },
    { c.fit(dep.scope, SCOPE_W), column_hl(selected, "JmistScope") },
    { c.fit(dep.kind, KIND_W), column_hl(selected, kind_hl) },
  }

  for _, fragment in ipairs(line) do
    fragment[3] = {
      click = function()
        require("jmist.actions").select_dependency(index)
      end,
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
    c.separator(width),
  }

  if total == 0 then
    lines[#lines + 1] = {
      { "  " .. icons.info, "JmistMuted" },
      { "  No dependencies found", "JmistMuted" },
    }
  else
    for index = scroll + 1, math.min(total, scroll + visible) do
      lines[#lines + 1] = dependency_line(state.dependencies[index], index, index == selected, name_width)
    end
  end

  return c.finish(lines, height, width)
end

return M
