# AI Workstation Stack

This repository contains the configuration and infrastructure for a specialized AI development environment, featuring local LLM orchestration via Ollama, Dockerized Claude Code, and custom model architectures.

## 🏗️ Infrastructure Overview

### Host Machine
- **OS:** Debian 13 Trixie
- **CPU:** Ryzen 9
- **RAM:** 128 GB
- **GPU:** NVIDIA RTX 5060 Ti (16 GB)
- **Compute:** Docker with NVIDIA GPU passthrough enabled.

## ⚙️ Ollama Service & API Checks

Ollama runs directly on the host for maximum performance and accessibility.
- **Service status**: `systemctl status ollama --no-pager`
- **API check**: `curl http://localhost:11434/api/tags`
- **Model list**: `ollama list`
- **Running models**: `ollama ps`
- **Model storage**: `/usr/share/ollama/.ollama`

### Proxy & Traffic Inspection

- **Ollama Proxy**: Run `ollama-proxy.sh` to start mitmproxy in reverse mode, exposing inspector at http://127.0.0.1:8081 for inspecting Ollama traffic

## 🤖 LLM Orchestration

### Ollama (Host-based)
- **API Endpoint:** `http://localhost:11434`
- **Example Models**:
  - Custom gpt-oss 20b variants
  - Custom gpt-oss 120b variants

### Model Deployment (`ollama-models/`)
Custom `Modelfiles` are used to optimize models for specific roles:
- **GPT-OSS Variants:** Large parameter models configured for diverse reasoning tasks.

## 🛠️ Tools & Containers

### Model Management
- **Model Manager**: `model-manager.sh` - Interactive interface for selecting and building Ollama models with templates; supports base model selection, version generation, and token limit configuration (64k/100k/128k/256k context windows)

### Shell Utilities
- **Model List**: `ollama-ls.sh` - List Ollama models
- **Temperature Monitor**: `temps.sh` - System temperature monitoring
- **Build Models**: `ollama-models/build_models.sh` - Build Ollama model variants

### Agent Launchers
- **Copilot Launcher**: `copilot-launcher` - Supports model selection on start
- **Claude Launcher**: `claude-launcher` - Supports model selection
- ** Gemini Launcher**: 'gemini-launcher' - the same here

### Claude Code Agent
- Previously I've been running claude and copilot inside docker but dropped that. Files are still in `docker` folder

## 🤖 AI Agent Workflow

This repository uses the `AGENTS.md` file for the SDD (Software Design Document) workflow, including delta specifications, plan creation, implementation with vertical slicing, and archival procedures.

## 🚀 Quick Start

1. **Build & Run Custom Models**
   Use `model-manager.sh` to select and build Ollama model variants with different context window sizes (64k, 100k, 128k, 256k)
2. **Run Claude Agent**
   Navigate to any project directory and run `claude-launcher`.
3. **Run Copilot Agent**
   Use `copilot-host-launcher` with dynamic token limits based on model context window
4. If you want to run claude (or copilot) in screen, use `screen -U` for unicode terminal support

## 📈 Monitoring

- **Ollama Logs**: Follow Ollama service logs with `ollama-journald.sh` (runs `journalctl -u ollama --no-hostname -f`)
- GPU/CPU temperature monitoring scripts available in the repository
- Scripts for tracking system performance during LLM inference sessions

## 🧪 Testbed Purpose

This repository serves as a personal testbed for AI experimentation, featuring:
- Dockerized Claude Code environments
- Local Ollama served LLM models
- Customized model session configurations
- System monitoring capabilities for performance analysis
