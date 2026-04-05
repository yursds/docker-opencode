#!/bin/bash
set -e

USERNAME=hannya
HOME_DIR=/home/$USERNAME
MYUID=1000
MYGID=1000

if [ "$(id -u)" = "0" ]; then
    mkdir -p $HOME_DIR
    chown $MYUID:$MYGID $HOME_DIR

    mkdir -p $HOME_DIR/workspace
    chown $MYUID:$MYGID $HOME_DIR/workspace

    mkdir -p $HOME_DIR/.config/opencode $HOME_DIR/.local/bin $HOME_DIR/.local/share
    chown -R $MYUID:$MYGID $HOME_DIR/.config $HOME_DIR/.local

    if [ ! -f $HOME_DIR/.config/opencode/opencode.json ] && [ -d /opt/opencode-config ]; then
        cp -r /opt/opencode-config/* $HOME_DIR/.config/opencode/ 2>/dev/null || true
    fi

    if [ -n "$OPENCODE_CONFIG" ] && [ "$OPENCODE_CONFIG" != "default" ]; then
        SRC="/opt/opencode-config/oh-my-opencode-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-opencode.json"
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
    mkdir -p $HOME_DIR/workspace $HOME_DIR/.config/opencode $HOME_DIR/.local/bin $HOME_DIR/.local/share
    cd $HOME_DIR/workspace

    if [ ! -f $HOME_DIR/.config/opencode/opencode.json ] && [ -d /opt/opencode-config ]; then
        cp -r /opt/opencode-config/* $HOME_DIR/.config/opencode/ 2>/dev/null || true
    fi

    if [ -n "$OPENCODE_CONFIG" ] && [ "$OPENCODE_CONFIG" != "default" ]; then
        SRC="/opt/opencode-config/oh-my-opencode-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-opencode.json"
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
