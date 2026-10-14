#!/usr/bin/env bash
# Dotfiles for an Ubuntu server: zsh + Neovim + git, with current CLI tools from mise.
# Safe to re-run: apt and mise skip what is installed, stow only adds links.
#
#   SET_DEFAULT_SHELL=0  keep the login shell (default: switch to zsh)
#   MACHINE_NAME=name    written to a new ~/.config/zsh/local.zsh (default: the hostname)
#
# tmux is installed but its config is not stowed: an SSH login from the Mac starts the
# server's tmux inside the Mac's tmux, and the stock prefix (C-b) keeps the two apart.
set -euo pipefail

log() {
  printf '%s\n' "$*"
}

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SET_DEFAULT_SHELL="${SET_DEFAULT_SHELL:-1}"
MACHINE_NAME="${MACHINE_NAME:-$(hostname -s)}"

log "==> Ubuntu server dotfiles install"
log "Dotfiles: ${DOTFILES_DIR}"

for pkg in shell nvim git bat mise; do
  if [[ ! -d "${DOTFILES_DIR}/${pkg}" ]]; then
    log "Error: missing ${pkg}/ package in ${DOTFILES_DIR}"
    exit 1
  fi
done

if ! command -v apt-get >/dev/null 2>&1; then
  log "Error: apt-get not found (this script targets Ubuntu/Debian)"
  exit 1
fi

log "==> Installing base packages"
sudo apt-get update -y
sudo apt-get install -y \
  build-essential \
  btop \
  ca-certificates \
  curl \
  git \
  gnupg \
  jq \
  make \
  ncdu \
  shellcheck \
  stow \
  tmux \
  unzip \
  zsh

# mise from its signed apt repo, so `apt upgrade` keeps mise itself current
if ! command -v mise >/dev/null 2>&1; then
  log "==> Adding the mise apt repository"
  sudo install -dm 755 /etc/apt/keyrings
  sudo curl -fsSLo /etc/apt/keyrings/mise-archive-keyring.asc https://mise.jdx.dev/gpg-key.pub
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" |
    sudo tee /etc/apt/sources.list.d/mise.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y mise
fi

mkdir -p "${HOME}/.local/bin" "${HOME}/.config" "${HOME}/projects"

# Older runs of this script linked nvim and fd here; mise provides both now
for stale in nvim fd bat; do
  if [[ -L "${HOME}/.local/bin/${stale}" ]]; then
    rm -f "${HOME}/.local/bin/${stale}"
  fi
done

# Ubuntu's ~/.profile and ~/.bashrc stay: bash is still the fallback shell
log "==> Stowing packages (shell, nvim, git, bat, mise)"
mkdir -p "${HOME}/.config/zsh" "${HOME}/.config/git" "${HOME}/.config/bat/themes"
stow --target="${HOME}" --dir="${DOTFILES_DIR}" shell nvim git bat mise

# fd/rg ignore list for the Neovim pickers (same as `make install-search`)
mkdir -p "${HOME}/.config/fd" "${HOME}/.config/rg"
ln -sfn "${DOTFILES_DIR}/.ignore" "${HOME}/.config/fd/.fdignore"
ln -sfn "${DOTFILES_DIR}/.ignore" "${HOME}/.config/rg/.rgignore"

if [[ ! -e "${HOME}/.config/zsh/local.zsh" ]]; then
  sed "s/^export MACHINE_NAME=.*/export MACHINE_NAME=\"${MACHINE_NAME}\"/" \
    "${DOTFILES_DIR}/shell/.config/zsh/local.zsh.example" >"${HOME}/.config/zsh/local.zsh"
  log "Created ~/.config/zsh/local.zsh (MACHINE_NAME=${MACHINE_NAME})"
fi

log "==> Installing CLI tools with mise (~/.config/mise/config.toml)"
mise install --yes
export PATH="${HOME}/.local/share/mise/shims:${PATH}"

if command -v bat >/dev/null 2>&1; then
  bat cache --build >/dev/null
fi

# The zsh config clones zinit and the OMZ snippets on the first start; do it now so the
# first login is quick (TMUX set: skip the tmux auto-start, there is no terminal here)
log "==> Installing zinit"
TMUX=install zsh -ic exit </dev/null >/dev/null 2>&1 || true

log "==> Installing Neovim plugins"
nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || log "  Lazy sync failed; open nvim and run :Lazy"

if [[ "${SET_DEFAULT_SHELL}" == "1" && "$(getent passwd "${USER}" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  log "==> Setting default shell to zsh"
  sudo chsh -s "$(command -v zsh)" "${USER}"
fi

log "==> Done"
log "Next:"
log "  - Git identity: cp ${DOTFILES_DIR}/git/.gitconfig-local.example ~/.gitconfig-local"
log "  - Log in again (or: exec zsh)"
log "  - Update tools later: mise up && (cd ${DOTFILES_DIR} && git pull && make update)"
