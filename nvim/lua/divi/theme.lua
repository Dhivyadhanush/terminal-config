-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  DIVI · theme engine                                             ║
-- ║  Reads your Ghostty theme (background, foreground, ANSI palette,  ║
-- ║  cursor) and turns it into the DIVI palette, so the editor and    ║
-- ║  the terminal are the same colours. Change the Ghostty theme and   ║
-- ║  Neovim follows — :DiviReload.                                    ║
-- ╚══════════════════════════════════════════════════════════════════╝
local S = require("divi.settings")

local M = {}

-- ── colour helpers ────────────────────────────────────────────────
local function hex(col)
  if type(col) ~= "string" then
    return nil
  end
  col = col:gsub("^#", "")
  if #col ~= 6 or col:find("%X") then
    return nil
  end
  return tonumber(col, 16)
end

local function tohex(r, g, b)
  local function c(x)
    return math.max(0, math.min(255, math.floor(x + 0.5)))
  end
  return string.format("#%02x%02x%02x", c(r), c(g), c(b))
end

--- r, g, b from a 0xRRGGBB number
local function rgb(n)
  return math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
end

--- Blend two hex colours. t = 0 -> a, t = 1 -> b.
local function mix(a, b, t)
  local ca, cb = hex(a), hex(b)
  if not ca or not cb then
    return a
  end
  local ar, ag, ab = rgb(ca)
  local br, bg_, bb = rgb(cb)
  local r = ar * (1 - t) + br * t
  local g = ag * (1 - t) + bg_ * t
  local bl = ab * (1 - t) + bb * t
  return tohex(r, g, bl)
end
M.mix = mix

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

--- Strip the background from a highlight group, keeping its colours.
local function no_bg(name)
  local cur = vim.api.nvim_get_hl(0, { name = name, link = false })
  if type(cur) ~= "table" then
    return
  end
  cur.bg = nil
  pcall(vim.api.nvim_set_hl, 0, name, cur)
end

-- ── ghostty theme parsing ─────────────────────────────────────────
---@class divi.GhosttyTheme
---@field bg string
---@field fg? string
---@field cursor? string
---@field selection? string
---@field palette table<number, string>

local function parse(text)
  local t = { palette = {} }
  for line in text:gmatch("[^\n]+") do
    local key, val = line:match("^%s*([%w%-_]+)%s*=%s*(%S+)")
    if key then
      if key == "palette" then
        local idx, col = val:match("^(%d+)=(#%x+)")
        if idx then
          t.palette[tonumber(idx)] = col
        end
      elseif key == "background" then
        t.bg = val
      elseif key == "foreground" then
        t.fg = val
      elseif key == "cursor-color" then
        t.cursor = val
      elseif key == "selection-background" then
        t.selection = val
      end
    end
  end
  if not t.bg then
    return nil
  end
  return t
end

