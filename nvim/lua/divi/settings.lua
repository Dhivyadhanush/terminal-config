-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · settings                                                 ║
-- ║  This is your control panel. Everything in DIVI reads from here,  ║
-- ║  so changing a value below changes the whole editor.              ║
-- ║  After editing:  :DiviReload                                      ║
-- ╚══════════════════════════════════════════════════════════════════╝

local M = {
  -- ── identity ────────────────────────────────────────────────────
  name = "DIVI",
  tagline = "a terminal IDE that is yours",
  author = "Divi",
  version = "1.0.0",

  -- ── colours ─────────────────────────────────────────────────────
  -- The palette comes from your Ghostty theme (background, foreground,
  -- ANSI 0-15, cursor). Set "auto" to keep the editor identical to the
  -- terminal, or hardcode a hex value to override one accent.
  use_terminal_theme = true,
  transparent = true, -- let Ghostty's opacity/blur show through Neovim
  blend = 15, -- 0 = crisp popups, 30 = very see-through (winblend/pumblend)
  accent = "auto", -- cursor line, statusline pill, dashboard header
  accent2 = "auto", -- icons, keys, secondary highlights

  -- ── features: set false to turn one off ─────────────────────────
  features = {
    dashboard = true, -- branded start screen
    intellij_keys = true, -- Alt+1..6 / Ctrl+P style shortcuts
    notes = true, -- Obsidian vault + markdown rendering
    ai = true, -- opencode integration
    debug = true, -- breakpoints / DAP
  },

  -- ── projects (the "all my projects" scanner) ────────────────────
  projects = {
    roots = { "~", "~/Documents/project" }, -- where to look
    depth = 3, -- how deep
  },

  -- ── notes ───────────────────────────────────────────────────────
  notes = {
    vault = "~/Documents/Obsidian Vault", -- your Obsidian vault
    daily = "Notes/Daily", -- folder for daily notes, inside the vault
  },

  -- ── AI ──────────────────────────────────────────────────────────
  ai = {
    command = "opencode", -- the CLI binary to launch
  },

  -- ── debug adapters to install through Mason ─────────────────────
  debug = {
    adapters = { "python", "js" },
  },
}

return M
