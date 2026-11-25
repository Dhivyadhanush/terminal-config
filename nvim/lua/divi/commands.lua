-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · commands                                                 ║
-- ║  :Divi          control panel (edit settings, plugins, health…)   ║
-- ║  :DiviReload    re-apply settings, theme and keymaps              ║
-- ║  :DiviVersion   print what you are running                        ║
-- ╚══════════════════════════════════════════════════════════════════╝
local S = require("divi.settings")
local M = {}

local config = vim.fn.stdpath("config")

local function edit(rel)
  vim.cmd.edit(vim.fn.fnamemodify(config .. "/" .. rel, ":p"))
end

--- Reload DIVI modules, theme and keymaps (no restart of Neovim needed).
function M.reload()
  for name in pairs(package.loaded) do
    if name == "divi" or name:match("^divi%.") then
      package.loaded[name] = nil
    end
  end
  package.loaded["divi"] = nil

  pcall(vim.cmd, "colorscheme divi")
  require("divi.keymaps")
  vim.notify(("[%s] settings, theme and keymaps reloaded"):format(S.name), vim.log.levels.INFO)
end

local items = {
  {
    label = "Customize DIVI (settings)",
    desc = "name, colours, features, vault path",
    run = function()
      edit("lua/divi/settings.lua")
    end,
  },
  {
    label = "Edit keymaps",
    desc = "IDE shortcuts, leader keys",
    run = function()
      edit("lua/divi/keymaps.lua")
    end,
  },
  {
    label = "Edit theme / palette",
    desc = "background, accents, highlights",
    run = function()
      edit("lua/divi/theme.lua")
    end,
  },
  {
    label = "Projects",
    desc = "every project on disk",
    run = function()
      Snacks.picker.projects()
    end,
  },
  {
    label = "Notes (Obsidian)",
    desc = "switch note in your vault",
    run = function()
      vim.cmd("Obsidian quick_switch")
    end,
  },
  {
    label = "Ask opencode",
    desc = "AI with the current file as context",
    run = function()
      require("divi.ai").ask()
    end,
  },
  {
    label = "Plugins",
    desc = "add, remove, update (:Lazy)",
    run = function()
      vim.cmd("Lazy")
    end,
  },
  {
    label = "LSP servers & tools",
    desc = "install more languages (:Mason)",
    run = function()
      vim.cmd("Mason")
    end,
  },
  {
    label = "Debug: run / continue",
    desc = "start a debug session (F5)",
    run = function()
      require("dap").continue()
    end,
  },
  {
    label = "Database",
    desc = "DBUI: connections + queries",
    run = function()
      vim.cmd("DBUIToggle")
    end,
  },
  {
    label = "Health check",
    desc = "diagnose the whole setup",
    run = function()
      vim.cmd("checkhealth")
    end,
  },
  {
    label = "All shortcuts",
    desc = "searchable list of every keymap",
    run = function()
      Snacks.picker.keymaps()
    end,
  },
  {
    label = "DIVI manual",
    desc = "all keys in one place",
    run = function()
      edit("README.md")
    end,
  },
  {
    label = "Reload DIVI",
    desc = "after editing settings or keymaps",
    run = function()
      M.reload()
    end,
  },
}

function M.panel()
  local labels = {}
  for i, item in ipairs(items) do
    labels[i] = string.format("%-34s  %s", item.label, item.desc)
  end

  vim.ui.select(labels, {
    prompt = string.format(" %s %s — what do you want to do? ", S.name, S.version),
  }, function(_, idx)
    if idx and items[idx] then
      items[idx].run()
    end
  end)
end

vim.api.nvim_create_user_command("Divi", function()
  M.panel()
end, { desc = "DIVI control panel" })

vim.api.nvim_create_user_command("DiviReload", function()
  M.reload()
end, { desc = "Reload DIVI settings, theme and keymaps" })

vim.api.nvim_create_user_command("DiviVersion", function()
  vim.notify(("%s %s · %s · %s"):format(S.name, S.version, S.tagline, S.author), vim.log.levels.INFO)
end, { desc = "Show DIVI version" })

return M
