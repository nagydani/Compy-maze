-- script.lua

-- Expand counted loops: 3R -> RRR

function expand_loops(text)
  return text:gsub("(%d+)([%a%.])", function(n, ch)
    return ch:rep(n)
  end)
end

-- Replace macro letters with their contents

function expand_macros(text)
  local result = ""
  for i = 1, #text do
    local ch = text:sub(i, i)
    result = result .. (macros[ch] or ch)
  end
  return result
end

-- Expand loops and macros

function expand(text)
  local expanded = expand_loops(text:upper())
  return expand_macros(expanded)
end

-- Define a macro: X=3RF

function define_macro(line)
  local name = line:sub(1, 1):upper()
  macros[name] = expand(line:sub(3))
end

-- Validate a single line

function is_valid_line(line)
  if line == "" then
    return true
  elseif line:match("^%a=[%a%d%.]+$") then
    local name = line:sub(1, 1):upper()
    return not PRIMITIVES[name]
  else
    return line:match("^[%a%d%.]+$") ~= nil
  end
end

-- Validate all lines

function validate_input(lines)
  for _, line in ipairs(lines) do
    if not is_valid_line(line) then
      return false
    end
  end
  return true
end

-- Expand a line into primitives with back pointers.
-- Returns { {cmd = ch, col_from = F, col_to = T},
-- ... } where F..T span the source columns of the
-- symbol — macro letter, loop digit-letter pair,
-- or primitive.

function expand_with_refs(line)
  local prims = { }
  local i = 1
  while i <= #line do
    local ch = line:sub(i, i)
    if ch:match("%d") then
      i = expand_loop_at(line, i, prims)
    else
      append_one(prims, ch, i, i)
      i = i + 1
    end
  end
  return prims
end

function expand_loop_at(line, i, prims)
  local num_str = line:sub(i):match("^(%d+)")
  local n = tonumber(num_str)
  local col = i + #num_str
  local ch = line:sub(col, col)
  for _ = 1, n do
    append_one(prims, ch, i, col)
  end
  return col + 1
end

function append_one(prims, ch, col_from, col_to)
  if macros[ch] then
    append_macro(prims, macros[ch], col_from, col_to)
  else
    table.insert(prims, {
      cmd = ch, 
      col_from = col_from, 
      col_to = col_to
    })
  end
end

function append_macro(prims, body, col_from, col_to)
  for j = 1, #body do
    table.insert(prims, {
      cmd = body:sub(j, j),
      col_from = col_from,
      col_to = col_to
    })
  end
end

function enqueue_commands(line_idx, line)
  local prims = expand_with_refs(line:upper())
  for _, p in ipairs(prims) do
    table.insert(player.queue, p.cmd)
    table.insert(player.queue_refs, {
      line = line_idx,
      col_from = p.col_from,
      col_to = p.col_to
    })
    if p.cmd ~= "." then
      sfx.ping()
    end
  end
end

-- Process a single line

function process_line(line_idx, line)
  if line == "" then
    return 
  elseif line:match("^%a=") then
    define_macro(line)
  else
    enqueue_commands(line_idx, line)
  end
end

-- Process entire input

function process_input(lines, start_offset)
  if not validate_input(lines) then
    return false
  end
  for i, line in ipairs(lines) do
    process_line(start_offset + i, line)
  end
  return true
end
