#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
LOG_FILE="$DOTFILES_DIR/install.log"

> "$LOG_FILE"

# Error trap
trap 'echo ""; echo "Error occurred during installation. Check $LOG_FILE for details." >&2; exit 1' ERR

echo "Starting dotfiles installation..."
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Log file: $LOG_FILE"

# Symlink bash_aliases
echo "Symlinking bash_aliases to $HOME/.bash_aliases"
ln -sf "$DOTFILES_DIR/bash_aliases" "$HOME_DIR/.bash_aliases" >> "$LOG_FILE" 2>&1

# Install tools
for tool in tmux nvim; do
    TOOL_INSTALLER="$DOTFILES_DIR/$tool/install.sh"
    if [ -f "$TOOL_INSTALLER" ]; then
        echo "Installing $tool"
        bash "$TOOL_INSTALLER" >> "$LOG_FILE" 2>&1
    fi
done

echo "Done."
