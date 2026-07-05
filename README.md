# AI Workstation Stack

This repository contains the configuration and infrastructure for a specialized AI development environment, featuring local LLM orchestration via Ollama, Dockerized Claude Code, and custom model architectures.

## 🏗️ Infrastructure Overview

### Host Machine
- **OS:** Debian 13 Trixie
- **CPU:** Ryzen 9
- **RAM:** 128 GB
- **GPU:** NVIDIA RTX 5060 Ti (16 GB)
- **Compute:** Docker with NVIDIA GPU passthrough enabled.

## 👥 Users & Workflow

The environment is optimized for a dual-user workflow:
1.  **`tamas`** – primary login user.
2.  **`tehhgoon`** – dedicated AI work user. Switching to this user is done via the `goon` command.

**Standard Developer Loop**
```bash
ssh tamas@<machine>
goon                          # Switch to tehhgoon user
cd ~/ai-stack/some/project    # Navigate to project
claude                        # Launch Claude Code agent
```

## 🐳 Docker & GPU

- **Docker Compose** is installed and works.
- **GPU passthrough** verified with:
```bash
docker run --rm --gpus all nvidia/cuda:13.0.0-base-ubuntu24.04 nvidia-smi
```
- Useful checks:
```bash
docker ps
docker ps -a
```

## ⚙️ Ollama Service & API Checks

Ollama runs directly on the host for maximum performance and accessibility.
- **Service status**: `systemlyctl status ollama --no-pager`
- **API check**: `curl http://localhost:11434/api/tags`
- **Model list**: `ollama list`
- **Running models**: `ollama ps`
- **Model storage**: `/usr/share/ollama/.ollama`

## 🤖 LLM Orchestration

### Ollama (Host-based)
- **API Endpoint:** `http://localhost:11434`
- **Key Models**:
  - Custom gpt-oss 20b and 120b variants
  - Custom Gemma 4 variants

### Model Deployment (`ollama-models/`)
Custom `Modelfiles` are used to optimize models for specific roles:
- **Gemma 4 Variants:** Optimized with large context windows (up or 128k) and system prompts tuned for tool-use protocols (e.g., GitHub Copilot CLI).
- **GPT-OSS Variants:** Large parameter models configured for diverse reasoning tasks.

## 🛠️ Tools & Containers

### Claude Code Agent
Claude Code runs within a specialized, lightweight Docker container to ensure environment isolation and workspace portability.

- **Docker Image:** `claude-code`
- **Dockerfile Source:** `~/ai-stack/claude/Dockerfile.claude`
- **Configuration Persistence:** Managed via the `claude-code-config` Docker volume (mounted to `/root/.claude` inside the container).
- **Workspace Mounting:** The current host directory is mounted as `/workspace` within the container. This allows the agent to interact with local files seamlessly. When you run `claude` from a project directory, that directory's contents are visible inside the container at `/workspace`.

#### Dockerfile (excerpt)
```dockerfile
FROM node:24-bookworm-slim
RUN apt-get update && apt-get install -y \
    git \
    bash \
    curl \
    ca-certificates \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /workspace
ENTRYPOINT ["claude"]
```

#### Build & Run
```bash
# Build the image
cd ~/ai-stack
docker build -f ./claude/Dockerfile.claude -t claude-code .

# Verify version (known working 2.1.178)
claude --version
```

### Global Launcher (`/usr/local/api/claude`)
A wrapper script at `/usr/local/bin/claude` handles network configuration (host networking), environment variables for Ollama API connectivity, and volume mounting.

```bash
#!/usr/bin/env bash
# Example of the launcher logic:
docker run --rm -it \
  --network host \
  -e ANTHROPIC_BASE_URL=http://localhost:11434 \
  -e ANTHROPIC_AUTH_TOKEN=ollama \
  -v "$PWD:/workspace" \
  -v claude-code-config:/root/.claude \
  claude-code "$@"
```

*Note: Ensure the launcher is executable with `sudo chmod 755 /usr/local/bin/claude`.*

## 🚀 Quick Start

1. **Build Claude Code Image**
   ```bash
   docker build -f ./claude/Dockerfile.claude -t claude-code .
   ```
2. **Build & Run Custom Models**
   Refer to `olloma-models/` for specific `ollama create` commands.
3. **Run Agent**
   Navigate to any project directory and run `claude`.

## ⚠️ Known Issues & Maintenance

- **Tool Use Compatibility:** Some smaller models (like `qwen2.5-coder:7b`) may emit raw JSON instead of following the Claude Code tool-calling protocol. Continuous testing of larger/custom variants is ongoing.
- **Container Updates:** Ensure Docker GPU passthrough is verified after any NVIDIA driver updates via `nvidia-smi` within a container.

## 📄 Git Ignore
All files ending with `.last_model` are ignored:
```
*.last_model
```
