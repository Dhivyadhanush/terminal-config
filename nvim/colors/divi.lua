-- DIVI colorscheme
-- Usage: :colorscheme divi   (DIVI already selects it on startup)
--
-- The palette is built by lua/divi/theme.lua, which reads the active Ghostty
-- theme, so the editor and the terminal share the same colours.
local function apply()
  local S = require("divi.settings")
  require("catppuccin").setup({
    flavour = "mocha",
    color_overrides = { mocha = require("divi.theme").palette },
    transparent_background = S.transparent,
  })
  vim.cmd("colorscheme catppuccin-mocha")
  vim.g.colors_name = "divi"
  require("divi.theme").extra()
end

if not pcall(apply) then
  -- catppuccin not loaded yet: show something sane, then try again once the
  -- plugins are up (instead of leaving a half-themed editor behind).
  vim.cmd("colorscheme habamax")
  vim.schedule(function()
    pcall(apply)
  end)
end
