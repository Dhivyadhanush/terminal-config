-- DIVI · the layer that sits on top of LazyVim.
-- Loaded from init.lua after lazy.nvim has registered every plugin spec.
if vim.g.divi_loaded then
  return
end

local S = require("divi.settings")

vim.g.divi_loaded = true
vim.g.divi_name = S.name
vim.g.divi_version = S.version

require("divi.commands")
require("divi.keymaps")

-- Keep DIVI's extra highlight groups alive across colorscheme switches.
-- The scheduled pass runs after plugins (bufferline, lualine, …) have set
-- their own groups, so our transparency overrides win.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("DiviTheme", { clear = true }),
  callback = function()
    require("divi.theme").extra()
    vim.schedule(function()
      pcall(function()
        require("divi.theme").extra()
      end)
    end)
  end,
})
