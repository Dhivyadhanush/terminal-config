-- DIVI · debugging (breakpoints, step through, inspect)
-- LazyVim's dap.core extra provides nvim-dap + dap-ui + the <leader>d* map;
-- here we install the adapters and add F-key shortcuts.
local S = require("divi.settings")

if not S.features.debug then
  return {}
end

return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = S.debug.adapters,
      automatic_installation = true,
      handlers = {},
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local exe = vim.fn.exepath("debugpy-adapter")
      if exe == "" then
        exe = vim.fn.stdpath("data") .. "/mason/bin/debugpy-adapter"
      end
      require("dap-python").setup(exe, { include_configs = true })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: run/continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Debug: eval", mode = { "n", "x" } },
    },
  },
}
