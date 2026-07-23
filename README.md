# AI Workstation Stack

This repository contains the configuration and infrastructure for a specialized AI development environment, featuring local LLM orchestration via Ollama, Dockerized Claude Code, and custom model architectures.

## 🏗️ Infrastructure Overview

### Host Machine
- **OS:** Debian 13 Trixie
- **CPU:** Ryzen 9
- **RAM:** 128 GB
- **GPU:** NVIDIA RTX 5060 Ti (16 GB)
- **Compute:** Docker with NVIDIA GPU passthrough enabled.

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
- **Service status**: `systemctl status ollama --no-pager`
- **API check**: `curl http://localhost:11434/api/tags`
- **Model list**: `ollama list`
- **Running models**: `ollama ps`
- **Model storage**: `/usr/share/ollama/.ollama`

## 🤖 LLM Orchestration

### Ollama (Host-based)
- **API Endpoint:** `http://localhost:11434`
- **Key Models**:
  - Custom gpt-oss 20b variants
  - Custom gpt-oss 120b variants

### Model Deployment (`ollama-models/`)
Custom `Modelfiles` are used to optimize models for specific roles:
- **GPT-OSS Variants:** Large parameter models configured for diverse reasoning tasks.

## 🛠️ Tools & Containers

### Claude Code Agent
Claude Code runs within a specialized, lightweight Docker container to ensure environment isolation and workspace portability.

- **Docker Image:** `claude-code`
- **Dockerfile Source:** `~/ai-stack/docker/claude/Dockerfile.claude`
- **Configuration Persistence:** Managed via the `claude-code-config` Docker volume (mounted to `/root/.claude` inside the container).
- **Workspace Mounting:** The current host directory is mounted as `/workspace` within the container. This allows the agent to interact with local files seamlessly. When you run `claude` from a project directory, that directory's contents are visible inside the container at `/workspace`.

## 🚀 Quick Start

1. **Build & Run Custom Models**
   Use `model-manager.sh` to build ollama model variants. Only those built with this utility will show up in my launchers
2. **Run Agent**
   Navigate to any project directory and run `claude-host-launcher`.
3. If you want to run claude (or copilot) in screen, use `screen -U` for unicode terminal support

## 📈 Monitoring

- GPU/CPU temperature monitoring scripts available in the repository
- Scripts for tracking system performance during LLM inference sessions

## 🧪 Testbed Purpose

This repository serves as a personal testbed for AI experimentation, featuring:
- Dockerized Claude Code environments
- Local Ollama served LLM models
- Customized model session configurations
- System monitoring capabilities for performance analysis
