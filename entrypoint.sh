#!/bin/bash
set -e

DOCKER_USERNAME=${DOCKER_USERNAME:-hannya}
HOME_DIR=/home/$DOCKER_USERNAME

setup_config() {
    if [ "$OPENCODE_CONFIG" = "free" ] || [ "$OPENCODE_CONFIG" = "paid" ]; then
        SRC="$HOME_DIR/.config/opencode/oh-my-openagent-${OPENCODE_CONFIG}.json"
        DEST="$HOME_DIR/.config/opencode/oh-my-openagent.json"
        if [ -f "$SRC" ]; then
            cp "$SRC" "$DEST"
        fi
    fi
}

setup_bash_history() {
    # Ensure bash_history is stored in the mounted .docker-opencode folder
    # This persists across container restarts and is isolated per-project+container
    if [ -d "$HOME_DIR/.docker-opencode" ]; then
        if [ ! -f "$HOME_DIR/.docker-opencode/bash_history" ]; then
            touch "$HOME_DIR/.docker-opencode/bash_history"
        fi
        if [ ! -L "$HOME_DIR/.bash_history" ] && [ "$HOME_DIR/.bash_history" != "$HOME_DIR/.docker-opencode/bash_history" ]; then
            ln -sf "$HOME_DIR/.docker-opencode/bash_history" "$HOME_DIR/.bash_history"
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
    
    mkdir -p "$HOME_DIR"
    if [ ! -f "$HOME_DIR/.bash_profile" ]; then
        echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' > "$HOME_DIR/.bash_profile"
    elif ! grep -q 'bashrc' "$HOME_DIR/.bash_profile" 2>/dev/null; then
        echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> "$HOME_DIR/.bash_profile"
    fi
    
    setup_config
    setup_bash_history

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec su -l $DOCKER_USERNAME -c "
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
    setup_bash_history
    handle_workspace

    if [ $# -gt 0 ]; then
        CMD="$*"
    else
        CMD="bash"
    fi

    exec $CMD
fi