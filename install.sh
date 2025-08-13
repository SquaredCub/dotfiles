#!/usr/bin/env bash
set -euo pipefail

# Run this script from inside your ~/dotfiles directory.
cd "$(dirname "$0")"
SCRIPT="./$(basename "$0")"

# Walk everything under dotfiles/, but skip .git and this script itself.
find . -mindepth 1 \
  -not -path "$SCRIPT" \
  -not -path "./.git" -not -path "./.git/*" \
  -print0 |
while IFS= read -r -d '' src; do
  rel="${src#./}"
  dest="$HOME/$rel"

  if [ -d "$src" ]; then
    # Ensure the directory exists in $HOME; do not replace it.
    mkdir -p "$dest"
    continue
  fi

  # Ensure parent dirs exist for files.
  mkdir -p "$(dirname "$dest")"

  # If a real file exists (not a symlink), back it up first.
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    ts=$(date +%Y%m%d-%H%M%S)
    mv "$dest" "$dest.bak.$ts"
    echo "Backup: $dest → $dest.bak.$ts"
  fi

  # Create/refresh the symlink (safe even if it already points correctly).
  ln -snf "$(pwd)/$src" "$dest"
  echo "Link:   $dest → $(pwd)/$src"
done
