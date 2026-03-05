-- macro.lua

-- Keyboard macro recording and playback

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

SHIFT_KEYS = {
  lshift = true,
  rshift = true
}

macro_state = {
  recording = false,
  shift_held = false,
  name = nil,
  body = { }
}

-- Start recording: Shift + key pressed

function start_recording(key)
  local name = key:upper()
  if PRIMITIVES[name] then
    sfx.wrong()
    return 
  end
  macro_state.recording = true
  macro_state.name = name
  macro_state.body = { }
  sfx.beep()
end

-- Add a key to macro body

function record_key(key)
  if MAX_MACRO_LEN <= #(macro_state.body) then
    return 
  end
  table.insert(macro_state.body, key:upper())
  sfx.toggle()
end

-- Finish recording: expand and save

function expand_body(body)
  local result = { }
  for _, k in ipairs(body) do
    if macros[k] then
      for _, m in ipairs(macros[k]) do
        table.insert(result, m)
      end
    else
      table.insert(result, k)
    end
  end
  return result
end

function finish_recording()
  if not macro_state.recording then
    return 
  end
  macro_state.recording = false
  local result = expand_body(macro_state.body)
  macros[macro_state.name] = 0 < #result and result or nil
end

-- Execute a key: expand macro if defined

function execute_key(key)
  local upper = key:upper()
  local expanded = macros[upper] or { upper }
  for _, ch in ipairs(expanded) do
    if process_key(ch) then
      sfx.ping()
    end
  end
end

-- Handle non-escape key presses

function handle_key(k)
  if SHIFT_KEYS[k] then
    macro_state.shift_held = true
    return
  elseif macro_state.recording then
    record_key(k)
  elseif macro_state.shift_held then
    start_recording(k)
  else
    execute_key(k)
  end
end
