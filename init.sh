#!/bin/bash

# Where to install the fk command
INSTALL_PATH="/usr/local/bin/fk"

# Path to the current fk script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FK_SCRIPT="$SCRIPT_DIR/fk"

# Check if we have write permissions
if [ ! -w "$(dirname "$INSTALL_PATH")" ]; then
  echo "Root permissions are required to install to $INSTALL_PATH."
  echo "Re-running with sudo..."
  sudo cp "$FK_SCRIPT" "$INSTALL_PATH" && sudo chmod +x "$INSTALL_PATH" && echo "Installed fk to $INSTALL_PATH"
else
  cp "$FK_SCRIPT" "$INSTALL_PATH" && chmod +x "$INSTALL_PATH" && echo "Installed fk to $INSTALL_PATH"
fi
