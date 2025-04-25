#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "🔧 Starting dotfiles installation..."
echo "🗂️ Dotfiles directory: $DOTFILES_DIR"

# Symlink bash_aliases
echo "🔗 Symlinking bash_aliases to $HOME/.bash_aliases"
ln -sf "$DOTFILES_DIR/bash_aliases" "$HOME_DIR/.bash_aliases"

# Install tools (modular, one per subdir)
for tool in tmux nvim; do
    TOOL_INSTALLER="$DOTFILES_DIR/$tool/install.sh"
    if [ -f "$TOOL_INSTALLER" ]; then
        echo "🚀 Running $tool installer..."
        bash "$TOOL_INSTALLER"
    else
        echo "⚠️ No installer found for $tool. Skipping."
    fi
done

echo "🎉 All done!"
