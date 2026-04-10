#!/bin/bash
set -e

cd "$(dirname "$0")"

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

check_and_fix_permissions() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        return 0
    fi
    
    local dir_owner=$(stat -c '%u' "$dir" 2>/dev/null)
    
    if [ "$dir_owner" = "0" ]; then
        echo "WARNING: $dir is owned by root!"
        echo "This happens if Docker created the directory before init_history.sh was run."
        echo "Fixing permissions..."
        rm -rf "$dir"
        return 1
    fi
}

for config in configs/*.env; do
    [ -f "$config" ] || continue
    config_name=$(basename "$config")
    [ "$config_name" = "_template.env" ] && continue
    
    source "$config"
    PROJECT_NAME="${PROJECT_NAME:-default}"
    
    for container_type in gpu cpu; do
        dir=".data_history/${PROJECT_NAME}-${container_type}"
        file="$dir/persistent_bash_history"
        
        if check_and_fix_permissions "$dir"; then
            if [ -f "$file" ]; then
                echo "Already exists: $file"
            fi
        else
            mkdir -p "$dir"
            touch "$file"
            chown ${CURRENT_UID}:${CURRENT_GID} "$dir" "$file"
            echo "Created and fixed permissions: $file"
        fi
        
        if [ ! -f "$file" ]; then
            mkdir -p "$dir"
            touch "$file"
            chown ${CURRENT_UID}:${CURRENT_GID} "$dir" "$file"
            echo "Created: $file"
        fi
    done
done

echo ""
echo "Done! Bash history will persist across container restarts."
