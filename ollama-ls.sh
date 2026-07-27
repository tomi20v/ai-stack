#!/usr/bin/env bash
set -euo pipefail

if ! command -v ollama >/dev/null 2>&1; then
  echo "Error: ollama is not installed or not in PATH." >&2
  exit 1
fi

ollama list | awk 'NR > 1 {print $1}' | sort -V
