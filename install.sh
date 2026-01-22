#!/bin/bash

# Install md-export to /usr/local/bin

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="md-export"

echo "Installing md-export..."

# Check if /usr/local/bin exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating $INSTALL_DIR..."
    sudo mkdir -p "$INSTALL_DIR"
fi

# Remove existing symlink if present
if [ -L "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "Removing existing symlink..."
    sudo rm "$INSTALL_DIR/$SCRIPT_NAME"
fi

# Create symlink
sudo ln -s "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"

echo "✓ md-export installed successfully!"
echo ""
echo "Usage:"
echo "  md-export document.md           # Creates document.pdf"
echo "  md-export -t html document.md   # Creates document.html"
echo "  md-export --help                # Show all options"
