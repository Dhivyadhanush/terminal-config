-- DIVI · notes: your Obsidian vault inside the editor
local S = require("divi.settings")

if not S.features.notes then
  return {}
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = { "Obsidian" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>no", "<cmd>Obsidian quick_switch<cr>", desc = "Switch note" },
      { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>nd", "<cmd>Obsidian today<cr>", desc = "Today's note" },
      { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search vault" },
      { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "Tags" },
    },
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = "vault", path = S.notes.vault },
      },
      picker = { name = "snacks.picker" },
      daily_notes = { folder = S.notes.daily },
      completion = { min_chars = 2 },
      ui = { enable = false },
    },
  },
}
