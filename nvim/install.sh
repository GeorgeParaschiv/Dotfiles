#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
NVIM_SRC="$DOTFILES_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"
LOG_FILE="$DOTFILES_DIR/install.log"

# Error trap
trap 'echo ""; echo "Error occurred during installation. Check $LOG_FILE for details." >&2; exit 1' ERR

# Verify source directory exists
if [[ ! -d "$NVIM_SRC" ]]; then
  echo "Error: Neovim source directory not found: $NVIM_SRC" >&2
  exit 1
fi

# Update package lists and install dependencies
echo -n "Updating package lists... "
sudo apt-get update -y >> "$LOG_FILE" 2>&1
echo "done"

echo -n "Installing dependencies... "
sudo apt-get install -y snapd ripgrep fd-find curl >> "$LOG_FILE" 2>&1
echo "done"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo -n "Installing Node.js and npm... "
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >> "$LOG_FILE" 2>&1
  sudo apt-get install -y nodejs >> "$LOG_FILE" 2>&1
  echo "done"
fi

mkdir -p "$HOME/.local/bin" >> "$LOG_FILE" 2>&1
if command -v fdfind >/dev/null 2>&1; then
  ln -snf "$(command -v fdfind)" "$HOME/.local/bin/fd" >> "$LOG_FILE" 2>&1
fi

# Install Neovim
echo -n "Installing Neovim... "
sudo snap install nvim --classic >> "$LOG_FILE" 2>&1 || sudo snap refresh nvim --classic >> "$LOG_FILE" 2>&1
export PATH="/snap/bin:$PATH"
echo "done"

mkdir -p "$NVIM_DEST" >> "$LOG_FILE" 2>&1
if [[ ! -d "$NVIM_DEST" ]]; then
  echo "Error: Failed to create destination directory: $NVIM_DEST" >&2
  exit 1
fi

# Symlink files
shopt -s nullglob
for item in "$NVIM_SRC"/*; do
  base="$(basename "$item")"
  [[ "$base" == "install.sh" ]] && continue
  ln -snf "$item" "$NVIM_DEST/$base" >> "$LOG_FILE" 2>&1 || true
done
