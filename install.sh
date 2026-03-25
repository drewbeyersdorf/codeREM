#!/usr/bin/env bash
# codeREM installer -- symlinks tools and sets up config
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/coderem"

echo ""
echo "  codeREM installer"
echo "  ================="
echo ""

# Check dependencies
missing=()
command -v claude >/dev/null 2>&1 || missing+=("claude (Claude Code CLI)")
command -v jq >/dev/null 2>&1 || missing+=("jq")
command -v python3 >/dev/null 2>&1 || missing+=("python3")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "  Missing dependencies:"
  for dep in "${missing[@]}"; do
    echo "    - $dep"
  done
  echo ""
  echo "  Install these first, then re-run."
  exit 1
fi

# Create bin directory
mkdir -p "$BIN_DIR"

# Symlink tools
tools=(deep-dream chronicle-writer chronicle-render render-image nightly-dream)
for tool in "${tools[@]}"; do
  chmod +x "$SCRIPT_DIR/$tool"
  if [[ -L "$BIN_DIR/$tool" ]]; then
    rm "$BIN_DIR/$tool"
  fi
  ln -s "$SCRIPT_DIR/$tool" "$BIN_DIR/$tool"
  echo "  Linked: $tool -> $BIN_DIR/$tool"
done

# Set up config
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/coderem.conf" ]]; then
  cp "$SCRIPT_DIR/coderem.conf.example" "$CONFIG_DIR/coderem.conf"
  echo ""
  echo "  Config created: $CONFIG_DIR/coderem.conf"
  echo "  Edit this file to customize paths and models."
else
  echo ""
  echo "  Config exists: $CONFIG_DIR/coderem.conf (not overwritten)"
fi

# Verify Claude Code memory directory exists
MEMORY_DIR="$HOME/.claude/projects/-home-$(whoami)/memory"
if [[ -d "$MEMORY_DIR" ]]; then
  file_count=$(ls "$MEMORY_DIR"/*.md 2>/dev/null | wc -l)
  echo ""
  echo "  Found $file_count memory files in $MEMORY_DIR"
else
  echo ""
  echo "  WARNING: No memory directory found at $MEMORY_DIR"
  echo "  deep-dream needs Claude Code memory files to consolidate."
  echo "  Update MEMORY_DIR in $CONFIG_DIR/coderem.conf if your files are elsewhere."
fi

echo ""
echo "  ================="
echo "  Install complete!"
echo "  ================="
echo ""
echo "  Try it:  deep-dream --dry-run"
echo "  Full run: deep-dream"
echo "  Schedule: see README for systemd timer setup"
echo ""
