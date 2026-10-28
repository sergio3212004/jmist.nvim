-- Declarative Volt sections. The wrappers resolve views lazily, so a view can be
-- replaced or reloaded without rebuilding the layout table.

local M = {}

local function view(name)
  return function(buf)
    return require("jmist.ui." .. name).lines(buf)
  end
end

M.main = {
  { name = "header", lines = view "header" },
  { name = "tabs", lines = view "tabs" },
  { name = "body", lines = view "body" },
  { name = "footer", lines = view "footer" },
}

return M