--- Read ~/.config/ghostty/{config,themes/*} and return the active colours.
---@return divi.GhosttyTheme?
function M.read_terminal_theme()
  local dir = vim.fn.expand("~/.config/ghostty")
  local cfg = read(dir .. "/config") or ""

  local name
  for line in cfg:gmatch("[^\n]+") do
    local k, v = line:match("^%s*([%w%-_]+)%s*=%s*(%S+)")
    if k == "theme" then
      name = v
    end
  end

  if name then
    name = name:match(":(.+)$") or name -- "light:dark" -> dark
    for _, path in ipairs({ dir .. "/themes/" .. name, name }) do
      local txt = read(path)
      local theme = txt and parse(txt)
      if theme then
        theme.source = path
        return theme
      end
    end
  end

  -- theme is a Ghostty built-in, or the colours are set inline
  local inline = parse(cfg)
  if inline then
    inline.source = dir .. "/config"
  end
  return inline
end

-- ── DIVI palette ──────────────────────────────────────────────────
--- Static fallback used when no Ghostty theme can be read.
local fallback = {
  base = "#0f1117",
  mantle = "#0b0d12",
  crust = "#08090d",
  surface0 = "#171a22",
  surface1 = "#20242e",
  surface2 = "#2b3140",
  overlay0 = "#3d4454",
  overlay1 = "#525a6d",
  overlay2 = "#6b7488",
  subtext0 = "#8f99ae",
  subtext1 = "#b6bfd1",
  text = "#dfe4f0",
  lavender = "#b7bcff",
  blue = "#8b9dff",
  sapphire = "#8b9dff",
  sky = "#5ee0c8",
  teal = "#5ee0c8",
  green = "#7ee787",
  yellow = "#ffd280",
  peach = "#ffab8a",
  maroon = "#f08a8a",
  red = "#ff7a8a",
  mauve = "#c6a5ff",
  pink = "#ff9ad5",
  flamingo = "#ffb3c8",
  rosewater = "#ffd6e0",
}

--- Turn a terminal theme into the 26 colours catppuccin expects.
---@param t divi.GhosttyTheme
local function derive(t)
  local bg = t.bg
  local fg = t.fg or "#d3c6aa"
  local p = t.palette or {}
  local function c(i, fb)
    return p[i] or fb
  end

  return {
    -- surfaces: the terminal background, with UI greys blended from fg
    base = bg,
    mantle = mix(bg, "#000000", 0.28),
    crust = mix(bg, "#000000", 0.45),
    surface0 = mix(bg, fg, 0.10),
    surface1 = mix(bg, fg, 0.17),
    surface2 = mix(bg, fg, 0.25),
    overlay0 = mix(bg, fg, 0.42),
    overlay1 = mix(bg, fg, 0.56),
    overlay2 = mix(bg, fg, 0.70),
    subtext0 = mix(bg, fg, 0.78),
    subtext1 = mix(bg, fg, 0.90),
    text = fg,

    -- ANSI 16 -> semantic colours
    red = c(1, "#e67e80"),
    maroon = mix(c(1, "#e67e80"), bg, 0.22),
    green = c(2, "#a7c080"),
    yellow = c(3, "#dbbc7f"),
    blue = c(4, "#7fbbb3"),
    mauve = c(5, "#d699b6"),
    teal = c(6, "#83c092"),
    rosewater = c(7, fg),
    peach = t.cursor or c(9, "#e69875"),
    pink = c(13, c(5, "#d699b6")),
    flamingo = mix(c(13, c(5, "#d699b6")), fg, 0.25),
    sky = c(12, c(4, "#7fbbb3")),
    sapphire = c(4, "#7fbbb3"),
    lavender = mix(c(5, "#d699b6"), fg, 0.30),
  }
end

local terminal
if S.use_terminal_theme then
  local ok, theme = pcall(M.read_terminal_theme)
  if ok and theme then
    terminal = theme
  end
end

M.terminal = terminal
M.palette = terminal and derive(terminal) or fallback
M.cursor = terminal and terminal.cursor or nil
M.selection = terminal and terminal.selection or nil
M.source = terminal and terminal.source or "built-in fallback"

local function resolved(value, auto)
  if type(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
    return value
  end
  return auto
end

-- "auto" -> take the accent straight from the terminal theme
M.accent = resolved(S.accent, M.cursor or M.palette.blue)
M.accent2 = resolved(S.accent2, M.palette.teal)

-- ── highlight groups on top of catppuccin ─────────────────────────
function M.extra()
  local p = M.palette
  local hl = vim.api.nvim_set_hl
  local set = function(name, opts)
    pcall(hl, 0, name, opts)
  end

  -- DIVI brand groups (dashboard + statusline)
  set("DiviBrand", { fg = M.accent, bold = true })
  set("DiviAccent", { fg = M.accent2, bold = true })
  set("DiviDim", { fg = p.overlay0, italic = true })
  set("DiviProject", { fg = p.text, bg = p.surface0, bold = true })

  -- Dashboard (snacks)
  set("SnacksDashboardHeader", { fg = M.accent })
  set("SnacksDashboardIcon", { fg = M.accent2 })
  set("SnacksDashboardKey", { fg = M.accent, bold = true })
  set("SnacksDashboardDesc", { fg = p.subtext1 })
  set("SnacksDashboardDir", { fg = p.overlay1 })
  set("SnacksDashboardFile", { fg = p.text })
  set("SnacksDashboardSpecial", { fg = p.mauve })
  set("SnacksDashboardFooter", { fg = p.overlay0, italic = true })
  set("SnacksDashboardTitle", { fg = M.accent, bold = true })

  -- editor polish
  set("CursorLineNr", { fg = M.accent, bold = true })
  set("LineNr", { fg = p.overlay0 })
  set("WinSeparator", { fg = p.surface2 })
  set("FloatBorder", { fg = p.surface2, bg = "NONE" })
  set("Visual", { bg = M.selection or p.surface1 })
  set("Search", { bg = p.surface2, fg = p.text })
  set("IncSearch", { bg = M.accent, fg = p.base, bold = true })
  set("PmenuSel", { bg = p.surface1 })
  set("Directory", { fg = M.accent })
  set("Title", { fg = M.accent, bold = true })
  set("Comment", { fg = p.overlay1, italic = true })
  set("DiagnosticVirtualTextError", { bg = "NONE" })
  set("DiagnosticVirtualTextWarn", { bg = "NONE" })

  -- cursor: match Ghostty's cursor colour so it looks like the same app
  if M.cursor then
    set("Cursor", { fg = p.base, bg = M.cursor })
    set("TermCursor", { fg = p.base, bg = M.cursor })
    set("lCursor", { fg = p.base, bg = M.cursor })
  end

  -- ── transparency ──────────────────────────────────────────────
  -- Remove every solid panel background so Ghostty's opacity + blur shows
  -- through the editor, popups, statusline and tab bar.
  if S.transparent then
    for _, group in ipairs({
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "FloatTitle",
      "FloatFooter",
      "StatusLine",
      "StatusLineNC",
      "TabLine",
      "TabLineFill",
      "Pmenu",
      "PmenuSbar",
      "PmenuThumb",
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBuffer",
      "BufferLineBufferSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorSelected",
      "BufferLineTabSelected",
      "SignColumn",
      "FoldColumn",
      "WinSeparator",
      "SnacksPicker",
      "TroubleNormal",
      "TroubleNormalNC",
    }) do
      no_bg(group)
    end
    vim.o.winblend = S.blend or 0
    vim.o.pumblend = S.blend or 0
  else
    vim.o.winblend = 0
    vim.o.pumblend = 0
  end
end

return M
