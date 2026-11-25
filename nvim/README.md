# DIVI

> Part of [terminal-config](../README.md). `install.sh` / `install-macos.sh`
> symlink this folder to `~/.config/nvim`, so edits here are your live config
> and `git pull` updates your editor.

```
██████╗  ██╗ ██╗   ██╗ ██╗
██╔══██╗ ██║ ██║   ██║ ██║
██║  ██║ ██║ ██║   ██║ ██║
██║  ██║ ██║ ╚██╗ ██╔╝ ██║
██████╔╝ ██║  ╚████╔╝  ██║
╚═════╝  ╚═╝   ╚═══╝   ╚═╝
```

A terminal IDE that is yours. Neovim + LazyVim underneath, with a DIVI layer
on top for branding, keymaps, notes, AI, debugging and SQL.

---

## Start here

```sh
cd ~/aetherwave && nvim      # opens your project, tree on the left
nvim                         # DIVI start screen, press p for projects
```

`:Divi` opens the control panel. `:DiviReload` re-applies your edits without
restarting Neovim.

---

## Where things live

Everything DIVI-specific is in one folder, so LazyVim updates never touch it:

```
~/.config/nvim/
├── init.lua                  boot: lazy.nvim + DIVI
├── lazyvim.json              which LazyVim extras are on
├── colors/divi.lua           the "divi" colorscheme
└── lua/
    ├── config/               LazyVim bootstrap (options, lazy.lua)
    └── divi/
        ├── settings.lua      ← your control panel (name, colours, features)
        ├── theme.lua         ← palette + highlight groups
        ├── keymaps.lua       ← your shortcuts
        ├── commands.lua      ← :Divi, :DiviReload, :DiviVersion
        ├── run.lua           ← run / debug current file, run tests
        ├── ai.lua            ← opencode integration (logic)
        └── plugins/
            ├── theme.lua     ← colorscheme wiring
            ├── ui.lua        ← start screen, statusline, tab bar
            ├── projects.lua  ← project scanner
            ├── lsp.lua       ← language servers
            ├── notes.lua     ← Obsidian vault
            ├── ai.lua        ← opencode keymaps
            └── debug.lua     ← DAP adapters + F-keys
```

### Customize in 30 seconds

| Want to change | Edit | Then |
| --- | --- | --- |
| Name on the statusline / start screen | `lua/divi/settings.lua` (`name`) | `:DiviReload` |
| Accent colour | `lua/divi/settings.lua` (`accent`, `accent2`) | `:DiviReload` |
| Background / full palette | `lua/divi/theme.lua` | `:DiviReload` |
| Shortcuts | `lua/divi/keymaps.lua` | `:DiviReload` |
| Turn a feature off | `lua/divi/settings.lua` (`features = {...}`) | restart |
| Note vault path | `lua/divi/settings.lua` (`notes.vault`) | restart |
| Add a plugin | new file in `lua/divi/plugins/` returning a lazy.nvim spec | `:Lazy` |

A plugin, for example `lua/divi/plugins/to-do.lua`:

```lua
return {
  { "folke/todo-comments.nvim", opts = {} },
}
```

---

## The keys that matter

`<Space>` is leader. All stock Vim keys still work (`dd`, `ciw`, `/`, `u` …).

### DIVI's IDE shortcuts

| Keys | Action |
| --- | --- |
| `Ctrl-p` | Find file |
| `Alt-1` | Project tree |
| `Alt-2` | Git (lazygit) |
| `Alt-3` | Terminal |
| `Alt-4` | Problems / diagnostics |
| `Alt-5` | Symbols in this file |
| `Alt-6` | Notes: switch note |
| `<Space>rr` | Run current file |
| `<Space>rd` | Debug current file |
| `<Space>rt` | Run tests |

If your terminal eats `Alt-1`…`Alt-6` (or the F-keys), use the
`<Space>` equivalents below — they always work.

### Projects

| Keys | Action |
| --- | --- |
| `<Space>fp` | Recent + all projects on disk |
| `<Space>fP` | All projects on disk only |
| `<Space>ff` | Find file in project |
| `<Space>/` | Grep the project |
| `<Space>ql` | Reopen last session (your tabs come back) |
| `<Space>qs` / `<Space>qd` | Restore / don't save session |

### Files and explorer

| Keys | Action |
| --- | --- |
| `<Space>e` | Toggle file explorer |
| `<Space>fF` | Find file from cwd |
| `<Space>fg` | Find git-tracked files |
| `Shift-h` / `Shift-l` | Previous / next open file |
| `<Space>bd` | Close file |
| `<Space>|` / `<Space>-` | Split right / below |
| `Ctrl-h/j/k/l` | Move between splits |

