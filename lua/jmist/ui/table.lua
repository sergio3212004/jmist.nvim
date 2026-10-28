-- Shared table chrome: cursor/hover styles, row icons, hover details and paging.
-- Views stay pure; the only external input is Volt's hover global.

local state = require "jmist.state"
local icons = require "jmist.icons"

local M = {}

local CURSOR_HL = {
  JmistAccent = "JmistCursorIcon",
  JmistMuted = "JmistCursorMuted",
  JmistValue = "JmistCursorValue",
  JmistScope = "JmistCursorScope",
  JmistDirect = "JmistCursorDirect",
  JmistOk = "JmistCursorOk",
}

local HOVER_HL = {
  JmistAccent = "JmistHoverIcon",
  JmistMuted = "JmistHoverMuted",
  JmistValue = "JmistHoverValue",
  JmistScope = "JmistHoverScope",
  JmistDirect = "JmistHoverDirect",
  JmistOk = "JmistHoverOk",
}

--- Stable hover identifier for a row or paging control.
M.id = function(kind, key)
  return kind .. ":" .. tostring(key)
end

--- Highlight for a column, adjusted for the row state.
--- @param mode string|nil "cursor", "hover" or nil for a regular row.
--- @param base string|nil Semantic highlight name.
--- @return string
M.hl = function(mode, base)
  if mode == "cursor" then
    return CURSOR_HL[base] or "JmistCursorText"
  elseif mode == "hover" then
    return HOVER_HL[base] or "JmistHoverText"
  end

  return base or "Normal"
end

--- Leading icon for the row state.
M.icon = function(mode)
  if mode == "cursor" then
    return icons.chevron_right
  elseif mode == "hover" then
    return icons.cursor
  end

  return icons.package
end

M.icon_hl = function(mode)
  if mode == "cursor" then
    return "JmistCursorIcon"
  elseif mode == "hover" then
    return "JmistHoverIcon"
  end

  return "JmistDim"
end

--- Resolves the visual state of a row. Selection wins over hover.
--- @return string|nil
M.mode = function(kind, index, selected)
  if selected then
    return "cursor"
  end

  if vim.g.nvmark_hovered == M.id(kind, index) then
    return "hover"
  end
end

--- Volt actions payload that makes a whole row hoverable.
M.hover = function(kind, key)
  return {
    id = M.id(kind, key),
    redraw = { "body", "footer" },
  }
end

local function page_button(icon, kind, key, enabled, step)
  if not enabled then
    return { icon, "JmistPageOff" }
  end

  local id = M.id(kind, key)
  local hovered = vim.g.nvmark_hovered == id

  return {
    icon,
    hovered and "JmistPageHover" or "JmistPage",
    {
      click = function()
        require("jmist.actions").page(step)
      end,
      hover = {
        id = id,
        redraw = { "body", "footer" },
      },
    },
  }
end

--- Separator with clickable page controls at the right edge.
--- @param width number
--- @param opts table { kind = "dep"|"search", can_prev = boolean, can_next = boolean }
--- @return table
M.separator = function(width, opts)
  return {
    { string.rep("─", math.max(0, width - 6)), "JmistBorder" },
    { "  ", "JmistBorder" },
    page_button(icons.chevron_up, opts.kind, "prev", opts.can_prev, -1),
    { "  ", "JmistBorder" },
    page_button(icons.chevron_down, opts.kind, "next", opts.can_next, 1),
  }
end

--- Parses the active Volt hover id.
--- @return table|nil { kind = string, key = string }
M.current = function()
  local id = vim.g.nvmark_hovered

  if type(id) ~= "string" then
    return nil
  end

  local kind, key = id:match "^(%a+):(.+)$"

  if not kind or not key then
    return nil
  end

  return { kind = kind, key = key }
end

local function dependency_detail(dep)
  return {
    { icons.package, "JmistAccent" },
    { " " .. dep.group .. ":" .. dep.artifact, "JmistValue" },
    { "  ·  ", "JmistDim" },
    { dep.version, "JmistValue" },
    { "  ·  ", "JmistDim" },
    { dep.scope, "JmistScope" },
    { "  ·  ", "JmistDim" },
    { dep.kind, dep.kind == "direct" and "JmistDirect" or "JmistMuted" },
  }
end

local function search_detail(result)
  local installed = result.installed
  local action_hl = installed and "JmistOk" or "JmistAccent"

  return {
    { icons.package, "JmistAccent" },
    { " " .. result.group .. ":" .. result.artifact, "JmistValue" },
    { "  ·  ", "JmistDim" },
    { result.version, "JmistValue" },
    { "  ·  ", "JmistDim" },
    { result.downloads .. " downloads", "JmistMuted" },
    { "  ·  ", "JmistDim" },
    { installed and icons.check or icons.download, action_hl },
    { " " .. (installed and "installed" or "install"), action_hl },
  }
end

local function page_detail(key)
  local icon = key == "prev" and icons.chevron_up or icons.chevron_down
  local label = key == "prev" and " Previous page" or " Next page"

  return {
    { icon, "JmistAccent" },
    { label, "JmistMuted" },
  }
end

--- Footer fragments for the current hover target, or nil when there is none.
--- @return table|nil
M.detail = function()
  local hover = M.current()

  if not hover then
    return nil
  end

  if hover.kind == "dep" then
    if state.tab ~= "dependencies" then
      return nil
    end

    local index = tonumber(hover.key)

    if index then
      local dep = state.dependencies[index]
      return dep and dependency_detail(dep) or nil
    end

    return page_detail(hover.key)
  elseif hover.kind == "search" then
    if state.tab ~= "search" then
      return nil
    end

    local index = tonumber(hover.key)

    if index then
      local result = state.search.results[index]
      return result and search_detail(result) or nil
    end

    return page_detail(hover.key)
  end
end

return M
