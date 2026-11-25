#!/usr/bin/env bash
#
# terminal-config installer for Linux
#   zsh + oh-my-zsh + powerlevel10k · ghostty · zellij · neovim · eza/fzf/ripgrep/fd
#
# Usage:  cd terminal-config && ./install.sh
#
# Safe to re-run. Existing configs are backed up to ~/.dotfiles-backup-<timestamp>/
# and then replaced with symlinks into this repo, so `git pull` updates your setup.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"
FONTS_DIR="$HOME/.local/share/fonts"

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

# ---------- detect distro / package manager ----------
PKG=""
if   command -v apt-get >/dev/null 2>&1; then PKG=apt
elif command -v dnf     >/dev/null 2>&1; then PKG=dnf
elif command -v pacman  >/dev/null 2>&1; then PKG=pacman
elif command -v zypper  >/dev/null 2>&1; then PKG=zypper
fi
[ -n "$PKG" ] || die "No supported package manager found (apt/dnf/pacman/zypper)."

ARCH="$(uname -m)"

step "System"
ok "package manager: $PKG"
ok "architecture: $ARCH"
ok "repo: $REPO"

SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"

install_pkgs() {
  [ $# -eq 0 ] && return 0
  case "$PKG" in
    apt)    $SUDO apt-get update -qq && $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) $SUDO zypper install -y "$@" ;;
  esac
}

# ---------- 1. base packages ----------
step "Base packages"
BASE=(zsh git curl unzip fontconfig ripgrep tree glow)
case "$PKG" in
  apt)    BASE+=(fzf fd-find build-essential) ;;
  dnf)    BASE+=(fzf fd-find) ;;
  pacman) BASE+=(fzf fd) ;;
  zypper) BASE+=(fzf fd) ;;
esac
install_pkgs "${BASE[@]}" || warn "some base packages failed — continuing"
ok "base packages done"

# fd on Debian/Ubuntu is installed as `fdfind`
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  ok "linked fdfind -> fd"
fi

# eza is not in older Ubuntu repos: use the official repo
if ! command -v eza >/dev/null 2>&1; then
  if [ "$PKG" = apt ]; then
    step "eza (official apt repo)"
    $SUDO mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
      | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
      | $SUDO tee /etc/apt/sources.list.d/gierens.list >/dev/null
    $SUDO apt-get update -qq && $SUDO apt-get install -y eza
  else
    install_pkgs eza || warn "eza not installed — ls aliases will fall back to plain ls"
  fi
fi
command -v eza >/dev/null 2>&1 && ok "eza installed" || warn "eza missing (aliases in .zshrc are guarded, so nothing breaks)"

# ---------- 2. neovim ----------
step "Neovim"
# proper version compare: ver_ge "0.9" "0.10" -> false
ver_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}
nvim_ver() {
  "${1:-nvim}" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1
}

need_nvim=1
if command -v nvim >/dev/null 2>&1 && ver_ge "$(nvim_ver)" 0.10; then
  ok "nvim $(nvim_ver) already installed (>= 0.10)"
  need_nvim=0
elif command -v nvim >/dev/null 2>&1; then
  warn "nvim $(nvim_ver) is too old (need >= 0.10)"
fi

if [ "$need_nvim" -eq 1 ]; then
  case "$PKG" in
    pacman|dnf) install_pkgs neovim 2>/dev/null || true ;;
  esac
  if command -v nvim >/dev/null 2>&1 && ver_ge "$(nvim_ver)" 0.10; then
    ok "neovim $(nvim_ver) installed from packages"
  else
    case "$ARCH" in
      x86_64)         NVIM_ASSET=nvim-linux-x86_64.appimage ;;
      aarch64|arm64)  NVIM_ASSET=nvim-linux-arm64.appimage ;;
      *) die "Unsupported architecture for the Neovim AppImage: $ARCH" ;;
    esac
    mkdir -p "$HOME/.local/bin"
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/$NVIM_ASSET" \
      -o "$HOME/.local/bin/nvim"
    chmod +x "$HOME/.local/bin/nvim"
    if ver_ge "$(nvim_ver "$HOME/.local/bin/nvim")" 0.10; then
      ok "neovim $(nvim_ver "$HOME/.local/bin/nvim") installed to ~/.local/bin/nvim (AppImage)"
    else
      die "Neovim install failed — check your network, or install it manually"
    fi
    warn "if it fails to start: sudo apt install libfuse2  (or run with --appimage-extract-and-run)"
  fi
fi

