-- Highlights are derived from the active colorscheme instead of hardcoding colors.
-- This keeps jmist consistent with NvChad/base46 and any other theme.

local api = vim.api
local M = {}

local function get(name)
  local ok, hl = pcall(api.nvim_get_hl, 0, { name = name, link = false })

  if not ok or not hl then
    ok, hl = pcall(api.nvim_get_hl, 0, { name = name })
  end

  return (ok and hl) or {}
end

local function first_fg(...)
  for _, hl in ipairs { ... } do
    if hl and hl.fg then
      return hl.fg
    end
  end
end

M.setup = function()
  local normal = get "Normal"
  local comment = get "Comment"
  local nontext = get "NonText"
  local func = get "Function"
  local special = get "Special"
  local identifier = get "Identifier"
  local type_group = get "Type"
  local string_group = get "String"
  local pmenu = get "Pmenu"
  local pmenu_sel = get "PmenuSel"
  local float_border = get "FloatBorder"
  local title = get "Title"

  local diag_ok = get "DiagnosticOk"
  local diag_warn = get "DiagnosticWarn"
  local diag_error = get "DiagnosticError"
  local diag_info = get "DiagnosticInfo"

  local selection_bg = pmenu_sel.bg or get("CursorLine").bg or get("Visual").bg or pmenu.bg
  local selection_fg = pmenu_sel.fg or normal.fg
  local accent = first_fg(func, special, identifier, normal)
  local muted = first_fg(comment, nontext, normal)

  local function set(name, opts)
    api.nvim_set_hl(0, name, opts)
  end

  set("JmistTitle", { fg = first_fg(normal, title), bold = true })
  set("JmistAccent", { fg = accent })
  set("JmistMuted", { fg = muted })
  set("JmistDim", { fg = first_fg(nontext, comment, normal) })
  set("JmistBorder", { fg = first_fg(float_border, comment, normal) })
  set("JmistKey", { fg = first_fg(special, identifier, normal), bold = true })
  set("JmistValue", { fg = first_fg(identifier, func, normal) })
  set("JmistScope", { fg = first_fg(type_group, identifier, normal) })
  set("JmistDirect", { fg = first_fg(string_group, diag_ok, normal) })
  set("JmistOk", { fg = first_fg(diag_ok, string_group, normal) })
  set("JmistWarn", { fg = first_fg(diag_warn, normal) })
  set("JmistError", { fg = first_fg(diag_error, normal) })
  set("JmistInfo", { fg = first_fg(diag_info, func, normal) })
  set("JmistCommand", { fg = first_fg(string_group, diag_ok, normal) })
  set("JmistTableHeader", { fg = first_fg(func, normal), bold = true })
  set("JmistInputBorder", { fg = first_fg(float_border, func, normal) })
  set("JmistFloatTitle", { fg = first_fg(func, normal), bold = true })

  -- Tabs and selected rows share the PmenuSel background.
  set("JmistTabActive", { fg = selection_fg, bg = selection_bg, bold = true })
  set("JmistTabInactive", { fg = muted })
  set("JmistRowSelected", { fg = selection_fg, bg = selection_bg })

  -- Selection keeps the semantic colors of each column while using one background.
  local function selection_variant(name, fg)
    set(name, { fg = fg or selection_fg, bg = selection_bg })
  end

  selection_variant("JmistSelText", normal.fg)
  selection_variant("JmistSelMuted", muted)
  selection_variant("JmistSelValue", first_fg(identifier, func, normal))
  selection_variant("JmistSelScope", first_fg(type_group, identifier, normal))
  selection_variant("JmistSelDirect", first_fg(string_group, diag_ok, normal))
  selection_variant("JmistSelIcon", accent)
end

return M
