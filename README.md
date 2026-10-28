# jmist.nvim

A floating Neovim UI for managing Maven and Gradle projects: dependencies, Maven
Central search, and build output.

> **Status:** UI scaffold only. Project, dependency, search, and build data are
> demo values. Only opening, closing, and toggling the window work for real.

## Requirements

- Neovim 0.10+
- [volt.nvim](https://github.com/nvchad/volt) for the UI primitives
- A Nerd Font for the icons
- Optional: [base46](https://github.com/NvChad/base46) for theme-aware colors.
  Without it the UI falls back to colors derived from the active colorscheme.

## Installation

With `lazy.nvim`:

```lua
{
  "sergio/jmist.nvim",
  dependencies = { "nvchad/volt" },
  cmd = { "Jmist", "JmistClose", "JmistToggle" },
  opts = {},
}
```

No `setup()` call is required; the defaults below are used unless you pass `opts`.

## Commands

| Command        | Description              |
| -------------- | ------------------------ |
| `:Jmist`       | Open the UI              |
| `:JmistClose`  | Close the UI             |
| `:JmistToggle` | Toggle the UI            |

The same operations are available from Lua:

```lua
require("jmist").open()
require("jmist").close()
require("jmist").toggle()
require("jmist").is_open()
```

## Keymaps

| Key           | Action                              |
| ------------- | ----------------------------------- |
| `j` / `k`     | Move selection or scroll output     |
| `g` / `G`     | Jump to first or last item          |
| `<C-d>` / `<C-u>` | Next or previous page           |
| `<PageDown>` / `<PageUp>` | Next or previous page    |
| `h` / `l`     | Previous or next tab                |
| `1` `2` `3`   | Dependencies, Search, Output        |
| `<Tab>`       | Next tab                            |
| `<CR>`        | Activate the selected item          |
| `/`           | Jump to the Search tab              |
| `r`           | Refresh (demo)                      |
| `y`           | Copy the current build command      |
| `q` / `<Esc>` | Close                               |

Tabs, result rows, the install action, and the pagination chevrons are also
clickable. Hovering a row highlights it, shows a Nerd Font pointer, and previews
its coordinates, version, scope, and kind in the footer.

## Configuration

```lua
require("jmist").setup {
  size = {
    width = 80, -- percentage of the editor width
    height = 75, -- percentage of the editor height
  },
  min_width = 84,
  min_height = 20,
  border = "rounded",
  padding = 1,
  winblend = 0,
  zindex = 50,
}
```

## Layout

The window is one Volt buffer with four fixed sections:

| Section  | Height        | Contents                              |
| -------- | ------------- | ------------------------------------- |
| `header` | 3             | Project, build tool, runtime, counts  |
| `tabs`   | 2             | Dependencies / Search / Output        |
| `body`   | remaining     | Active tab view                       |
| `footer` | 2             | Contextual keys and status message    |

## Module layout

```
lua/jmist/
├── init.lua          Public API
├── app.lua           Window lifecycle and Volt mounting
├── actions.lua       State mutations and redraws
├── config.lua        User configuration
├── state.lua         Runtime state contract
├── layout.lua        Declarative Volt sections
├── windows.lua       Float geometry
├── keymaps.lua       Buffer-local keymaps
├── highlights.lua    base46-aware highlight groups
├── icons.lua         Nerd Font codepoints
├── util.lua          Scroll and clamp helpers
└── ui/
    ├── body.lua      Tab dispatcher
    ├── components.lua Line/fragment helpers
    ├── demo.lua      Placeholder data
    ├── deps.lua      Dependency table
    ├── search.lua    Search input and results
    ├── table.lua     Cursor/hover styles and pagination chrome
    ├── output.lua    Build log stream
    ├── header.lua
    ├── tabs.lua
    └── footer.lua
```

Views are pure functions over `state`; only `actions.lua` and `app.lua` mutate
state and request redraws.

## Theme

When base46 is available, jmist reads the palette compiled for the active theme
(`vim.g.base46_cache .. "colors"`) and uses it for every highlight group. The
keyboard cursor row mirrors NvChad's `PmenuSel` (`pmenu_bg` on `black`), hovered
rows use `one_bg2`, and borders and pagination controls use `blue`.

Outside NvChad, the groups are derived from the active colorscheme (`Normal`,
`PmenuSel`, `Comment`, `Diagnostic*`, and friends), so the UI still matches the
editor. Changing the colorscheme while jmist is open re-renders with the new
colors.
