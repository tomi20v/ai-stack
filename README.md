# AI Workstation Stack

This repository contains the configuration and infrastructure for a specialized AI development environment, featuring local LLM orchestration via Ollama, Dockerized Claude Code, and custom model architectures.

## 🏗️ Infrastructure Overview

### Host Machine
- **OS:** Debian 13 Trixie
- **CPU:** Ryzen 9
- **RAM:** 128 GB
- **GPU:** NVIDIA RTX 5060 Ti (16 GB)
- **Compute:** Docker with NVIDIA GPU passthrough enabled.

### Users & Workflow
The environment is optimized for a dual-user workflow:
1.  **`tamas`**: Primary login user.
2.  **`tehhgoon`**: Dedicated AI work user.

**Standard Developer Loop:**
```bash
ssh tamas@<machine>
goon                          # Switch to tehhgoon user
cd ~/projects/my-project      # Navigate to project
claude                        # Launch Claude Code agent
```

## 🤖 LLM Orchestration

### Ollama (Host-based)
Ollama runs directly on the host for maximum performance and accessibility.
- **API Endpoint:** `http://localhost:11434`
- **Model Storage:** `/usr/share/ollama/.ollama`
- **Key Models:**
  - `qwen2.5-coder:7b` (Baseline, currently testing tool-use compatibility)
  - Custom Gemma 4 variants (see `ollama-models/`)

### Model Deployment (`ollama-models/`)
Custom `Modelfiles` are used to optimize models for specific roles:
- **Gemma 4 Variants:** Optimized with large context windows (up to 128k) and system prompts tuned for tool-use protocols (e.g., GitHub Copilot CLI).
- **GPT-OSS Variants:** Large parameter models configured for diverse reasoning tasks.

## 🛠️ Tools & Containers

### Claude Code Agent
Claude Code runs within a specialized, lightweight Docker container to ensure environment isolation and workspace portability.

- **Docker Image:** `claude-code`
- **Dockerfile Source:** `./claude/Dockerfile.claude`
- **Configuration Persistence:** Managed via the `claude-code-config` Docker volume (mapped to `/root/.claude` inside the container).
- **Workspace Mounting:** The current host directory is mounted as `/workspace` within the container, allowing the agent to interact with local files seamlessly.

**The Global Launcher (`/usr/local/bin/claude`):**
A wrapper script that handles network configuration (host networking), environment variables for Ollama API connectivity, and volume mounting.
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

## 🚀 Quick Start

1.  **Build Claude Code Image:**
    ```bash
    docker build -f ./claude/Dockerfile.claude -t claude-code .
    ```
2.  **Build & Run Custom Models:**
    Refer to `ollama-models/` for specific `ollama create` commands.
3.  **Run Agent:**
    Navigate to any project directory and run `claude`.

## ⚠️ Known Issues & Maintenance
- **Tool Use Compatibility:** Some smaller models (like `qwen2.5-coder:7b`) may emit raw JSON instead of following the Claude Code tool‑calling protocol. Continuous testing of larger/custom variants is ongoing.
- **Container Updates:** Ensure Docker GPU passthrough is verified after any NVIDIA driver updates via `nvidia-smi` within a container.
