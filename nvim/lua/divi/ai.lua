-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · opencode integration                                     ║
-- ║  Talk to your AI agent from inside the editor. Code is sent as    ║
-- ║  part of the prompt, so it works in any project, no temp files.   ║
-- ╚══════════════════════════════════════════════════════════════════╝
local M = {}

local S = require("divi.settings")

local function notify(msg, level)
  vim.notify("[DIVI] " .. msg, level or vim.log.levels.INFO)
end

local function available()
  if vim.fn.executable(S.ai.command) == 1 then
    return true
  end
  notify(("`%s` is not in PATH. Install it or change divi.settings.ai.command"):format(S.ai.command), vim.log.levels.ERROR)
  return false
end

--- Open a long-running process (the opencode TUI) in a floating terminal.
local function chat(args)
  Snacks.terminal(args, { cwd = LazyVim.root(), interactive = true })
end

--- Run a one-shot prompt; the window stays open so you can read the answer.
local function once(args)
  Snacks.terminal(args, { cwd = LazyVim.root(), interactive = false })
end

local function context()
  local file = vim.fn.expand("%:.")
  if file == "" then
    file = "untitled"
  end
  local ft = vim.bo.filetype
  return file, ft
end

local function fenced(code, ft)
  ft = (ft ~= "" and ft ~= "text") and ft or ""
  return "```" .. ft .. "\n" .. code .. "\n```"
end

--- Whole current buffer.
local function buffer_code()
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

--- Visual selection (uses the '< and '> marks).
local function visual_code()
  local start = vim.fn.getpos("'<")
  local finish = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start[2], finish[2])
  if type(lines) == "string" then
    lines = { lines }
  end
  if #lines == 0 or (start[2] == 0) then
    return nil
  end
  lines[1] = lines[1]:sub(start[3])
  lines[#lines] = lines[#lines]:sub(1, finish[3])
  return table.concat(lines, "\n")
end

--- Toggle the opencode chat window.
function M.toggle()
  if not available() then
    return
  end
  chat({ S.ai.command })
end

--- Explain the whole current file.
function M.explain()
  if not available() then
    return
  end
  local file, ft = context()
  local msg = ("Explain this %s code from %s. Be concise: what it does, anything surprising, and gotchas.\n\n%s")
    :format(ft ~= "" and ft or "code", file, fenced(buffer_code(), ft))
  once({ S.ai.command, "run", msg })
end

--- Explain the visual selection (call from visual mode).
function M.explain_selection()
  if not available() then
    return
  end
  local file, ft = context()
  local code = visual_code() or buffer_code()
  local msg = ("Explain this %s code from %s. Be concise: what it does, anything surprising, and gotchas.\n\n%s")
    :format(ft ~= "" and ft or "code", file, fenced(code, ft))
  once({ S.ai.command, "run", msg })
end

--- Review the current file for bugs / issues.
function M.review_file()
  if not available() then
    return
  end
  local file, ft = context()
  local msg = ("Review %s for bugs, edge cases and code smells. List concrete problems with line references, most important first.\n\n%s")
    :format(file, fenced(buffer_code(), ft))
  once({ S.ai.command, "run", msg })
end

--- Free-form question, with the current file attached for context.
function M.ask()
  if not available() then
    return
  end
  local file, ft = context()
  vim.ui.input({ prompt = "Ask " .. S.ai.command .. ": " }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    local msg = ("%s\n\nContext from %s:\n\n%s"):format(input, file, fenced(buffer_code(), ft))
    once({ S.ai.command, "run", msg })
  end)
end

--- Follow-up on the previous session.
function M.follow_up()
  if not available() then
    return
  end
  vim.ui.input({ prompt = "Follow up: " }, function(input)
    if not input or vim.trim(input) == "" then
      return
    end
    once({ S.ai.command, "run", "-c", input })
  end)
end

return M
