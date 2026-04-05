# AI Dev Container

![Docker Build](https://github.com/yursds/docker-opencode/actions/workflows/docker-build.yml/badge.svg)
![Version Check](https://github.com/yursds/docker-opencode/actions/workflows/version-check.yml/badge.svg)

Generic AI-powered development container with OpenCode, uv, Bun, and CUDA support.

---

## Setup

### 1. Create a project config

```bash
cp configs/_template.env configs/my-project.env
```

Edit it:
```env
PROJECT_NAME=my-project
PROJECT_PATH=/path/to/your/repo
OPENCODE_CONFIG=free
```

### 1b. Check your user ID

Files created by the container are owned by your user. To avoid ownership mismatches, your container user must have the same UID/GID as your host user.

Open a terminal on your **host** (outside Docker) and run:

```bash
id
```

You'll see something like:
```
uid=1000(yours) gid=1000(yours) groups=1000(yours),27(sudo)
```

The numbers `1000` are your UID and GID.

- **If both are 1000**: default values work, no changes needed
- **If different** (e.g. `uid=1001`): edit your `.env`:
  ```env
  MYUID=1001
  MYGID=1001
  ```
  Then rebuild: `docker compose build`

### 2. Start the container

```bash
docker compose --env-file configs/my-project.env --profile cpu up -d
# or --profile gpu for CUDA
```

### 3. Enter & work

```bash
docker exec -it my-project-cpu bash
```

On first entry, `uv sync` runs automatically if `pyproject.toml` exists in the workspace.
Otherwise a reminder is printed.

---

## OpenCode Config

Bundled configs in `configs/opencode/`:

| Value | Models | API Keys needed |
|-------|--------|----------------|
| `free` | qwen3.6-plus-free, nemotron, minimax, big-pickle | No |
| `paid` | GitHub Copilot (Claude, GPT-5, Gemini) | GitHub Copilot token |

To switch: edit `OPENCODE_CONFIG` in your `.env` and restart the container.

### Switch at runtime

Inside the container, switch configs without restarting:

```bash
switch-opencode-config free    # Free models only
switch-opencode-config paid    # GitHub Copilot models
```

### No API Keys?

If you leave all API keys empty and use `OPENCODE_CONFIG=free`, everything works — the free tier models (`opencode/*`) don't require any keys.

If you use `OPENCODE_CONFIG=paid`, you'll need the corresponding API keys set in the `.env`.

---

## Agent Guidelines

A global `AGENTS.md` is deployed to `~/.config/opencode/AGENTS.md` on first boot.
It applies to all OpenCode sessions in the container.

For project-specific guidelines, copy a template into your project root:
```bash
cp configs/templates/AGENTS.md-python /path/to/your/repo/AGENTS.md
```

---

## Multiple Projects

Each project gets its own config file and isolated container:

```bash
docker compose --env-file configs/project-alpha.env --profile gpu up -d
docker compose --env-file configs/project-beta.env --profile cpu up -d
```

Both run simultaneously — no name collisions.

| Config | Image | Container |
|--------|-------|-----------|
| `project-alpha.env` | `opencode-uv:gpu` | `project-alpha-gpu` |
| `project-beta.env` | `opencode-uv:cpu` | `project-beta-cpu` |

---

## What's Inside

| Tool | Purpose |
|------|---------|
| **uv** | Python package manager |
| **Node.js** | JavaScript runtime (for oh-my-openagent) |
| **Bun** | JavaScript runtime |
| **OpenCode** | AI coding agent |
| **oh-my-openagent** | Agent orchestration layer |

See `VERSIONS.md` for tested versions.

---

## Common Commands

```bash
# Install a Python dependency
uv add <package>

# Lint & format
uv run ruff check . && uv run ruff format .

# Run a script
uv run script.py

# Run tests
uv run pytest
```

---

## Config Reference

| Env Var | Required | Description |
|---------|----------|-------------|
| `PROJECT_NAME` | Yes | Unique name — used for container naming |
| `PROJECT_PATH` | Yes | Absolute path to your repo |
| `MYUID` / `MYGID` | No | Must match your host user — run `id` to check (default: 1000) |
| `OPENCODE_CONFIG` | No | Config preset: `free`, `paid`, `default` |
| `ANTHROPIC_API_KEY` | No | Anthropic API key |
| `OPENAI_API_KEY` | No | OpenAI API key |
| `GOOGLE_API_KEY` | No | Google API key |

---

## References

| Project | URL |
|---------|-----|
| OpenCode | https://opencode.ai |
| oh-my-openagent | https://github.com/code-yeongyu/oh-my-openagent |
| uv | https://docs.astral.sh/uv/ |
| ruff | https://docs.astral.sh/ruff/ |
| Bun | https://bun.sh/docs |
| Docker Compose | https://docs.docker.com/compose/ |

---

## Stop & Cleanup

```bash
# Stop a specific project
docker compose --env-file configs/my-project.env down

# Remove container + image
docker compose --env-file configs/my-project.env down --rmi all

# Stop everything at once
docker compose down
```
