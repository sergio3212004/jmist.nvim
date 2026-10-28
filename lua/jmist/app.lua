-- Window lifecycle: create the float, mount Volt sections, and clean everything up.

local api = vim.api
local config = require "jmist.config"
local state = require "jmist.state"
local windows = require "jmist.windows"
local layout = require "jmist.layout"
local ui = require "jmist.ui"

local M = {}

M.is_open = function()
  return state.win ~= nil and api.nvim_win_is_valid(state.win) and state.buf ~= nil and api.nvim_buf_is_valid(state.buf)
end

local HIDDEN_CURSOR = "a:JmistHiddenCursor"
local FILETYPE = "jmist"

--- Hides the real cursor while jmist is focused. The plugin draws its own
--- selection row, so a block cursor would only cover the highlighted text.
local function hide_cursor()
  if state.guicursor == nil then
    state.guicursor = vim.go.guicursor
  end

  if vim.go.guicursor ~= HIDDEN_CURSOR then
    vim.go.guicursor = HIDDEN_CURSOR
  end
end

--- Restores the cursor mode saved when the window opened.
local function restore_cursor()
  if state.guicursor ~= nil then
    vim.go.guicursor = state.guicursor
  end
end

--- Keeps animated cursor plugins from drawing their own block over the float.
--- smear-cursor checks the current filetype, so jmist registers its filetype in
--- the plugin's opt-out list when it is loaded.
local function exclude_cursor_animations()
  local ok, smear = pcall(require, "smear_cursor.config")

  if ok and type(smear.filetypes_disabled) == "table" and not vim.tbl_contains(smear.filetypes_disabled, FILETYPE) then
    table.insert(smear.filetypes_disabled, FILETYPE)
  end
end

local function forget_volt(buf)
  local ok, volt_state = pcall(require, "volt.state")

  if ok then
    volt_state[buf] = nil
  end

  local events_ok, events = pcall(require, "volt.events")

  if events_ok and events.bufs then
    for index = #events.bufs, 1, -1 do
      if events.bufs[index] == buf then
        table.remove(events.bufs, index)
      end
    end
  end
end

local function install_session_autocmds(win)
  local group = api.nvim_create_augroup("JmistSession", { clear = true })
  state.augroup = group

  api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(win),
    callback = function()
      vim.schedule(function()
        if state.win == win then
          M.close()
        end
      end)
    end,
  })

  api.nvim_create_autocmd("WinLeave", {
    group = group,
    buffer = state.buf,
    callback = function()
      restore_cursor()

      if not vim.g.nvmark_hovered then
        return
      end

      vim.g.nvmark_hovered = nil

      vim.schedule(function()
        if M.is_open() then
          require("volt").redraw(state.buf, { "body", "footer" })
        end
      end)
    end,
  })

  api.nvim_create_autocmd("WinEnter", {
    group = group,
    buffer = state.buf,
    callback = function()
      hide_cursor()
    end,
  })

  -- The option is global and mode-based: while the command line is active the
  -- real cursor must be visible again, then hidden when focus returns to jmist.
  api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = function()
      if api.nvim_get_current_win() == state.win then
        restore_cursor()
      end
    end,
  })

  api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      if api.nvim_get_current_win() == state.win then
        hide_cursor()
      end
    end,
  })
end

M.open = function()
  if M.is_open() then
    api.nvim_set_current_win(state.win)
    return
  end

  require("jmist.highlights").setup()
  require("jmist.ui.demo").apply(state)
  vim.g.nvmark_hovered = nil

  local cfg = config.get()
  local geometry = windows.main()

  state.previous_win = api.nvim_get_current_win()
  state.width = geometry.width
  state.height = geometry.height
  state.content_width = geometry.width - 2 * cfg.padding
  state.body_height = math.max(4, geometry.height - ui.header.HEIGHT - ui.tabs.HEIGHT - ui.footer.HEIGHT)
  state.body_top = ui.header.HEIGHT + ui.tabs.HEIGHT
  state.selected = 1
  state.scroll = 0
  state.status = nil

  state.ns = api.nvim_create_namespace "jmist"
  state.buf = api.nvim_create_buf(false, true)
  state.win = api.nvim_open_win(state.buf, true, geometry.opts)

  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.wo[state.win].wrap = false
  vim.wo[state.win].cursorline = false
  vim.wo[state.win].signcolumn = "no"
  vim.wo[state.win].winhighlight = "Normal:JmistNormal,FloatBorder:JmistBorder,FloatTitle:JmistFloatTitle"
  hide_cursor()

  local volt = require "volt"

  volt.gen_data {
    {
      buf = state.buf,
      ns = state.ns,
      layout = layout.main,
      xpad = cfg.padding,
    },
  }

  volt.run(state.buf, { h = geometry.height, w = geometry.width })
  -- Volt sets its own filetype, so override it after the initial draw.
  vim.bo[state.buf].filetype = FILETYPE
  exclude_cursor_animations()
  require("volt.events").add(state.buf)
  require("jmist.keymaps").attach(state.buf)
  install_session_autocmds(state.win)
  require("jmist.actions").sync_cursor()
end

M.close = function()
  if state.closing then
    return
  end

  state.closing = true
  vim.g.nvmark_hovered = nil
  restore_cursor()
  state.guicursor = nil

  local win = state.win
  local buf = state.buf
  local augroup = state.augroup
  local previous_win = state.previous_win

  state.win = nil
  state.buf = nil
  state.ns = nil
  state.augroup = nil
  state.previous_win = nil

  if augroup then
    pcall(api.nvim_del_augroup_by_id, augroup)
  end

  if win and api.nvim_win_is_valid(win) then
    pcall(api.nvim_win_close, win, true)
  end

  if buf and api.nvim_buf_is_valid(buf) then
    pcall(api.nvim_buf_delete, buf, { force = true })
  end

  if buf then
    forget_volt(buf)
  end

  state.closing = false

  if previous_win and api.nvim_win_is_valid(previous_win) then
    pcall(api.nvim_set_current_win, previous_win)
  end
end

M.toggle = function()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

return M
