#!/bin/bash

set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
NVIM_SOURCE_DIR="$DOTFILES_DIR/nvim"
NVIM_TARGET_DIR="$HOME/.config/nvim"

# Ask for sudo permissions
if ! sudo -v; then
    echo "❌ This script requires sudo privileges."
    exit 1
fi

# Install Neovim if it's not already installed
    if command -v nvim >/dev/null 2>&1; then
        echo "✅ Neovim is already installed."
    else
        echo "📦 Installing Neovim..."
        sudo add-apt-repository ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install -y neovim
    fi

 # Backup existing config if it's not already a symlink
    if [ -e "$NVIM_CONFIG_DIR" ] && [ ! -L "$NVIM_CONFIG_DIR" ]; then
        echo "🗂️ Backing up existing Neovim config..."
        mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)"
    fi

# Create parent config directory if needed
mkdir -p "$HOME/.config"

# Create the target directory
mkdir -p "$NVIM_TARGET_DIR"

# Symlink everything inside nvim/ except install.sh
echo "🔗 Symlinking Neovim config files (excluding install.sh)..."
for item in "$NVIM_SOURCE_DIR"/*; do
    base_item="$(basename "$item")"
    if [ "$base_item" != "install.sh" ]; then
        ln -sf "$item" "$NVIM_TARGET_DIR/$base_item"
    fi
done
