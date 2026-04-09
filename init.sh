#!/bin/bash
# Run this before: docker compose --env-file configs/<project>.env --profile gpu up

[ -f "$1" ] && source "$1"
PROJECT_NAME="${PROJECT_NAME:-autoresearchclaw}"

mkdir -p ".docker-opencode/${PROJECT_NAME}-gpu"
mkdir -p ".docker-opencode/${PROJECT_NAME}-cpu"
touch ".docker-opencode/${PROJECT_NAME}-gpu/bash_history"
touch ".docker-opencode/${PROJECT_NAME}-cpu/bash_history"

echo "Created .docker-opencode directories for $PROJECT_NAME"
