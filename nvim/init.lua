-- ~/.config/nvim/init.lua
-- Minimal starter config. Everything here is optional; Neovim works without it.

-- Line numbers: absolute on the cursor line, distance from cursor elsewhere.
vim.opt.number = true
vim.opt.relativenumber = true

-- Colours
vim.opt.termguicolors = true      -- 24-bit colour (needs a modern terminal)
vim.cmd("syntax on")              -- syntax highlighting on
vim.cmd.colorscheme("catppuccin") -- try :colorscheme <Tab> to preview others
