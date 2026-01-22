#!/bin/bash

# Uninstall md-export from /usr/local/bin

set -e

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="md-export"

if [ -L "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "Removing md-export..."
    sudo rm "$INSTALL_DIR/$SCRIPT_NAME"
    echo "✓ md-export uninstalled successfully!"
else
    echo "md-export is not installed in $INSTALL_DIR"
fi
