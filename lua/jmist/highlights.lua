-- Highlights use base46's palette when it is available, so jmist always
-- matches the active NvChad theme. A colorscheme-derived fallback keeps the
-- plugin usable outside the NvChad ecosystem.

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

--- Reads the palette base46 compiled for the current theme.
--- @return table|nil
local function base46_colors()
  local cache = vim.g.base46_cache

  if type(cache) == "string" and cache ~= "" then
    local path = cache:sub(-1) == "/" and (cache .. "colors") or (cache .. "/colors")
    local ok, colors = pcall(dofile, path)

    if ok and type(colors) == "table" then
      return colors
    end
  end

  local ok, b46 = pcall(require, "base46")

  if ok and type(b46) == "table" and type(b46.get_theme_tb) == "function" then
    local loaded, colors = pcall(b46.get_theme_tb, "base_30")

    if loaded and type(colors) == "table" then
      return colors
    end
  end
end

--- @return boolean
local function transparent()
  local ok, nvconfig = pcall(require, "nvconfig")

  if ok and type(nvconfig) == "table" and type(nvconfig.base46) == "table" then
    return nvconfig.base46.transparency == true
  end

  return false
end

--- @return table
local function palette()
  local ui = base46_colors()

  if ui then
    local normal_bg = ui.darker_black

    if transparent() then
      normal_bg = nil
    end

    return {
      normal_fg = ui.white,
      normal_bg = normal_bg,
      accent = ui.blue,
      border = ui.blue,
      title = ui.white,
      muted = ui.grey_fg,
      dim = ui.grey,
      key = ui.yellow,
      value = ui.green,
      scope = ui.purple,
      direct = ui.vibrant_green,
      ok = ui.green,
      warn = ui.yellow,
      error = ui.red,
      info = ui.cyan,
      command = ui.seablue,
      header = ui.white,
      input_border = ui.blue,
      float_title_fg = ui.black,
      float_title_bg = ui.blue,
      cursor_fg = ui.black,
      cursor_bg = ui.pmenu_bg,
      cursor_icon = ui.white,
      hover_bg = ui.one_bg2,
      hover_fg = ui.white,
      hover_muted = ui.grey_fg,
      hover_icon = ui.blue,
      page = ui.blue,
      page_off = ui.grey,
      page_hover = ui.cyan,
      tab_active_fg = ui.black,
      tab_active_bg = ui.pmenu_bg,
      tab_inactive = ui.grey_fg,
    }
  end

  local normal = get "Normal"
  local float = get "NormalFloat"
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
  local cursorline = get "CursorLine"
  local title = get "Title"

  local diag_ok = get "DiagnosticOk"
  local diag_warn = get "DiagnosticWarn"
  local diag_error = get "DiagnosticError"
  local diag_info = get "DiagnosticInfo"

  local accent = first_fg(func, special, identifier, normal)
  local muted = first_fg(comment, nontext, normal)
  local selection_bg = pmenu_sel.bg or cursorline.bg or get("Visual").bg or pmenu.bg
  local selection_fg = pmenu_sel.fg or normal.fg

  return {
    normal_fg = normal.fg,
    normal_bg = float.bg or normal.bg,
    accent = accent,
    border = first_fg(float_border, comment, normal),
    title = first_fg(normal, title),
    muted = muted,
    dim = first_fg(nontext, comment, normal),
    key = first_fg(special, identifier, normal),
    value = first_fg(identifier, func, normal),
    scope = first_fg(type_group, identifier, normal),
    direct = first_fg(string_group, diag_ok, normal),
    ok = first_fg(diag_ok, string_group, normal),
    warn = first_fg(diag_warn, normal),
    error = first_fg(diag_error, normal),
    info = first_fg(diag_info, func, normal),
    command = first_fg(string_group, diag_ok, normal),
    header = first_fg(func, normal),
    input_border = first_fg(float_border, func, normal),
    float_title_fg = first_fg(func, normal),
    float_title_bg = nil,
    cursor_fg = selection_fg,
    cursor_bg = selection_bg,
    cursor_icon = selection_fg,
    hover_bg = cursorline.bg or pmenu.bg or selection_bg,
    hover_fg = normal.fg,
    hover_muted = muted,
    hover_icon = accent,
    page = accent,
    page_off = first_fg(nontext, comment, normal),
    page_hover = first_fg(special, identifier, normal),
    tab_active_fg = selection_fg,
    tab_active_bg = selection_bg,
    tab_inactive = muted,
  }
end

M.setup = function()
  local p = palette()

  local function set(name, opts)
    api.nvim_set_hl(0, name, opts)
  end

  set("JmistNormal", { fg = p.normal_fg, bg = p.normal_bg })
  set("JmistTitle", { fg = p.title, bold = true })
  set("JmistAccent", { fg = p.accent })
  set("JmistMuted", { fg = p.muted })
  set("JmistDim", { fg = p.dim })
  set("JmistBorder", { fg = p.border })
  set("JmistKey", { fg = p.key, bold = true })
  set("JmistValue", { fg = p.value })
  set("JmistScope", { fg = p.scope })
  set("JmistDirect", { fg = p.direct })
  set("JmistOk", { fg = p.ok })
  set("JmistWarn", { fg = p.warn })
  set("JmistError", { fg = p.error })
  set("JmistInfo", { fg = p.info })
  set("JmistCommand", { fg = p.command })
  set("JmistTableHeader", { fg = p.header, bold = true })
  set("JmistInputBorder", { fg = p.input_border })
  set("JmistFloatTitle", { fg = p.float_title_fg, bg = p.float_title_bg, bold = true })

  set("JmistTabActive", { fg = p.tab_active_fg, bg = p.tab_active_bg, bold = true })
  set("JmistTabInactive", { fg = p.tab_inactive })

  -- Keyboard cursor row: NvChad's PmenuSel style.
  local function cursor_variant(name, bold)
    set(name, { fg = p.cursor_fg, bg = p.cursor_bg, bold = bold })
  end

  cursor_variant "JmistCursorText"
  cursor_variant "JmistCursorMuted"
  cursor_variant "JmistCursorValue"
  cursor_variant "JmistCursorScope"
  cursor_variant("JmistCursorDirect", true)
  cursor_variant("JmistCursorOk", true)
  set("JmistCursorIcon", { fg = p.cursor_icon, bg = p.cursor_bg, bold = true })

  -- Mouse hover row: a softer background that keeps semantic column colors.
  local function hover_variant(name, fg, bold)
    set(name, { fg = fg, bg = p.hover_bg, bold = bold })
  end

  hover_variant("JmistHoverText", p.hover_fg)
  hover_variant("JmistHoverMuted", p.hover_muted)
  hover_variant("JmistHoverValue", p.value)
  hover_variant("JmistHoverScope", p.scope)
  hover_variant("JmistHoverDirect", p.direct, true)
  hover_variant("JmistHoverOk", p.ok, true)
  set("JmistHoverIcon", { fg = p.hover_icon, bg = p.hover_bg, bold = true })

  -- Table pagination chevrons.
  set("JmistPage", { fg = p.page })
  set("JmistPageOff", { fg = p.page_off })
  set("JmistPageHover", { fg = p.page_hover, bold = true })
end

return M
