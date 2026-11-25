--  ██████╗  ██╗ ██╗   ██╗ ██╗
--  ██╔══██╗ ██║ ██║   ██║ ██║
--  ██║  ██║ ██║ ██║   ██║ ██║
--  ██║  ██║ ██║ ╚██╗ ██╔╝ ██║
--  ██████╔╝ ██║  ╚████╔╝  ██║
--  ╚═════╝  ╚═╝   ╚═══╝   ╚═╝
--
--  DIVI · a personal Neovim distribution built on LazyVim.
--  Your settings live in lua/divi/settings.lua  —  run :Divi for the panel.

-- bootstrap lazy.nvim, LazyVim and the DIVI plugins
require("config.lazy")

-- DIVI's own layer: commands, keymaps, theme hooks
require("divi")
