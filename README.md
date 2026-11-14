# terminal-config

My terminal setup, reproducible on any Linux box with one script.

zsh · oh-my-zsh · powerlevel10k · Ghostty · Zellij · Neovim · eza/fzf/ripgrep/fd

## Install

```bash
git clone https://github.com/Dhivyadhanush/terminal-config.git ~/terminal-config
cd ~/terminal-config
./install.sh
```

Then open a new terminal. The script is safe to re-run.

## What it does

| Step | Result |
|---|---|
| 1 | Installs zsh, git, curl, ripgrep, fd, fzf, tree, glow, eza |
| 2 | Installs Neovim ≥ 0.10 — package if new enough, otherwise the official AppImage |
| 3 | Installs oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting |
| 4 | Ensures a modern fzf (Ctrl-R history, Ctrl-T files) |
| 5 | Installs Departure Mono Nerd Font + refreshes fontconfig |
| 6 | Installs Zellij (package, or musl binary fallback) |
| 7 | **Symlinks** the configs into `~/.zshrc`, `~/.config/{nvim,ghostty,zellij}` |
| 8 | Installs Ghostty if your distro packages it; otherwise tells you where to get it |
| 9 | Reminds you to `chsh` if zsh isn't your login shell |

## Layout

```
install.sh          the whole installer
shell/zshrc         -> ~/.zshrc
shell/p10k.zsh      -> ~/.p10k.zsh
nvim/init.lua       -> ~/.config/nvim/init.lua
ghostty/            -> ~/.config/ghostty     (config + custom theme + shader)
zellij/config.kdl   -> ~/.config/zellij/config.kdl
```

Configs are **symlinked**, so editing in place edits the repo and `git pull` updates your setup.

## Backups

Anything that already existed is moved to `~/.dotfiles-backup-<timestamp>/` before being replaced. Nothing is deleted.

## Supported distros

Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman), openSUSE (zypper). Tested paths: apt and pacman.

## Notes

- **Font is required.** Without the Nerd Font, prompt glyphs and `eza --icons` render as boxes.
- **Ghostty** is not in Debian/Fedora repos. Grab the `.deb`/`.rpm` from <https://ghostty.org/download>; the linked config applies immediately.
- **Ubuntu's `fd` is `fdfind`** — the installer symlinks it to `fd` for you.
- **Neovim on Ubuntu is 0.9 in the repos**, which breaks modern `init.lua` files. The installer uses the AppImage instead.
- `background-blur` in the Ghostty config only works on compositors that support it (KDE Plasma yes, GNOME no).

## macOS

This repo targets Linux. For macOS the equivalents are:

```bash
brew install neovim ripgrep fd fzf tree glow eza zellij ghostty
brew install --cask font-departure-mono-nerd-font
```
