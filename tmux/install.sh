#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for sudo access up front
if ! sudo -v; then
    echo "❌ This script requires sudo privileges."
    exit 1
fi

# Install tmux if not present
if command_exists tmux; then
    echo "✅ tmux is already installed."
else
    echo "📦 Installing tmux..."
    sudo apt update
    sudo apt install -y tmux
fi

# Symlink the tmux config
echo "🔗 Symlinking .tmux.conf..."
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
