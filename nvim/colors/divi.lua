-- DIVI colorscheme
-- Usage: :colorscheme divi   (DIVI already selects it on startup)
local ok = pcall(function()
  require("catppuccin").setup({
    flavour = "mocha",
    color_overrides = { mocha = require("divi.theme").palette },
  })
  vim.cmd("colorscheme catppuccin-mocha")
end)

if not ok then
  vim.cmd("colorscheme habamax")
end

vim.g.colors_name = "divi"
require("divi.theme").extra()
