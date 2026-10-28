-- Runtime state for a single jmist window.
-- The views read from this table; only actions and app mutate it.

local M = {
  -- Window/session data
  win = nil,
  buf = nil,
  ns = nil,
  augroup = nil,
  previous_win = nil,
  closing = false,

  -- Geometry (set by app.open)
  width = 0,
  height = 0,
  content_width = 0,
  body_height = 0,
  body_top = 0,

  -- Navigation
  tab = "dependencies",
  tabs = { "dependencies", "search", "output" },
  selected = 1,
  scroll = 0,

  -- Transient footer message: { icon = string, text = string, hl = string }
  status = nil,

  -- Demo payload. These fields will be filled by real Maven/Gradle data later.
  project = {},
  counts = { total = 0, direct = 0, transitive = 0 },
  dependencies = {},
  search = { query = "", source = "Maven Central", results = {} },
  output = { command = "", status = "", elapsed = "", lines = {} },
}

return M
