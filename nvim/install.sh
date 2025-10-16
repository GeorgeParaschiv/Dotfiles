#!/bin/bash

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
NVIM_SOURCE_DIR="$DOTFILES_DIR/nvim"
NVIM_TARGET_DIR="$HOME/.config/nvim"

# Install Neovim if it's not already installed
if command -v nvim >/dev/null 2>&1; then
  echo "✅ Neovim is already installed."
else
  echo "📦 Installing Neovim..."
  if ! sudo -v; then
    echo "❌ This step needs sudo to install Neovim with apt."
    exit 1
  fi
  # sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt update
  sudo apt install -y neovim
fi

# Create parent config directory if needed
mkdir -p "$HOME/.config"

# Create the target directory
mkdir -p "$NVIM_TARGET_DIR"

# Symlink everything inside nvim/ except install.sh
echo "🔗 Symlinking Neovim config files (excluding install.sh)..."
for item in "$NVIM_SOURCE_DIR"/*; do
    base_item="$(basename "$item")"
    
    # Skip install.sh file
    if [ "$base_item" != "install.sh" ]; then
        # Ensure we only symlink files and directories that exist
        ln -snf "$item" "$NVIM_TARGET_DIR/$base_item"
    fi
done
