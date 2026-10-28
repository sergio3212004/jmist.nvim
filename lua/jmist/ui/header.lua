-- Top bar: project identity on the left, build/runtime details on the right.

local state = require "jmist.state"
local icons = require "jmist.icons"
local c = require "jmist.ui.components"

local M = {}

M.HEIGHT = 3

M.lines = function()
  local width = state.content_width
  local project = state.project or {}
  local counts = state.counts or {}
  local is_gradle = project.build == "gradle"

  local title = c.join(
    c.icon(icons.package, "JmistAccent"),
    c.text(" jmist", "JmistTitle"),
    c.text("  ·  ", "JmistDim"),
    c.text(project.name or "project", "JmistMuted")
  )

  local build_info = {
    { is_gradle and icons.gradle or icons.maven, "JmistAccent" },
    { " " .. (project.build_label or "Maven"), "JmistMuted" },
    { "   ", "JmistDim" },
    { icons.java, "JmistAccent" },
    { " " .. (project.java or "Java"), "JmistMuted" },
    { "   ·   ", "JmistDim" },
    { icons.check_circle, "JmistOk" },
    { " " .. (project.status or "ready"), "JmistOk" },
  }

  local location = c.join(
    c.icon(icons.folder, "JmistMuted"),
    c.text(" " .. (project.root or "~"), "JmistMuted"),
    c.text("   ", "JmistDim"),
    c.icon(icons.branch, "JmistMuted"),
    c.text(" " .. (project.branch or "main"), "JmistMuted")
  )

  local stats = {
    { tostring(counts.total or 0), "JmistAccent" },
    { " deps", "JmistMuted" },
    { "  ·  ", "JmistDim" },
    { tostring(counts.direct or 0), "JmistDirect" },
    { " direct", "JmistMuted" },
    { "  ·  ", "JmistDim" },
    { tostring(counts.transitive or 0), "JmistScope" },
    { " transitive", "JmistMuted" },
  }

  return {
    c.row(width, title, build_info),
    c.row(width, location, stats),
    c.separator(width),
  }
end

return M
