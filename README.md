# AI Dev Container

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

### 2. Start the container

```bash
docker compose --env-file configs/my-project.env --profile cpu up -d
# or --profile gpu for CUDA
```

### 3. Enter & work

```bash
docker exec -it my-project-cpu bash
```

The entrypoint auto-runs `uv sync` if `pyproject.toml` exists.

### 4. Add agent guidelines (optional)

Copy the bundled template into your project root:

```bash
cp configs/templates/AGENTS.md-python /path/to/your/repo/AGENTS.md
```

OpenCode reads `AGENTS.md` from the project root automatically on every session.
Customize it to match your project's specific conventions.

---

## OpenCode Config

Bundled configs in `configs/opencode/`:

| Value | Models | API Keys needed |
|-------|--------|----------------|
| `free` | qwen3.6-plus-free, nemotron, minimax, big-pickle | No |
| `paid` | GitHub Copilot (Claude, GPT-5, Gemini) | GitHub Copilot token |
| `default` | Built-in OpenCode defaults | Depends on model |

To switch: edit `OPENCODE_CONFIG` in your `.env` and restart the container.

### No API Keys?

If you leave all API keys empty and use `OPENCODE_CONFIG=free`, everything works — the free tier models (`opencode/*`) don't require any keys.

If you use `OPENCODE_CONFIG=paid` or leave it `default`, you'll need the corresponding API keys set in the `.env` or on the host.

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

| Tool | Version | Purpose |
|------|---------|---------|
| **uv** | 0.11.3 | Python package manager |
| **Node.js** | 20.18.0 | JavaScript runtime (for oh-my-openagent) |
| **Bun** | latest | JavaScript runtime |
| **OpenCode** | latest | AI coding agent |
| **oh-my-openagent** | latest | Agent orchestration layer |

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
| `MYUID` / `MYGID` | No | User/group ID (default: 1000) |
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
