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
  table.insert(macro_state.body, key:upper())
  sfx.toggle()
  if MAX_MACRO_LEN <= #(macro_state.body) then
    finish_recording()
  end
end

-- Finish recording: expand and save

function finish_recording()
  if not macro_state.recording then
    return 
  end
  macro_state.recording = false
  local result = ""
  for _, k in ipairs(macro_state.body) do
    result = result .. (macros[k] or k)
  end
  macros[macro_state.name] = result ~= "" and result or nil
end

-- Execute a key: expand macro if defined

function execute_key(key)
  local upper = key:upper()
  local expanded = macros[upper] or upper
  for i = 1, #expanded do
    local ch = expanded:sub(i, i)
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
