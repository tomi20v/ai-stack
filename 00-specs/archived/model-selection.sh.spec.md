# model-selection.sh Specification

Create a new script `model-selection.sh` that:

1. Takes one input parameter (e.g., `-cpilot`, `-claude`, `-gemini`)
2. Filters `ollama list` output for models matching that parameter
3. Displays an interactive list with fzf for selection (up/down arrows)
4. If fzf is not installed, displays a message to install it
5. Returns the selected model name to stdout for chaining

Example usage:
- `model-selection.sh copilot` → displays interactive list of copilot-compatible models, returns selected model to stdout
- `model-selection.sh claude` → displays interactive list of claude-compatible models, returns selected model to stdout
- `model-selection.sh gemini` → displays interactive list of gemini-compatible models, returns selected model to stdout
- `MODEL=$(model-selection.sh copilot)` → chains the output to a variable

Model matching examples:
- `gemma4:26b-128k-copilot` matches `copilot`
- `gemma4:26b-claude` matches `claude`
- `gemma4:26b` does NOT match any of the above
- `gemma4:26b-128k-gemini` matches `gemini`