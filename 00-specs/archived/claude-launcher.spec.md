# claude-launcher

## Overview

`claude-launcher` is a shell script that launches Claude Code with a specified Ollama model. It provides both interactive and command-line model selection options.

## Features

### Interactive Model Selection

When no model is specified, the script:
1. Discovers Ollama models containing 'claude' in their names
2. Presents a selection interface using fzf if available, or manual input otherwise
3. Validates the selected model exists in Ollama
4. Launches Claude Code with the selected model

### Command-Line Model Specification

The script accepts model names via command-line arguments:
- Positional argument: `./claude-launcher <model-name>`
- Flag argument: `./claude-launcher --model <model-name>`

When a model is specified:
1. The script validates the model exists in Ollama
2. Launches Claude Code with the specified model
3. Skips interactive selection

## Usage

```bash
# Interactive selection
./claude-launcher

# Use specific model as positional argument
./claude-launcher glm-4.7-flash-100k-claude

# Use specific model with --model flag
./claude-launcher --model glm-4.7-flash-100k-claude
```

## Environment Variables

The script sets these environment variables when launching Claude Code:
- `ANTHROPIC_BASE_URL=http://localhost:11435`
- `ANTHROPIC_AUTH_TOKEN=ollama`
- `ANTHROPIC_API_KEY=""`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL=<model>`
- `ANTHROPIC_DEFAULT_SONNET_MODEL=<model>`
- `ANTHROPIC_DEFAULT_OPUS_MODEL=<model>`

## Requirements

- Ollama must be installed and running
- Claude Code must be installed and available in PATH
- Model must exist in Ollama's model list