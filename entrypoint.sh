#!/bin/bash
set -e

USERNAME=hannya
HOME_DIR=/home/$USERNAME

if [ "$(id -u)" = "0" ]; then
    mkdir -p $HOME_DIR/workspace
    chown -R ${MYUID:-1000}:${MYGID:-1000} $HOME_DIR

    if [ "$OPENCODE_CONFIG" = "free" ] || [ "$OPENCODE_CONFIG" = "paid" ]; then
        SRC="$HOME_DIR/.config/opencode/oh-my-openagent-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-openagent.json"
        if [ -f "$SRC" ]; then
            cp "$SRC" "$DEST"
        fi
    fi

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec su -l $USERNAME -c "cd ~/workspace && $CMD"
else
    mkdir -p $HOME_DIR/workspace
    cd $HOME_DIR/workspace

    if [ "$OPENCODE_CONFIG" = "free" ] || [ "$OPENCODE_CONFIG" = "paid" ]; then
        SRC="$HOME_DIR/.config/opencode/oh-my-openagent-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-openagent.json"
        if [ -f "$SRC" ]; then
            cp "$SRC" "$DEST"
        fi
    fi

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec $CMD
fi
