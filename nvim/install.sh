#!/usr/bin/env bash
set -euo pipefail

# Install deps, install/refresh Neovim (snap), link config
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
NVIM_SRC="$DOTFILES_DIR/nvim"
NVIM_DEST="$HOME/.config/nvim"

# Verify source directory exists
if [[ ! -d "$NVIM_SRC" ]]; then
  echo "Error: Neovim source directory not found: $NVIM_SRC" >&2
  exit 1
fi

sudo apt-get update -y
sudo apt-get install -y snapd ripgrep fd-find curl

# Install Node.js and npm (required for some Mason language servers)
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Installing Node.js and npm..."
  # Use NodeSource repository for latest LTS Node.js
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
  # Verify installation
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "✓ Node.js $(node --version) and npm $(npm --version) installed successfully"
  else
    echo "Warning: Node.js/npm installation may have failed. Some language servers may not install." >&2
  fi
else
  echo "✓ Node.js $(node --version) and npm $(npm --version) are already installed"
fi

mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1; then
  ln -snf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

sudo snap install nvim --classic || sudo snap refresh nvim --classic
export PATH="/snap/bin:$PATH"

# Create destination directory
mkdir -p "$NVIM_DEST"
if [[ ! -d "$NVIM_DEST" ]]; then
  echo "Error: Failed to create destination directory: $NVIM_DEST" >&2
  exit 1
fi

# Symlink files
shopt -s nullglob
for item in "$NVIM_SRC"/*; do
  base="$(basename "$item")"
  [[ "$base" == "install.sh" ]] && continue
  if ! ln -snf "$item" "$NVIM_DEST/$base"; then
    echo "Warning: Failed to symlink $base" >&2
  fi
done


