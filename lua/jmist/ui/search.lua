-- Search view: input box plus Maven Central results.
-- The input is visual only for now; real querying will be wired later.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"
local util = require "jmist.util"

local M = {}

M.LIST_OFFSET = 8

local VERSION_W = 13
local DOWNLOADS_W = 9
local ACTION_W = 11

local SELECTION_HL = {
  JmistAccent = "JmistSelIcon",
  JmistMuted = "JmistSelMuted",
  JmistValue = "JmistSelValue",
  JmistOk = "JmistSelDirect",
}

local function column_hl(selected, base)
  if not selected then
    return base or "Normal"
  end

  return SELECTION_HL[base] or "JmistSelText"
end

local function results_header(name_width)
  return {
    { "  ", "JmistTableHeader" },
    { c.fit("Artifact", name_width), "JmistTableHeader" },
    { " ", "JmistTableHeader" },
    { c.fit("Version", VERSION_W), "JmistTableHeader" },
    { c.fit("Downloads", DOWNLOADS_W), "JmistTableHeader" },
    { " ", "JmistTableHeader" },
    { c.fit("Action", ACTION_W), "JmistTableHeader" },
  }
end

local function result_line(result, index, selected, name_width)
  local action = result.installed and "installed" or "install"
  local action_hl = result.installed and "JmistOk" or "JmistAccent"
  local name = c.ellipsize(result.group .. ":" .. result.artifact, name_width)

  local line = {
    { selected and icons.chevron_right or icons.package, column_hl(selected, nil) },
    { " ", column_hl(selected, nil) },
    { c.fit(name, name_width), column_hl(selected, nil) },
    { " ", column_hl(selected, nil) },
    { c.fit(result.version, VERSION_W), column_hl(selected, "JmistValue") },
    { c.fit(result.downloads, DOWNLOADS_W), column_hl(selected, "JmistMuted") },
    { " ", column_hl(selected, nil) },
    { c.fit(" " .. action, ACTION_W), column_hl(selected, action_hl) },
  }

  for fragment_index, fragment in ipairs(line) do
    fragment[3] = {
      click = function()
        if fragment_index == #line then
          require("jmist.actions").toggle_install(index)
        else
          require("jmist.actions").select_result(index)
        end
      end,
    }
  end

  return line
end

M.lines = function()
  local width = state.content_width
  local height = state.body_height
  local search = state.search or {}
  local results = search.results or {}
  local total = #results
  local visible = math.max(1, height - M.LIST_OFFSET)
  local selected = util.clamp(state.selected, 1, math.max(1, total))
  local scroll = util.clamp_scroll(state.scroll, selected, visible, total)
  local name_width = math.max(10, width - 37)

  local query = search.query or ""
  local query_text = query ~= "" and query or "Search dependencies in Maven Central…"
  local query_hl = query ~= "" and "JmistValue" or "JmistDim"

  local lines = {
    c.row(width, {
      { icons.search, "JmistAccent" },
      { "  Search Maven Central", "JmistTableHeader" },
    }, {
      { tostring(total) .. " results", "JmistMuted" },
      { "  ·  ", "JmistDim" },
      { search.source or "Maven Central", "JmistMuted" },
    }),
    c.blank(width),
    { { "╭" .. string.rep("─", width - 2) .. "╮", "JmistInputBorder" } },
  }

  local input_line = {
    { "│ ", "JmistInputBorder" },
  }

  c.append(
    input_line,
    c.row(width - 4, {
      { icons.search, "JmistAccent" },
      { "  ", "JmistDim" },
      { query_text, query_hl },
      { "▏", "JmistAccent" },
    }, {
      { "⏎ search", "JmistDim" },
    })
  )

  input_line[#input_line + 1] = { " │", "JmistInputBorder" }
  lines[#lines + 1] = input_line
  lines[#lines + 1] = { { "╰" .. string.rep("─", width - 2) .. "╯", "JmistInputBorder" } }
  lines[#lines + 1] = c.blank(width)
  lines[#lines + 1] = results_header(name_width)
  lines[#lines + 1] = c.separator(width)

  if total == 0 then
    lines[#lines + 1] = {
      { "  " .. icons.info, "JmistMuted" },
      { "  No results yet", "JmistMuted" },
    }
  else
    for index = scroll + 1, math.min(total, scroll + visible) do
      lines[#lines + 1] = result_line(results[index], index, index == selected, name_width)
    end
  end

  return c.finish(lines, height, width)
end

return M
