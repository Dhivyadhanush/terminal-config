-- DIVI · run & debug the current file (the green ▶ button, terminal edition)
local M = {}

local runners = {
  python = { "python3", "-u", "%" },
  javascript = { "node", "%" },
  typescript = { "npx", "--yes", "tsx", "%" },
  lua = { "nvim", "-l", "%" },
  go = { "go", "run", "%" },
  sh = { "bash", "%" },
  bash = { "bash", "%" },
  zsh = { "zsh", "%" },
  ruby = { "ruby", "%" },
  php = { "php", "%" },
  rust = { "cargo", "run" },
}

local function notify(msg, level)
  vim.notify("[DIVI] " .. msg, level or vim.log.levels.INFO)
end

local function current_file()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    notify("This buffer has no file yet — write it first (:w).", vim.log.levels.WARN)
    return nil
  end
  vim.cmd("write")
  return vim.fn.expand("%:p")
end

--- Run the current buffer in a terminal window.
function M.run_file()
  local tmpl = runners[vim.bo.filetype]
  if not tmpl then
    notify(("No runner for filetype '%s'. Add one in lua/divi/run.lua"):format(vim.bo.filetype), vim.log.levels.WARN)
    return
  end
  local file = current_file()
  if not file then
    return
  end

  local argv = {}
  for _, arg in ipairs(tmpl) do
    argv[#argv + 1] = (arg == "%") and file or arg
  end

  Snacks.terminal(argv, { cwd = LazyVim.root(), interactive = false })
end

--- Start a debug session on the current file.
function M.debug_file()
  local ok, dap = pcall(require, "dap")
  if not ok then
    notify("nvim-dap is not loaded.", vim.log.levels.ERROR)
    return
  end

  local file = current_file()
  if not file then
    return
  end

  local ft = vim.bo.filetype
  local cwd = LazyVim.root()

  if ft == "python" then
    dap.run({
      type = "python",
      request = "launch",
      program = file,
      cwd = cwd,
      console = "integratedTerminal",
      justMyCode = true,
    })
  elseif ft == "javascript" or ft == "typescript" or ft == "typescriptreact" then
    dap.run({
      type = "pwa-node",
      request = "launch",
      program = file,
      cwd = cwd,
      console = "integratedTerminal",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
    })
  else
    -- No adapter for this filetype: resume whatever session is configured
    dap.continue()
  end
end

--- Run the project's test suite.
function M.run_tests()
  local cwd = LazyVim.root()
  local cmd

  if vim.fn.filereadable(cwd .. "/package.json") == 1 then
    cmd = { "npm", "test" }
  elseif
    vim.fn.filereadable(cwd .. "/pyproject.toml") == 1
    or vim.fn.filereadable(cwd .. "/pytest.ini") == 1
    or vim.fn.filereadable(cwd .. "/setup.py") == 1
  then
    cmd = { "python3", "-m", "pytest", "-q" }
  else
    notify("No test runner detected (package.json / pyproject.toml).", vim.log.levels.WARN)
    return
  end

  Snacks.terminal(cmd, { cwd = cwd, interactive = false })
end

return M
