# terminal-config

My terminal setup, reproducible on any machine with one script.

zsh · oh-my-zsh · powerlevel10k · Ghostty · Zellij · **DIVI** (Neovim IDE) · eza/fzf/ripgrep/fd

## Install

**macOS**

```bash
git clone https://github.com/Dhivyadhanush/terminal-config.git ~/Documents/project/terminal-config
cd ~/Documents/project/terminal-config
./install-macos.sh
```

**Linux**

```bash
git clone https://github.com/Dhivyadhanush/terminal-config.git ~/terminal-config
cd ~/terminal-config
./install.sh
```

Then open a new terminal window. Both scripts are safe to re-run.

## What it does

| Step | Result |
|---|---|
| 1 | Installs zsh, git, curl, ripgrep, fd, fzf, tree, glow, eza |
| 2 | Installs Neovim ≥ 0.10 — package if new enough, otherwise AppImage (Linux) / Homebrew (macOS) |
| 3 | Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting |
| 4 | Ensures a modern fzf (Ctrl-R history, Ctrl-T files) |
| 5 | Installs the Departure Mono Nerd Font |
| 6 | Installs Zellij (package, musl binary, or Homebrew) |
| 7 | **Symlinks** the configs into `~/.zshrc`, `~/.config/{nvim,ghostty,zellij,fd}` |
| 8 | Installs Ghostty (macOS cask / Arch package; elsewhere tells you where to get it) |
| 9 | Reminds you to `chsh` if zsh isn't your login shell |

## Layout

```
install.sh            Linux installer
install-macos.sh      macOS installer
shell/zshrc           -> ~/.zshrc
shell/p10k.zsh        -> ~/.p10k.zsh
nvim/                 -> ~/.config/nvim     (DIVI: a full Neovim IDE, see nvim/README.md)
ghostty/              -> ~/.config/ghostty   (config + theme + shader)
zellij/config.kdl     -> ~/.config/zellij/config.kdl
fd/ignore             -> ~/.config/fd/ignore (keeps pickers fast by skipping Library/, node_modules/, …)
bin/update            -> ~/.local/bin/update (one-command Homebrew maintenance)
bin/brewup            -> ~/.local/bin/brewup (the script behind `update`)
```

Configs are **symlinked**, so editing in place edits the repo and `git pull` updates your setup.
On a fresh machine the first `nvim` launch installs plugins (~40s); `lazy-lock.json` pins the versions.

## DIVI (the Neovim IDE)

Neovim + LazyVim with a personal layer on top — file explorer, project switcher,
fuzzy find, git UI, notes, AI, debugger and SQL, all in the terminal.

| Keys | Action |
| --- | --- |
| `<Space>fp` | Every project on disk (scans `~/Documents/project`) |
| `<Space>e` | File explorer (create/rename/move/delete) |
| `<Space>ff` · `<Space>/` | Find file · grep the project |
| `<Space>gg` | Git (lazygit: stage, commit, branch, push) |
| `<Space>rr` · `<Space>rd` | Run · debug the current file |
| `<Space>aa` · `<Space>ae` | opencode chat · explain file/selection |
| `<Space>no` | Switch note in the Obsidian vault |
| `<Space>D` | Database UI (dadbod) |
| `:Divi` | DIVI control panel (edit settings, all keymaps, health) |
| `:DiviReload` | Re-apply settings/theme/keymaps after editing |

Everything you'd customize lives in `lua/divi/` — `settings.lua` (name, colours,
feature switches, vault path), `theme.lua` (palette), `keymaps.lua`, `plugins/`.
LazyVim updates never touch it. Full manual: [`nvim/README.md`](nvim/README.md).

## Maintenance

```sh
update                 # brew update + upgrade formulae/casks + cleanup + autoremove
update -n              # dry run
update --no-greedy     # skip self-updating apps (Chrome, VS Code)
update --no-cleanup    # upgrade only
update --doctor        # also run brew doctor
```

`update` wraps `bin/brewup`: it updates the index, upgrades formulae and casks
(including `--greedy` apps), prunes old versions and unused dependencies, then
prints a summary (packages upgraded, cache size). Every step runs even if one
fails, and it exits `1` with the failures listed — safe for cron/launchd.

## Backups

Anything that already existed is moved to `~/.dotfiles-backup-<timestamp>/` before being replaced. Nothing is deleted.

## Supported distros

Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman), openSUSE (zypper) — and macOS via Homebrew.
Tested paths: apt, pacman and macOS.

## Notes

- **Font is required.** Without the Nerd Font, prompt glyphs, devicons and `eza --icons` render as boxes.
- **Ghostty** is not in Debian/Fedora repos. Grab the `.deb`/`.rpm` from <https://ghostty.org/download>; the linked config applies immediately.
- **Ubuntu's `fd` is `fdfind`** — the installer symlinks it to `fd` for you.
- **Neovim on Ubuntu is 0.9 in the repos**, which breaks modern `init.lua` files. The installer uses the AppImage instead.
- `background-blur` in the Ghostty config only works on compositors that support it (KDE Plasma yes, GNOME no).
- **Zellij sessions** are named: `zellij attach -c work`. Detach with `Ctrl-o` then `d`; list with `zellij ls`.

## macOS

`./install-macos.sh` does the Homebrew equivalent of the Linux script and links the same configs:

```bash
brew install neovim ripgrep fd fzf tree glow eza zellij
brew install --cask ghostty font-departure-mono-nerd-font
```

Use `DRY_RUN=1 ./install-macos.sh` to relink configs without installing anything.
