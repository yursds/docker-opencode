#!/bin/bash
set -e

sudo chown -R hannya:hannya "$HOME" 2>/dev/null || true

cd "$HOME/workspace"

mkdir -p "$HOME/.config/opencode" "$HOME/.local/bin" "$HOME/.local/share"

# Restore all configs + templates from build if not present
if [ ! -f "$HOME/.config/opencode/opencode.json" ] && [ -d /opt/opencode-config ]; then
    cp -r /opt/opencode-config/* "$HOME/.config/opencode/" 2>/dev/null || true
fi

# Apply OPENCODE_CONFIG selection at boot
if [ -n "$OPENCODE_CONFIG" ] && [ "$OPENCODE_CONFIG" != "default" ]; then
    SRC="/opt/opencode-config/oh-my-opencode-${OPENCODE_CONFIG}.json"
    DEST="$HOME/.config/opencode/oh-my-opencode.json"
    if [ -f "$SRC" ]; then
        cp "$SRC" "$DEST"
    fi
fi

exec "$@"
