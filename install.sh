#!/bin/bash

RAW_URL="https://raw.githubusercontent.com/AlexAuragan/file-keeper/main/fk"
INSTALL_PATH="/usr/local/bin/fk"

setup_shell_integration() {
  local BASH_BLOCK='
# fk shell integration
_fk_inject_history() {
  if [ -f ~/.fk_last_cmd ]; then
    history -s "$(cat ~/.fk_last_cmd)"
    rm -f ~/.fk_last_cmd
  fi
}
PROMPT_COMMAND="_fk_inject_history${PROMPT_COMMAND:+; $PROMPT_COMMAND}"'

  local ZSH_BLOCK='
# fk shell integration
_fk_inject_history() {
  if [ -f ~/.fk_last_cmd ]; then
    print -s "$(cat ~/.fk_last_cmd)"
    rm -f ~/.fk_last_cmd
  fi
}
precmd_functions+=(_fk_inject_history)'

  local injected=0

  if [ -f "$HOME/.bashrc" ] && ! grep -q '_fk_inject_history' "$HOME/.bashrc"; then
    printf '%s\n' "$BASH_BLOCK" >> "$HOME/.bashrc"
    echo "Shell integration added to ~/.bashrc"
    injected=1
  elif [ -f "$HOME/.bashrc" ]; then
    echo "Shell integration already present in ~/.bashrc"
  fi

  if [ -f "$HOME/.zshrc" ] && ! grep -q '_fk_inject_history' "$HOME/.zshrc"; then
    printf '%s\n' "$ZSH_BLOCK" >> "$HOME/.zshrc"
    echo "Shell integration added to ~/.zshrc"
    injected=1
  elif [ -f "$HOME/.zshrc" ]; then
    echo "Shell integration already present in ~/.zshrc"
  fi

  if [ $injected -eq 1 ]; then
    echo "Reload your shell (or run 'source ~/.bashrc' / 'source ~/.zshrc') to activate."
  fi
}

TMP=$(mktemp)
curl -sSL "$RAW_URL" -o "$TMP" || { echo "Failed to download fk."; rm -f "$TMP"; exit 1; }

if [ -f "$INSTALL_PATH" ]; then
  if diff -q "$TMP" "$INSTALL_PATH" > /dev/null 2>&1; then
    echo "fk is already up to date."
    rm -f "$TMP"
    setup_shell_integration
    exit 0
  fi
  echo "Updating fk..."
else
  echo "Installing fk..."
fi

chmod +x "$TMP"
if [ ! -w "$(dirname "$INSTALL_PATH")" ]; then
  if command -v sudo > /dev/null 2>&1; then
    sudo mv "$TMP" "$INSTALL_PATH"
  else
    echo "Error: cannot write to $(dirname "$INSTALL_PATH") and sudo is not available."
    rm -f "$TMP"
    exit 1
  fi
else
  mv "$TMP" "$INSTALL_PATH"
fi

echo "Done. fk installed to $INSTALL_PATH"
setup_shell_integration
