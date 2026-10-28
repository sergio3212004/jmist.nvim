-- Pure helpers that build Volt line fragments.
-- A line is a list of fragments: { text, highlight, actions }.

local api = vim.api
local M = {}

M.strw = function(text)
  return api.nvim_strwidth(text)
end

--- Total display width of a line.
--- @param line table
--- @return number
M.width = function(line)
  local width = 0

  for _, fragment in ipairs(line) do
    if fragment[1] ~= "_pad_" then
      width = width + api.nvim_strwidth(fragment[1])
    end
  end

  return width
end

--- A new line with a single text fragment.
M.text = function(text, hl)
  return { { text, hl or "Normal" } }
end

M.icon = function(icon, hl)
  return { { icon, hl or "Normal" } }
end

M.spaces = function(n)
  return { { string.rep(" ", math.max(0, n)), "Normal" } }
end

M.blank = function(width)
  return { { string.rep(" ", math.max(0, width)), "Normal" } }
end

M.separator = function(width, hl)
  return { { string.rep("─", math.max(0, width)), hl or "JmistBorder" } }
end

--- Concatenates lines into a new line.
M.join = function(...)
  local result = {}

  for _, line in ipairs { ... } do
    for _, fragment in ipairs(line) do
      result[#result + 1] = { fragment[1], fragment[2] or "Normal", fragment[3] }
    end
  end

  return result
end

--- Appends a line into another line, mutating the target.
M.append = function(target, line)
  for _, fragment in ipairs(line) do
    target[#target + 1] = fragment
  end

  return target
end

--- Truncates text to a display width and returns the text plus the used width.
M.truncate = function(text, max_width)
  if max_width <= 0 then
    return "", 0
  end

  local used = 0
  local result = {}

  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    local char_width = api.nvim_strwidth(char)

    if used + char_width > max_width then
      break
    end

    result[#result + 1] = char
    used = used + char_width
  end

  return table.concat(result), used
end

--- Pads or truncates text to an exact display width.
M.fit = function(text, width)
  local fitted, used = M.truncate(text, width)
  return fitted .. string.rep(" ", math.max(0, width - used))
end

--- Truncates with an ellipsis when the text does not fit.
M.ellipsize = function(text, width)
  if M.strw(text) <= width then
    return text
  end

  local fitted = M.truncate(text, math.max(0, width - 1))
  return fitted .. "…"
end

--- Truncates a line to an exact display width, preserving its highlights.
--- @param line table
--- @param width number
--- @return table
M.clip = function(line, width)
  local result = {}
  local used = 0

  for _, fragment in ipairs(line) do
    local text = fragment[1]
    local text_width = M.strw(text)

    if used + text_width <= width then
      result[#result + 1] = { text, fragment[2] or "Normal", fragment[3] }
      used = used + text_width
    else
      local remaining = width - used

      if remaining > 0 then
        local fitted = M.truncate(text, remaining - 1)
        result[#result + 1] = { fitted .. "…", fragment[2] or "Normal", fragment[3] }
        used = width
      end

      break
    end
  end

  if used < width then
    result[#result + 1] = { string.rep(" ", width - used), "Normal" }
  end

  return result
end

--- Builds a line with left and right aligned content.
--- The right side is dropped when there is no room for at least one space.
M.row = function(width, left, right)
  local left_width = M.width(left)
  local right_width = right and M.width(right) or 0
  local gap = width - left_width - right_width

  local result = {}
  M.append(result, left)

  if right and gap >= 1 then
    result[#result + 1] = { string.rep(" ", gap), "Normal" }
    M.append(result, right)
  else
    result[#result + 1] = { string.rep(" ", math.max(0, width - left_width)), "Normal" }
  end

  return result
end

--- Pads a list of lines to an exact height with blank full-width lines.
M.finish = function(lines, height, width)
  local result = {}

  for i = 1, height do
    local line = lines[i]

    if not line or #line == 0 then
      line = M.blank(width)
    end

    result[i] = line
  end

  return result
end

--- Compact keyboard hints: { { "j/k", "move" }, ... }
M.key_hints = function(entries)
  local line = {}

  for i, entry in ipairs(entries) do
    if i > 1 then
      line[#line + 1] = { "  ·  ", "JmistDim" }
    end

    line[#line + 1] = { entry[1], "JmistKey" }
    line[#line + 1] = { " " .. entry[2], "JmistMuted" }
  end

  return line
end

return M
