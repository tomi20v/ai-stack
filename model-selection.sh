#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(pwd)"

# Parse command line arguments
FILTER_KEYWORD="${1:-}"

if [[ -z "$FILTER_KEYWORD" ]]; then
  echo "Error: No filter keyword specified." >&2
  echo "Usage: $0 <keyword>" >&2
  echo "Example: $0 copilot" >&2
  exit 1
fi

if [[ "$FILTER_KEYWORD" == "-h" ]] || [[ "$FILTER_KEYWORD" == "--help" ]]; then
  echo "Usage: $0 <keyword>"
  echo ""
  echo "Arguments:"
  echo "  keyword  String to match in model names (case-insensitive)"
  echo ""
  echo "Example:"
  echo "  $0 copilot"
  echo "  $0 claude"
  echo "  $0 gemini"
  echo "  $0 mycustomtag"
  exit 0
fi

get_ollama_models() {
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Error: ollama is not installed or not in PATH." >&2
    exit 1
  fi

  mapfile -t models < <(
    ollama list |
      awk "NR > 1 && tolower(\$1) ~ /$FILTER_KEYWORD/ {print \$1}" |
      sort -u
  )
}

select_model() {
  local choice=""

  if command -v fzf >/dev/null 2>&1; then
    echo "Available models:"
    choice="$(printf '%s\n' "${models[@]}" | fzf --prompt='Select model: ')"
  else
    echo "**********************************************************************************" >&2
    echo "Warning: fzf is not installed. For best experience install it eg 'apt install fzf'" >&2
    echo "**********************************************************************************" >&2
    echo "Available models:"
    printf '  %s\n' "${models[@]}"
    read -rp "Enter model name: " choice
  fi

  if [[ -z "$choice" ]]; then
    echo "Error: no model selected." >&2
    exit 1
  fi

  if ! printf '%s\n' "${models[@]}" | grep -Fxq -- "$choice"; then
    echo "Error: '$choice' is not among the available models." >&2
    exit 1
  fi

  SELECTED_MODEL="$choice"
}

get_ollama_models

if [[ ${#models[@]} -eq 0 ]]; then
  echo "No Ollama models containing '$FILTER_KEYWORD' were found." >&2
  exit 1
fi

select_model

echo "$SELECTED_MODEL"