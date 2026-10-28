-- Commands only. All logic lives in lua/jmist.

if vim.g.loaded_jmist then
  return
end

vim.g.loaded_jmist = true

vim.api.nvim_create_user_command("Jmist", function()
  require("jmist").open()
end, { desc = "jmist: open the UI" })

vim.api.nvim_create_user_command("JmistClose", function()
  require("jmist").close()
end, { desc = "jmist: close the UI" })

vim.api.nvim_create_user_command("JmistToggle", function()
  require("jmist").toggle()
end, { desc = "jmist: toggle the UI" })

local group = vim.api.nvim_create_augroup("JmistColors", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    require("jmist.highlights").setup()
  end,
})
