-- Public API for jmist.
-- Volt is loaded lazily so requiring this module never breaks Neovim startup.

local M = {}

--- @param opts table|nil
M.setup = function(opts)
  require("jmist.config").setup(opts)
end

M.open = function()
  require("jmist.app").open()
end

M.close = function()
  require("jmist.app").close()
end

M.toggle = function()
  require("jmist.app").toggle()
end

M.is_open = function()
  return require("jmist.app").is_open()
end

return M
