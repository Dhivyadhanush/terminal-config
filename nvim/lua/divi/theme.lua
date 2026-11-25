-- DIVI theme: catppuccin mocha as the engine, with the DIVI palette and a few
-- extra highlight groups. A colorscheme file (instead of a plugin spec) means
-- `:colorscheme divi` works like any other scheme.
local M = {}

local S = require("divi.settings")

M.palette = {
  -- deep, near-black background instead of the default #1e1e2e
  base = "#0f1117",
  mantle = "#0b0d12",
  crust = "#08090d",
  surface0 = "#171a22",
  surface1 = "#20242e",
  surface2 = "#2b3140",
  overlay0 = "#3d4454",
  overlay1 = "#525a6d",
  overlay2 = "#6b7488",
  subtext0 = "#8f99ae",
  subtext1 = "#b6bfd1",
  text = "#dfe4f0",

  lavender = "#b7bcff",
  blue = S.accent,
  sapphire = S.accent,
  sky = S.accent2,
  teal = S.accent2,
  green = "#7ee787",
  yellow = "#ffd280",
  peach = "#ffab8a",
  maroon = "#f08a8a",
  red = "#ff7a8a",
  mauve = "#c6a5ff",
  pink = "#ff9ad5",
  flamingo = "#ffb3c8",
  rosewater = "#ffd6e0",
}

--- Extra highlight groups applied on top of catppuccin.
function M.extra()
  local p = M.palette
  local hl = vim.api.nvim_set_hl
  local set = function(name, opts)
    pcall(hl, 0, name, opts)
  end

  -- DIVI brand groups (used by the dashboard + statusline)
  set("DiviBrand", { fg = S.accent, bold = true })
  set("DiviAccent", { fg = S.accent2, bold = true })
  set("DiviDim", { fg = p.overlay0, italic = true })
  set("DiviProject", { fg = p.text, bg = p.surface0, bold = true })

  -- Dashboard (snacks)
  set("SnacksDashboardHeader", { fg = S.accent })
  set("SnacksDashboardIcon", { fg = S.accent2 })
  set("SnacksDashboardKey", { fg = S.accent, bold = true })
  set("SnacksDashboardDesc", { fg = p.subtext1 })
  set("SnacksDashboardDir", { fg = p.overlay1 })
  set("SnacksDashboardFile", { fg = p.text })
  set("SnacksDashboardSpecial", { fg = p.mauve })
  set("SnacksDashboardFooter", { fg = p.overlay0, italic = true })
  set("SnacksDashboardTitle", { fg = S.accent, bold = true })

  -- editor polish
  set("CursorLineNr", { fg = S.accent, bold = true })
  set("LineNr", { fg = p.overlay0 })
  set("WinSeparator", { fg = p.surface2 })
  set("FloatBorder", { fg = p.surface2, bg = "NONE" })
  set("Visual", { bg = p.surface1 })
  set("Search", { bg = p.surface2, fg = p.text })
  set("IncSearch", { bg = S.accent, fg = p.base, bold = true })
  set("PmenuSel", { bg = p.surface1 })
  set("Directory", { fg = S.accent })
  set("Title", { fg = S.accent, bold = true })
  set("Comment", { fg = p.overlay1, italic = true })
  set("DiagnosticVirtualTextError", { bg = p.base })
  set("DiagnosticVirtualTextWarn", { bg = p.base })
end

return M
