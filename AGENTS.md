# AGENTS.md — docker-opencode

## Repo Overview

Docker-based AI development container. Provides OpenCode, uv, Bun, Node.js, and optional CUDA in an isolated Ubuntu 24.04 environment.

**Two images**: `Dockerfile.cpu` and `Dockerfile.gpu` (CUDA 12). Selected via `--profile cpu` or `--profile gpu` in docker compose.

---

## Key Directories

| Path | Purpose |
|------|---------|
| `configs/` | Env templates, OpenCode configs, agent templates |
| `configs/opencode/` | `oh-my-opencode-free.json` and `oh-my-opencode-paid.json` |
| `configs/templates/` | `AGENTS.md-global` (deployed to `~/.config/opencode/AGENTS.md` in container) |
| `data/` | Persistent per-project OpenCode data (gitignored) |
| `.github/workflows/` | CI: docker-build (PR/push), version-check (monthly cron) |

---

## Commands

```bash
# Create project config
cp configs/_template.env configs/my-project.env

# Start container
docker compose --env-file configs/my-project.env --profile cpu up -d

# Enter container
docker exec -it my-project-cpu bash

# Stop
docker compose --env-file configs/my-project.env down
```

Inside the container:
```bash
switch-opencode-config free    # Free models (no API keys)
switch-opencode-config paid    # GitHub Copilot models
switch-opencode-config default # Restore installer config
```

---

## Conventions

- **No hardcoded values**. All configurable values must be defined as constants, env vars, or in config files. Never inline literals for paths, ports, credentials, model names, or feature flags.
- `configs/*.env` files are gitignored except `_template.env`. Never commit personal configs or API keys.
- CI triggers on `Dockerfile.*`, `docker-compose.yml`, and workflow changes only.
- Use only ASCII characters in all files.

---

## Git Rules

- NEVER execute git commands without explicit user permission. Read-only commands (status, log, diff) are allowed for context.
- NEVER mention AI tool names in comments, commit messages, or documentation.
- ALWAYS ask before creating branches for substantial changes. Suggest a branch name and wait for confirmation.
- NEVER commit unless explicitly requested.

---

## References

- Global agent rules: `configs/templates/AGENTS.md-global`
- Project-specific templates: `configs/templates/AGENTS.md-python`
- Full setup: `README.md`
