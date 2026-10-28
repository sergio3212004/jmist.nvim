-- Small, UI-agnostic helpers shared by views and actions.

local M = {}

M.clamp = function(value, min, max)
  if value < min then
    return min
  end

  if value > max then
    return max
  end

  return value
end

--- Keeps the selected row inside the visible window and returns the clamped scroll.
--- @param scroll number Current first visible row (0-based).
--- @param selected number Selected row (1-based).
--- @param visible number Number of rows that fit in the viewport.
--- @param total number Total number of rows.
--- @return number scroll, number max_scroll
M.clamp_scroll = function(scroll, selected, visible, total)
  visible = math.max(1, visible)
  local max_scroll = math.max(0, total - visible)
  scroll = M.clamp(scroll, 0, max_scroll)

  if total == 0 then
    return 0, max_scroll
  end

  if selected - 1 < scroll then
    scroll = selected - 1
  elseif selected - 1 >= scroll + visible then
    scroll = selected - visible
  end

  return M.clamp(scroll, 0, max_scroll), max_scroll
end

--- Returns the first and last visible row (1-based) for a viewport.
--- @return number first, number last
M.visible_range = function(scroll, visible, total)
  local first = math.min(total, scroll + 1)
  local last = math.min(total, scroll + visible)
  return first, last
end

return M
