#!/usr/bin/env bash
#
# terminal-config installer for macOS
#   zsh + oh-my-zsh + powerlevel10k · ghostty · zellij · neovim (DIVI) · eza/fzf/ripgrep/fd
#
# Usage:
#   cd terminal-config
#   ./install-macos.sh              # install everything and link configs
#   DRY_RUN=1 ./install-macos.sh    # link configs only, skip package installs
#
# Safe to re-run. Existing configs are backed up to ~/.dotfiles-backup-<timestamp>/
# and then replaced with symlinks into this repo, so `git pull` updates your setup.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"
DRY="${DRY_RUN:-0}"

# ---------- output ----------
if [ -t 1 ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; C=$'\033[36m'; N=$'\033[0m'
else
  B=''; DIM=''; G=''; Y=''; R=''; C=''; N=''
fi
step() { printf '\n%s==> %s%s\n' "$B$C" "$*" "$N"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$N" "$*"; }
die()  { printf '  %s✗%s %s\n' "$R" "$N" "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "This script is for macOS. On Linux use ./install.sh"
command -v brew >/dev/null 2>&1 || die "Homebrew is required: https://brew.sh"

step "macOS"
ok "repo: $REPO"

# ---------- 1. packages ----------
step "Homebrew packages"
PKGS=(git neovim ripgrep fd fzf tree glow eza zellij)
if [ "$DRY" = 1 ]; then
  warn "DRY_RUN=1 — skipping: brew install ${PKGS[*]}"
else
  brew install "${PKGS[@]}" || warn "some packages failed — continuing"
  ok "packages done"
fi

# ---------- 2. ghostty + font ----------
step "Ghostty + Departure Mono Nerd Font"
if [ "$DRY" = 1 ]; then
  warn "DRY_RUN=1 — skipping casks"
else
  brew install --cask ghostty || warn "ghostty cask failed — get it from https://ghostty.org/download"
  brew install --cask font-departure-mono-nerd-font || warn "font cask failed — icons will render as boxes"
fi

# ---------- 3. shell ----------
step "zsh + oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ "$DRY" = 1 ]; then
  warn "DRY_RUN=1 — skipping oh-my-zsh and plugins"
else
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      || warn "oh-my-zsh install failed"
    ok "oh-my-zsh installed"
  else
    ok "oh-my-zsh already present"
  fi

  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$ZSH_CUSTOM/themes/powerlevel10k" || warn "powerlevel10k clone failed"
  fi

  for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [ -d "$ZSH_CUSTOM/plugins/$p" ] || \
      git clone --depth=1 "https://github.com/zsh-users/$p.git" "$ZSH_CUSTOM/plugins/$p" || true
  done
  ok "p10k + plugins ready"
fi

# ---------- 4. link configs ----------
step "Linking configs"
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      ok "$dst already linked"
      return 0
    fi
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/$(basename "$dst")"
    warn "backed up $dst -> $BACKUP/"
  fi
  ln -sfn "$src" "$dst"
  ok "$dst -> $src"
}

link "$REPO/shell/zshrc"    "$HOME/.zshrc"
link "$REPO/shell/p10k.zsh" "$HOME/.p10k.zsh"
link "$REPO/nvim"           "$HOME/.config/nvim"
link "$REPO/ghostty"        "$HOME/.config/ghostty"
link "$REPO/zellij"         "$HOME/.config/zellij"
link "$REPO/fd"             "$HOME/.config/fd"

# maintenance scripts (`update`, `brewup`)
mkdir -p "$HOME/.local/bin"
for f in brewup update; do
  link "$REPO/bin/$f" "$HOME/.local/bin/$f"
done

# ---------- 5. login shell ----------
step "Login shell"
case "${SHELL:-}" in
  *zsh) ok "zsh is already your login shell" ;;
  *)    warn "make zsh your login shell:  chsh -s $(command -v zsh)" ;;
esac

# ---------- summary ----------
step "Done"
cat <<EOF
  ${DIM}next:${N} open a new terminal window

  ${B}verify${N}
    echo \$SHELL                # /bin/zsh
    ls                          # eza icons
    nvim --version | head -1    # >= 0.10
    divi                        # DIVI start screen
    divi ~/Documents/project    # open a folder
    :Divi                       # inside nvim: control panel
    zellij attach -c work       # zellij session
    gh help                     # optional: GitHub CLI

  backups from this run: ${BACKUP}
EOF
