-- script.lua

-- Macro definitions

macros = { }

PRIMITIVES = {
  N = true,
  E = true,
  S = true,
  W = true,
  F = true,
  B = true,
  L = true,
  R = true
}

-- Expand counted loops: 3R -> RRR

function expand_loops(text)
  return text:gsub("(%d+)(%a)", function(n, ch)
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
  elseif line:match("^%a=[%a%d]+$") then
    local name = line:sub(1, 1):upper()
    return not PRIMITIVES[name]
  else
    return line:match("^[%a%d]+$") ~= nil
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

-- Add expanded commands to the queue

function enqueue_commands(line)
  local cmds = expand(line)
  for i = 1, #cmds do
    local ch = cmds:sub(i, i)
    if process_cmd(ch) then
      sfx.ping()
    end
  end
end

-- Process a single line

function process_line(line)
  if line == "" then
    return 
  elseif line:match("^%a=") then
    define_macro(line)
  else
    enqueue_commands(line)
  end
end

-- Process entire input

function process_input(lines)
  if not validate_input(lines) then
    return false
  end
  for _, line in ipairs(lines) do
    process_line(line)
  end
  return true
end
