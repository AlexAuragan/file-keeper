#!/bin/bash

RAW_URL="https://raw.githubusercontent.com/AlexAuragan/file-keeper/main/fk"
INSTALL_PATH="/usr/local/bin/fk"

TMP=$(mktemp)
curl -sSL "$RAW_URL" -o "$TMP" || { echo "Failed to download fk."; rm -f "$TMP"; exit 1; }

if [ -f "$INSTALL_PATH" ]; then
  if diff -q "$TMP" "$INSTALL_PATH" > /dev/null 2>&1; then
    echo "fk is already up to date."
    rm -f "$TMP"
    exit 0
  fi
  echo "Updating fk..."
else
  echo "Installing fk..."
fi

chmod +x "$TMP"
if [ ! -w "$(dirname "$INSTALL_PATH")" ]; then
  sudo mv "$TMP" "$INSTALL_PATH"
else
  mv "$TMP" "$INSTALL_PATH"
fi

echo "Done. fk installed to $INSTALL_PATH"