# ---------- 3. shell ----------
step "zsh + oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "oh-my-zsh installed"
else
  ok "oh-my-zsh already present"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
  ok "powerlevel10k installed"
else
  ok "powerlevel10k already present"
fi

for p in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$p" ]; then
    git clone --depth=1 "https://github.com/zsh-users/$p.git" "$ZSH_CUSTOM/plugins/$p" || true
  fi
done

# ---------- 4. fzf ----------
step "fzf"
if command -v fzf >/dev/null 2>&1; then
  FZF_V="$(fzf --version | awk '{print $1}')"
  if ver_ge "$FZF_V" 0.48; then
    ok "fzf $FZF_V supports --zsh"
  else
    warn "fzf $FZF_V is old; installing current release to ~/.fzf"
    git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf" 2>/dev/null || true
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish >/dev/null
    ln -sf "$HOME/.fzf/bin/fzf" "$HOME/.local/bin/fzf"
    ok "fzf $(fzf --version | awk '{print $1}') installed via ~/.fzf"
  fi
else
  warn "fzf missing — Ctrl-R history search will be unavailable"
fi

# ---------- 5. font ----------
step "Departure Mono Nerd Font"
mkdir -p "$FONTS_DIR/DepartureMono"
if curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/DepartureMono.zip" \
     -o /tmp/DepartureMono.zip; then
  unzip -o -q /tmp/DepartureMono.zip -d "$FONTS_DIR/DepartureMono"
  fc-cache -f >/dev/null
  ok "font installed ($(find "$FONTS_DIR/DepartureMono" -name '*.otf' -o -name '*.ttf' | wc -l | tr -d ' ') files)"
else
  warn "font download failed — install it manually from github.com/ryanoasis/nerd-fonts/releases"
fi

# ---------- 6. zellij ----------
step "Zellij"
if ! command -v zellij >/dev/null 2>&1; then
  install_pkgs zellij 2>/dev/null || true
fi
if ! command -v zellij >/dev/null 2>&1; then
  case "$ARCH" in
    x86_64)        ZJ=zellij-x86_64-unknown-linux-musl ;;
    aarch64|arm64) ZJ=zellij-aarch64-unknown-linux-musl ;;
  esac
  if [ -n "${ZJ:-}" ]; then
    mkdir -p "$HOME/.local/bin"
    curl -fL "https://github.com/zellij-org/zellij/releases/latest/download/$ZJ.tar.gz" \
      | tar -xz -C "$HOME/.local/bin" zellij
    ok "zellij installed to ~/.local/bin"
  fi
fi
command -v zellij >/dev/null 2>&1 && ok "zellij ready" || warn "zellij could not be installed"

# ---------- 7. dotfiles ----------
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

link "$REPO/shell/zshrc"      "$HOME/.zshrc"
link "$REPO/shell/p10k.zsh"   "$HOME/.p10k.zsh"
link "$REPO/nvim"             "$HOME/.config/nvim"
link "$REPO/ghostty"          "$HOME/.config/ghostty"
link "$REPO/zellij"           "$HOME/.config/zellij"
link "$REPO/fd"               "$HOME/.config/fd"

# ---------- 8. ghostty ----------
step "Ghostty"
if command -v ghostty >/dev/null 2>&1; then
  ok "ghostty $(ghostty --version 2>/dev/null | head -1 | awk '{print $2}') installed"
else
  if [ "$PKG" = pacman ]; then
    install_pkgs ghostty && ok "ghostty installed" || warn "ghostty not installed"
  else
    warn "ghostty is not in the distro repos — install it, then re-run:"
    warn "  https://ghostty.org/download   (.deb / .rpm / tar.gz)"
    warn "your config is already linked, so it applies as soon as ghostty starts"
  fi
fi

# ---------- 9. default shell ----------
step "Login shell"
case "$(getent passwd "$USER" | cut -d: -f7)" in
  *zsh) ok "zsh is already your login shell" ;;
  *)    warn "make zsh your login shell:  chsh -s $(command -v zsh)" ;;
esac

# ---------- summary ----------
step "Done"
cat <<EOF
  ${DIM}next:${N} open a new terminal (or: exec zsh)

  ${B}verify${N}
    echo \$SHELL                  # /usr/bin/zsh
    ls                           # eza icons
    nvim --version | head -1     # >= 0.10
    nvim                         # numbers + theme
    nvim +Tutor                  # tutorial
    zellij                       # your layout

  backups from this run: ${BACKUP}
EOF
