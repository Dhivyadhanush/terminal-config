-- DIVI · opencode (AI) keymaps
-- The logic lives in lua/divi/ai.lua so you can call it from anywhere.
local S = require("divi.settings")

if not S.features.ai then
  return {}
end

return {
  {
    "snacks.nvim",
    keys = {
      { "<leader>aa", function() require("divi.ai").toggle() end, desc = "Chat (floating)" },
      {
        "<leader>ae",
        function() require("divi.ai").explain() end,
        desc = "Explain file",
      },
      {
        "<leader>ae",
        mode = "x",
        ":<C-u>lua require('divi.ai').explain_selection()<cr>",
        desc = "Explain selection",
      },
      { "<leader>ar", function() require("divi.ai").review_file() end, desc = "Review file" },
      { "<leader>aq", function() require("divi.ai").ask() end, desc = "Ask…" },
      { "<leader>ac", function() require("divi.ai").follow_up() end, desc = "Follow up (last session)" },
    },
  },
}
