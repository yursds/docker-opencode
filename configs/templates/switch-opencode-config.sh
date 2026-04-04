#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/opencode"

case "$1" in
  free)
    cp "$CONFIG_DIR/oh-my-opencode-free.json" "$CONFIG_DIR/oh-my-apenagent.json"
    echo "FREE activated (OpenCode Zen free models)"
    ;;
  paid)
    cp "$CONFIG_DIR/oh-my-opencode-paid.json" "$CONFIG_DIR/oh-my-openagent.json"
    echo "PAID activated (GitHub Copilot models)"
    ;;
  default)
    cp "$CONFIG_DIR/oh-my-openagent.json.bak" "$CONFIG_DIR/oh-my-openagent.json"
    echo "Default config restored (from installer backup)"
    ;;
  *)
    echo "Usage: $0 {free|paid|default}"
    echo "  free    - OpenCode Zen free models only"
    echo "  paid    - GitHub Copilot models"
    echo "  default - Restore installer-generated config"
    ;;
esac
