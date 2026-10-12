#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '%s\n' "$*"
}

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SET_DEFAULT_SHELL="${SET_DEFAULT_SHELL:-0}"
INSTALL_EXTRAS="${INSTALL_EXTRAS:-0}"
INSTALL_BAT="${INSTALL_BAT:-0}"

log "==> Ubuntu server dotfiles install"
log "Dotfiles: ${DOTFILES_DIR}"

if [[ ! -d "${DOTFILES_DIR}/shell" || ! -d "${DOTFILES_DIR}/nvim" ]]; then
  log "Error: missing shell/ or nvim/ package in ${DOTFILES_DIR}"
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  log "Error: apt-get not found (this script targets Ubuntu/Debian)"
  exit 1
fi

log "==> Installing base packages (shell + nvim)"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  zsh \
  stow \
  ripgrep \
  fd-find \
  fzf \
  build-essential \
  unzip

mkdir -p "${HOME}/.local/bin"

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd"
fi

if [[ "${INSTALL_BAT}" == "1" ]]; then
  sudo apt-get install -y bat
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "${HOME}/.local/bin/bat"
  fi
fi

if [[ "${INSTALL_EXTRAS}" == "1" ]]; then
  sudo apt-get install -y eza zoxide direnv atuin
fi

# Neovim: apt's build is far older than this config needs (0.11+), so use the official release
NVIM_MIN="0.11"
nvim_version() { nvim --version 2>/dev/null | awk 'NR==1 { sub(/^v/, "", $2); print $2 }'; }
if ! command -v nvim >/dev/null 2>&1 || [[ "$(printf '%s\n' "$NVIM_MIN" "$(nvim_version)" | sort -V | head -n1)" != "$NVIM_MIN" ]]; then
  case "$(uname -m)" in
    x86_64) nvim_arch="x86_64" ;;
    aarch64 | arm64) nvim_arch="arm64" ;;
    *) log "Error: unsupported CPU $(uname -m) for the Neovim release build"; exit 1 ;;
  esac
  log "==> Installing Neovim (latest stable release, ${nvim_arch})"
  mkdir -p "${HOME}/.local/opt"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" |
    tar -xz -C "${HOME}/.local/opt"
  ln -sfn "${HOME}/.local/opt/nvim-linux-${nvim_arch}/bin/nvim" "${HOME}/.local/bin/nvim"
fi

# The shell config uses zinit, which installs itself on the first zsh start (no Oh My Zsh needed)

log "==> Stowing packages (shell, nvim)"
stow --target="${HOME}" --dir="${DOTFILES_DIR}" shell nvim

if [[ "${SET_DEFAULT_SHELL}" == "1" ]]; then
  log "==> Setting default shell to zsh"
  sudo chsh -s "$(command -v zsh)" "${USER}"
fi

log "==> Done"
log "Next:"
log "  - Review ~/.config/zsh/local.zsh"
log "  - Launch zsh: exec zsh"
