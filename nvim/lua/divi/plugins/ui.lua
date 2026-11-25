-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · look & feel                                              ║
-- ║  The branded start screen, the statusline and the tab bar.        ║
-- ╚══════════════════════════════════════════════════════════════════╝
local S = require("divi.settings")
local P = require("divi.theme").palette

local header = table.concat({
  "",
  [[██████╗  ██╗ ██╗   ██╗ ██╗]],
  [[██╔══██╗ ██║ ██║   ██║ ██║]],
  [[██║  ██║ ██║ ██║   ██║ ██║]],
  [[██║  ██║ ██║ ╚██╗ ██╔╝ ██║]],
  [[██████╔╝ ██║  ╚████╔╝  ██║]],
  [[╚═════╝  ╚═╝   ╚═══╝   ╚═╝]],
  "",
  "        " .. S.tagline,
  "",
}, "\n")

return {
  -- ── start screen ────────────────────────────────────────────────
  {
    "snacks.nvim",
    opts = function(_, opts)
      if not S.features.dashboard then
        return opts
      end
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = header
      ---@type snacks.dashboard.Item[]
      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "a", desc = "Ask opencode", action = ":lua require('divi.ai').ask()" },
        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        { icon = " ", key = "c", desc = "DIVI Config", action = ":Divi" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }
      return opts
    end,
  },

  -- ── statusline ──────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = {
        normal = {
          a = { fg = P.base, bg = S.accent, gui = "bold" },
          b = { fg = P.text, bg = P.surface0 },
          c = { fg = P.subtext0, bg = P.base },
        },
        insert = { a = { fg = P.base, bg = P.teal, gui = "bold" } },
        visual = { a = { fg = P.base, bg = P.mauve, gui = "bold" } },
        replace = { a = { fg = P.base, bg = P.peach, gui = "bold" } },
        command = { a = { fg = P.base, bg = P.yellow, gui = "bold" } },
        terminal = { a = { fg = P.base, bg = P.green, gui = "bold" } },
        inactive = {
          a = { fg = P.overlay1, bg = P.mantle },
          b = { fg = P.overlay1, bg = P.mantle },
          c = { fg = P.overlay1, bg = P.mantle },
        },
      }

      local icons = LazyVim.config.icons

      opts.sections = {
        lualine_a = { { "mode", padding = { left = 1, right = 1 } } },
        lualine_b = {
          { "branch", icon = " ", color = { fg = P.subtext1 } },
          {
            "diff",
            symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
          },
        },
        lualine_c = {
          {
            function()
              return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
            end,
            color = function()
              return { fg = S.accent, bg = P.surface0, gui = "bold" }
            end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path() },
        },
        lualine_x = {
          {
            function()
              return " " .. require("dap").status()
            end,
            cond = function()
              return package.loaded["dap"] and require("dap").status() ~= ""
            end,
            color = { fg = P.red },
          },
          { "encoding" },
          { "fileformat" },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          {
            function()
              return " " .. S.name .. " "
            end,
            color = { fg = P.base, bg = S.accent, gui = "bold" },
          },
        },
      }
      return opts
    end,
  },

  -- ── tab bar ─────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        show_close_icon = false,
        separator_style = "slant",
        indicator = { style = "underline" },
        tab_size = 20,
      },
    },
  },
}
