-- UI actions. This is the only layer that mutates state and requests redraws.

local api = vim.api
local state = require "jmist.state"
local util = require "jmist.util"
local icons = require "jmist.icons"

local M = {}

local function is_open()
  return state.win ~= nil and api.nvim_win_is_valid(state.win) and state.buf ~= nil and api.nvim_buf_is_valid(state.buf)
end

local function redraw(names)
  if not is_open() then
    return
  end

  require("volt").redraw(state.buf, names)
end

local function list_offset()
  return require("jmist.ui.body").list_offset()
end

local function visible_rows()
  return math.max(1, state.body_height - list_offset())
end

local function list_length()
  if state.tab == "dependencies" then
    return #state.dependencies
  elseif state.tab == "search" then
    return #state.search.results
  end

  return #state.output.lines
end

--- Volt keeps the hovered id global; clear it when the pointer context changes.
local function clear_hover()
  vim.g.nvmark_hovered = nil
end

--- Places the cursor on the selected row so <CR> and mouse actions feel natural.
M.sync_cursor = function()
  if not is_open() then
    return
  end

  local line

  if state.tab == "output" then
    line = state.body_top + list_offset() + 1
  else
    line = state.body_top + list_offset() + (state.selected - state.scroll)
  end

  line = util.clamp(line, 1, state.height)
  local column = require("jmist.config").get().padding

  pcall(api.nvim_win_set_cursor, state.win, { line, column })
end

M.set_tab = function(tab)
  if not vim.tbl_contains(state.tabs, tab) then
    return
  end

  clear_hover()

  if state.tab == tab then
    redraw { "body", "footer" }
    return
  end

  state.tab = tab
  state.selected = 1
  state.scroll = 0
  state.status = nil

  M.sync_cursor()
  redraw { "tabs", "body", "footer" }
end

M.next_tab = function()
  local index = 1

  for tab_index, tab in ipairs(state.tabs) do
    if tab == state.tab then
      index = tab_index
      break
    end
  end

  index = (index % #state.tabs) + 1
  M.set_tab(state.tabs[index])
end

M.prev_tab = function()
  local index = 1

  for tab_index, tab in ipairs(state.tabs) do
    if tab == state.tab then
      index = tab_index
      break
    end
  end

  index = ((index - 2) % #state.tabs) + 1
  M.set_tab(state.tabs[index])
end

M.next = function(step)
  clear_hover()

  if state.tab == "output" then
    local total = #state.output.lines
    state.scroll = util.clamp(state.scroll + step, 0, math.max(0, total - visible_rows()))
  else
    local total = list_length()

    if total > 0 then
      state.selected = util.clamp(state.selected + step, 1, total)
      state.scroll = util.clamp_scroll(state.scroll, state.selected, visible_rows(), total)
      M.sync_cursor()
    end
  end

  state.status = nil
  redraw { "body", "footer" }
end

M.first = function()
  clear_hover()

  if state.tab == "output" then
    state.scroll = 0
  else
    state.selected = 1
    state.scroll = 0
    M.sync_cursor()
  end

  state.status = nil
  redraw { "body", "footer" }
end

M.last = function()
  clear_hover()

  if state.tab == "output" then
    local total = #state.output.lines
    state.scroll = math.max(0, total - visible_rows())
  else
    local total = list_length()

    if total > 0 then
      state.selected = total
      state.scroll = util.clamp_scroll(state.scroll, state.selected, visible_rows(), total)
      M.sync_cursor()
    end
  end

  state.status = nil
  redraw { "body", "footer" }
end

--- Moves the viewport (and selection) by one visible page.
M.page = function(step)
  clear_hover()

  local total = list_length()
  local visible = visible_rows()
  local max_scroll = math.max(0, total - visible)

  state.scroll = util.clamp(state.scroll + step * visible, 0, max_scroll)

  if state.tab ~= "output" and total > 0 then
    state.selected = util.clamp(state.scroll + 1, 1, total)
  end

  state.status = nil
  M.sync_cursor()
  redraw { "body", "footer" }
end

M.select_dependency = function(index)
  local total = #state.dependencies

  if total == 0 then
    return
  end

  clear_hover()
  state.selected = util.clamp(index or state.selected, 1, total)
  state.scroll = util.clamp_scroll(state.scroll, state.selected, visible_rows(), total)
  state.status = nil

  M.sync_cursor()
  redraw { "body", "footer" }
end

M.select_result = function(index)
  local total = #state.search.results

  if total == 0 then
    return
  end

  clear_hover()
  state.selected = util.clamp(index or state.selected, 1, total)
  state.scroll = util.clamp_scroll(state.scroll, state.selected, visible_rows(), total)
  state.status = nil

  M.sync_cursor()
  redraw { "body", "footer" }
end

M.toggle_install = function(index)
  local result = state.search.results[index]

  if not result then
    return
  end

  clear_hover()
  result.installed = not result.installed
  state.selected = index
  state.scroll = util.clamp_scroll(state.scroll, state.selected, visible_rows(), #state.search.results)

  if result.installed then
    state.status = {
      icon = icons.check_circle,
      text = "Demo: " .. result.artifact .. " marked as installed",
      hl = "JmistOk",
    }
  else
    state.status = {
      icon = icons.info,
      text = "Demo: " .. result.artifact .. " marked as not installed",
      hl = "JmistInfo",
    }
  end

  M.sync_cursor()
  redraw { "body", "footer" }
end

M.activate = function()
  clear_hover()

  if state.tab == "dependencies" then
    local dependency = state.dependencies[state.selected]

    if not dependency then
      return
    end

    state.status = {
      icon = icons.info,
      text = "Demo: details for " .. dependency.artifact .. " will open here",
      hl = "JmistInfo",
    }

    redraw "footer"
  elseif state.tab == "search" then
    M.toggle_install(state.selected)
  else
    M.copy_command()
  end
end

M.refresh = function()
  clear_hover()
  local text

  if state.tab == "dependencies" then
    text = "Demo: reloading dependencies from " .. (state.project.build_label or "Maven")
  elseif state.tab == "search" then
    text = 'Demo: searching Maven Central for "' .. (state.search.query or "") .. '"'
  else
    text = "Demo: rerunning " .. (state.output.command or "the last command")
  end

  state.status = { icon = icons.refresh, text = text, hl = "JmistInfo" }
  redraw "footer"
end

M.copy_command = function()
  clear_hover()
  local command = state.output.command

  if not command or command == "" then
    return
  end

  if not pcall(vim.fn.setreg, "+", command) then
    pcall(vim.fn.setreg, '"', command)
  end

  state.status = { icon = icons.check, text = "Copied: " .. command, hl = "JmistOk" }
  redraw "footer"
end

M.focus_search = function()
  M.set_tab "search"

  state.status = {
    icon = icons.info,
    text = "Demo: type a query; Maven Central search comes next",
    hl = "JmistInfo",
  }

  redraw "footer"
end

M.close = function()
  require("jmist.app").close()
end

return M
