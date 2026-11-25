-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · keymaps                                                  ║
-- ║  IDE shortcuts on top of the Vim defaults. Nothing here removes   ║
-- ║  a Vim key: hjkl, dd, ciw, /, u … all still work.                 ║
-- ║  Add or change yours in this file, then :DiviReload               ║
-- ╚══════════════════════════════════════════════════════════════════╝

local S = require("divi.settings")
local map = vim.keymap.set

if S.features.intellij_keys then
  -- IntelliJ / VS Code muscle memory
  map("n", "<C-p>", function()
    Snacks.picker.files()
  end, { desc = "Find file (Ctrl+P)" })

  map("n", "<A-1>", function()
    Snacks.explorer()
  end, { desc = "Project tree (Alt+1)" })

  map("n", "<A-2>", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Git (Alt+2)" })

  map("n", "<A-3>", function()
    Snacks.terminal(nil, { cwd = LazyVim.root() })
  end, { desc = "Terminal (Alt+3)" })

  map("n", "<A-4>", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Problems (Alt+4)" })

  map("n", "<A-5>", function()
    Snacks.picker.lsp_symbols()
  end, { desc = "Symbols (Alt+5)" })

  map("n", "<A-6>", "<cmd>Obsidian quick_switch<cr>", { desc = "Notes (Alt+6)" })

  -- Run / debug the current file, like the green arrow in an IDE
  map("n", "<leader>rr", function()
    require("divi.run").run_file()
  end, { desc = "Run current file" })

  map("n", "<leader>rd", function()
    require("divi.run").debug_file()
  end, { desc = "Debug current file" })

  map("n", "<leader>rt", function()
    require("divi.run").run_tests()
  end, { desc = "Run tests" })
end

-- which-key group labels (so <leader>x opens a named menu)
pcall(function()
  require("which-key").add({
    { "<leader>a", group = "AI · opencode" },
    { "<leader>n", group = "Notes" },
    { "<leader>r", group = "Run / Debug" },
    { "<leader>D", desc = "Database (DBUI)" },
  })
end)
