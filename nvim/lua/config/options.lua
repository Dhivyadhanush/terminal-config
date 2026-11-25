-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Same as your old config
vim.opt.relativenumber = true -- absolute on cursor line, relative elsewhere
vim.opt.termguicolors = true

-- Editor feel (closer to a GUI IDE)
vim.opt.scrolloff = 8 -- keep 8 lines of context around the cursor
vim.opt.sidescrolloff = 8
vim.opt.wrap = false -- no soft wrapping, like IntelliJ's default
vim.opt.clipboard = "unnamedplus" -- y/p talk to the macOS clipboard
vim.opt.splitright = true -- vertical splits open to the right
vim.opt.splitbelow = true -- horizontal splits open below
vim.opt.undofile = true -- persistent undo across restarts
vim.opt.mouse = "a" -- mouse clicks/resizes work, Vim keys still rule
vim.opt.updatetime = 250 -- faster diagnostics + git signs
vim.opt.confirm = true -- ask to save instead of failing on :q