In the explorer: `l` open, `a` add, `r` rename, `d` delete (to Trash),
`c` copy, `m` move, `p` paste, `y` yank path, `H` hidden, `.` focus current file.

### Code

| Keys | Action |
| --- | --- |
| `gd` / `gr` / `gI` | Definition / references / implementation |
| `K` | Hover docs |
| `<Space>ca` | Quick fix / code action |
| `<Space>cr` | Rename symbol |
| `<Space>cf` | Format file |
| `<Space>xx` | All diagnostics |
| `<Space>ss` | Symbols in file |
| `]d` / `[d` | Next / previous diagnostic |
| `<Space>uh` | Toggle inlay hints |

### Notes (Obsidian)

| Keys | Action |
| --- | --- |
| `<Space>no` | Switch note (fuzzy over the vault) |
| `<Space>nn` | New note |
| `<Space>nd` | Today's daily note |
| `<Space>ns` | Search vault contents |
| `<Space>nb` | Backlinks |
| `<Space>nt` | Tags |

Markdown renders in place (`<Space>um` toggles rendering).

### AI (opencode)

| Keys | Action |
| --- | --- |
| `<Space>aa` | Chat: opencode in a floating terminal |
| `<Space>ae` | Explain file (or selection in visual mode) |
| `<Space>ar` | Review current file for bugs |
| `<Space>aq` | Ask anything, current file attached |
| `<Space>ac` | Follow up on the last session |

Nothing is sent anywhere until you press one of these; it runs your local
`opencode` CLI in the project directory.

### Debug

| Keys | Action |
| --- | --- |
| `<F5>` | Run / continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<Space>db` | Toggle breakpoint |
| `<Space>du` | Debug UI (variables, stack, breakpoints) |
| `<Space>de` | Eval expression under cursor |
| `<Space>dt` | Terminate |

Python and JS/TS adapters are installed. Add more with `:Mason`
(`delve` for Go, `codelldb` for Rust/C++).

### Database

| Keys | Action |
| --- | --- |
| `<Space>D` | Toggle DBUI (connections tree + query editor) |

Add a connection in the DBUI sidebar, e.g.
`postgres://user@localhost:5432/mydb`, `mysql://root@localhost/db`,
`sqlite:~/data/app.db`. Requires the matching CLI client (`psql`, `mysql`);
SQLite works out of the box.

### Git and terminal

| Keys | Action |
| --- | --- |
| `<Space>gg` | Lazygit (stage/commit/branch/push) |
| `<Space>gs` | Git status picker |
| `<Space>gd` | Diff hunks of this file |
| `]h` / `[h` | Next / previous hunk |
| `<Space>ghs` / `<Space>ghr` | Stage / reset hunk |
| `<Space>ft` | Terminal in project root |
| `<Ctrl-/>` | Hide the terminal |

### Everything else

| Keys | Action |
| --- | --- |
| `<Space>sk` | Search all keymaps |
| `<Space>?` | Keymaps for this buffer |
| `:Divi` | DIVI control panel |
| `:Lazy` | Plugin manager |
| `:Mason` | LSP servers, formatters, adapters |
| `:checkhealth` | Diagnose the setup |

---

## Commands

| Command | What it does |
| --- | --- |
| `:Divi` | Control panel: edit settings, plugins, notes, debug, health |
| `:DiviReload` | Reload settings, theme and keymaps |
| `:DiviVersion` | Print the version |
| `:colorscheme divi` | Re-apply the DIVI colours |

---

## Features you can switch off

In `lua/divi/settings.lua`:

```lua
features = {
  dashboard = true,
  intellij_keys = true,
  notes = true,
  ai = true,
  debug = true,
}
```

Set any to `false` and restart. Plugins for disabled features are not loaded.

---

## Troubleshooting

- **Colours look wrong** → `:colorscheme divi`, or `:DiviReload`.
- **Icons are boxes** → the terminal font needs Nerd Font glyphs
  (Ghostty already uses `DepartureMono Nerd Font` here).
- **`Alt-1` does nothing** → terminal intercepts it; use `<Space>e`.
- **opencode not found** → `which opencode`; change `ai.command` in settings.
- **A project is missing from `<Space>fp`** → give it a marker (`git init`,
  `package.json`) or raise `projects.depth`.
- **Plugin broke after an update** → `:Lazy restore` or `git -C ~/.config/nvim
  checkout -- lua/`.
