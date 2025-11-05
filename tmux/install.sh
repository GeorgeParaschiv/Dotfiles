#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
LOG_FILE="$DOTFILES_DIR/install.log"

# Error trap
trap 'echo ""; echo "Error occurred during installation. Check $LOG_FILE for details." >&2; exit 1' ERR

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! sudo -v; then
    echo "Error: This script requires sudo privileges." >&2
    exit 1
fi

# Install tmux
if ! command_exists tmux; then
    echo -n "Installing tmux... "
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y tmux >> "$LOG_FILE" 2>&1
    echo "done"
fi

# Symlink the tmux config
ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf" >> "$LOG_FILE" 2>&1
