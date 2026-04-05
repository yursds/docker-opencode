#!/bin/bash
set -e

USERNAME=hannya
HOME_DIR=/home/$USERNAME

setup_config() {
    if [ "$OPENCODE_CONFIG" = "free" ] || [ "$OPENCODE_CONFIG" = "paid" ]; then
        SRC="$HOME_DIR/.config/opencode/oh-my-openagent-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-openagent.json"
        if [ -f "$SRC" ]; then
            cp "$SRC" "$DEST"
        fi
    fi
}

handle_workspace() {
    mkdir -p $HOME_DIR/workspace
    cd $HOME_DIR/workspace

    if [ -f "$HOME_DIR/workspace/pyproject.toml" ]; then
        uv sync
    else
        echo "⚠ No pyproject.toml found. This container is designed for uv + OpenCode."
        echo "  Create a pyproject.toml or run: uv init"
    fi
}

if [ "$(id -u)" = "0" ]; then
    chown -R ${MYUID:-1000}:${MYGID:-1000} $HOME_DIR
    setup_config

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec su -l $USERNAME -c "
        mkdir -p ~/workspace
        cd ~/workspace
        if [ -f ~/workspace/pyproject.toml ]; then
            uv sync
        else
            echo '⚠ No pyproject.toml found. This container is designed for uv + OpenCode.'
            echo '  Create a pyproject.toml or run: uv init'
        fi
        $CMD
    "
else
    setup_config
    handle_workspace

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec $CMD
fi
