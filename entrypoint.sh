#!/bin/bash
set -e

cd /workspace

# ── OpenCode config ──────────────────────────────────────────────────────────
CONFIG_DIR="/home/coder/.config/opencode"
mkdir -p "$CONFIG_DIR"

if [ -n "$OPENCODE_CONFIG" ] && [ "$OPENCODE_CONFIG" != "default" ]; then
    SRC="/workspace/configs/opencode/oh-my-opencode-${OPENCODE_CONFIG}.json"
    DEST="$CONFIG_DIR/oh-my-opencode.json"
    if [ -f "$SRC" ]; then
        if [ ! -f "$DEST" ] || [ "$SRC" -nt "$DEST" ]; then
            cp "$SRC" "$DEST"
        fi
    fi
fi

# ── uv sync ──────────────────────────────────────────────────────────────────
if [ -f pyproject.toml ]; then
    if [ ! -d .venv ] || [ ! -f .venv/bin/python ]; then
        uv sync
    fi
fi

exec "$@"
