#!/bin/bash
cd "$(dirname "$0")"

for config in configs/*.env; do
    [ -f "$config" ] || continue
    config_name=$(basename "$config")
    [ "$config_name" = "_template.env" ] && continue
    
    source "$config"
    PROJECT_NAME="${PROJECT_NAME:-default}"
    
    for container_type in gpu cpu; do
        dir=".docker-opencode/${PROJECT_NAME}-${container_type}"
        file="$dir/persistent_bash_history"
        
        if [ ! -f "$file" ]; then
            mkdir -p "$dir"
            touch "$file"
            echo "Created $file"
        else
            echo "Already exists: $file"
        fi
    done
done

echo "Done!"
