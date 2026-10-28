-- Body dispatcher. Each tab has its own view with the same contract:
-- lines(buf) returns exactly state.body_height lines.

local state = require "jmist.state"

local M = {}

local VIEWS = {
  dependencies = require "jmist.ui.deps",
  search = require "jmist.ui.search",
  output = require "jmist.ui.output",
}

local function current()
  return VIEWS[state.tab] or VIEWS.dependencies
end

M.lines = function(buf)
  return current().lines(buf)
end

--- First row of the actionable list inside the body, used to place the cursor.
M.list_offset = function()
  return current().LIST_OFFSET
end

return M
