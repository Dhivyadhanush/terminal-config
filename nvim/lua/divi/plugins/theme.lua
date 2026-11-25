-- DIVI · theme engine
-- catppuccin does the heavy lifting; colors/divi.lua applies the DIVI palette
-- on top. Change colours in lua/divi/theme.lua and run :DiviReload.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "divi",
    },
  },
}
