#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/opencode"

case "$1" in
  free)
    cp "$CONFIG_DIR/oh-my-openagent-free.json" "$CONFIG_DIR/oh-my-openagent.json"
    echo "Free config activated"
    ;;
  paid)
    cp "$CONFIG_DIR/oh-my-openagent-paid.json" "$CONFIG_DIR/oh-my-openagent.json"
    echo "Paid config activated"
    ;;
  default)
    cp "$CONFIG_DIR/oh-my-openagent-default.json" "$CONFIG_DIR/oh-my-openagent.json"
    echo "Default config restored"
    ;;
  *)
    echo "Usage: $0 {free|paid}"
    echo "  free  - Free models only"
    echo "  paid  - Paid models"
    ;;
esac
