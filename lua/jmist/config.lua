-- Plugin configuration. Only UI concerns live here for now.

local M = {}

M.defaults = {
  -- Percentages of the editor size, like floaterm.
  size = {
    width = 80,
    height = 75,
  },

  -- Absolute limits so the table stays readable on small terminals.
  min_width = 84,
  min_height = 20,

  border = "rounded",
  padding = 1,
  winblend = 0,
  zindex = 50,
}

M.values = vim.deepcopy(M.defaults)

--- @param opts table|nil
M.setup = function(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

--- @return table
M.get = function()
  return M.values
end

return M
