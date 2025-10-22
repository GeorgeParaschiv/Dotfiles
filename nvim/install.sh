#!/usr/bin/env bash
set -euo pipefail

# Install deps, install/refresh Neovim (snap), link config
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
NVIM_SRC="$DOTFILES_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

sudo apt-get update -y
sudo apt-get install -y snapd ripgrep fd-find

mkdir -p "$HOME/.local/bin"
command -v fdfind >/dev/null 2>&1 && ln -snf "$(command -v fdfind)" "$HOME/.local/bin/fd"

sudo snap install nvim --classic || sudo snap refresh nvim --classic
export PATH="/snap/bin:$PATH"

mkdir -p "$NVIM_DEST"
shopt -s nullglob
for item in "$NVIM_SRC"/*; do
  base="$(basename "$item")"
  [[ "$base" == "install.sh" ]] && continue
  ln -snf "$item" "$NVIM_DEST/$base"
done


