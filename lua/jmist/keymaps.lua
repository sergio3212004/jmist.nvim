-- Buffer-local keymaps. Only navigation and demo actions for now.

local map = vim.keymap.set

local M = {}

M.attach = function(buf)
  local function act(description)
    return {
      buffer = buf,
      nowait = true,
      silent = true,
      desc = "jmist: " .. description,
    }
  end

  local actions = function()
    return require "jmist.actions"
  end

  map("n", "q", function()
    actions().close()
  end, act "close")

  map("n", "<Esc>", function()
    actions().close()
  end, act "close")

  map("n", "j", function()
    actions().next(1)
  end, act "next item")

  map("n", "<Down>", function()
    actions().next(1)
  end, act "next item")

  map("n", "k", function()
    actions().next(-1)
  end, act "previous item")

  map("n", "<Up>", function()
    actions().next(-1)
  end, act "previous item")

  map("n", "g", function()
    actions().first()
  end, act "first item")

  map("n", "<Home>", function()
    actions().first()
  end, act "first item")

  map("n", "G", function()
    actions().last()
  end, act "last item")

  map("n", "<End>", function()
    actions().last()
  end, act "last item")

  map("n", "h", function()
    actions().prev_tab()
  end, act "previous tab")

  map("n", "<Left>", function()
    actions().prev_tab()
  end, act "previous tab")

  map("n", "l", function()
    actions().next_tab()
  end, act "next tab")

  map("n", "<Right>", function()
    actions().next_tab()
  end, act "next tab")

  map("n", "<Tab>", function()
    actions().next_tab()
  end, act "next tab")

  map("n", "<S-Tab>", function()
    actions().prev_tab()
  end, act "previous tab")

  map("n", "1", function()
    actions().set_tab "dependencies"
  end, act "dependencies tab")

  map("n", "2", function()
    actions().set_tab "search"
  end, act "search tab")

  map("n", "3", function()
    actions().set_tab "output"
  end, act "output tab")

  map("n", "/", function()
    actions().focus_search()
  end, act "search")

  map("n", "o", function()
    actions().set_tab "output"
  end, act "output tab")

  map("n", "<CR>", function()
    actions().activate()
  end, act "activate")

  map("n", "r", function()
    actions().refresh()
  end, act "refresh")

  map("n", "y", function()
    actions().copy_command()
  end, act "copy command")

  map("n", "<ScrollWheelDown>", function()
    actions().next(3)
  end, act "scroll down")

  map("n", "<ScrollWheelUp>", function()
    actions().next(-3)
  end, act "scroll up")
end

return M
