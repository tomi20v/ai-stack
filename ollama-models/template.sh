#!/bin/bash

# This script generates an Ollama Modelfile by concatenating template partials.
# It resides in ollama-models/ and resolves all paths relative to its own location.

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <base_model> <variant_name>" >&2
    exit 1
fi

BASE_MODEL="$1"
VARIANT_NAME="$2"

# Validate variant name starts with base_model-
if [[ ! "$VARIANT_NAME" =~ ^${BASE_MODEL}- ]]; then
    echo "Error: variant name must start with '${BASE_MODEL}-'" >&2
    exit 1
fi

# Resolve the templates directory relative to script location
TEMPLATES_DIR="${SCRIPT_DIR}/_templates"
if [ ! -d "${TEMPLATES_DIR}" ]; then
    echo "Error: _templates directory not found" >&2
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR="${SCRIPT_DIR}/${BASE_MODEL}"
mkdir -p "${OUTPUT_DIR}"

# Output file path
OUTPUT_FILE="${OUTPUT_DIR}/Modelfile.${VARIANT_NAME}"

# Initialize the output file
> "${OUTPUT_FILE}"

# Extract option tokens from variant name (remove base_model- prefix and split on -)
OPTION_TOKENS=()
if [[ "$VARIANT_NAME" =~ ^${BASE_MODEL}-(.*)$ ]]; then
    TOKENS="${BASH_REMATCH[1]}"
    IFS='-' read -ra OPTION_TOKENS <<< "$TOKENS"
fi

# Process each entry in _templates directory in sorted order (both files and directories)
# Get all entries sorted by name and process them in order
entries=()
while IFS= read -r -d '' entry; do
    [ -e "$entry" ] || continue
    basename_entry=$(basename "$entry")
    [ "$basename_entry" = "_templates" ] && continue
    entries+=("$entry")
done < <(find "${TEMPLATES_DIR}" -maxdepth 1 \( -type f -o -type d \) -print0 | sort -zV)

# Process all entries in order (this maintains the sequence)
for entry in "${entries[@]}"; do
    # Check if it's a regular file
    if [ -f "$entry" ]; then
        # For regular files, read content and substitute #MODEL_NAME# with BASE_MODEL 
        cat "$entry" | sed "s/#MODEL_NAME#/$BASE_MODEL/g" >> "${OUTPUT_FILE}"
    # Handle directories (template options)
    elif [ -d "$entry" ]; then
        MATCH_FOUND=false
        MATCH_FILE=""
        
        # List all files within this directory (we'll match against them)
        while IFS= read -r -d '' option_file; do
            [ -e "$option_file" ] || continue
            
            # Get the filename without leading dash for matching
            option_filename=$(basename "$option_file")
            if [[ "$option_filename" == -* ]]; then
                token_without_dash="${option_filename#-}"
                
                # Check if this matches any of our tokens
                for token in "${OPTION_TOKENS[@]}"; do
                    if [ "$token" = "$token_without_dash" ]; then
                        # Found a match
                        if [ "$MATCH_FOUND" = true ]; then
                            echo "Error: multiple matches found for option directory '$(basename "$entry")'" >&2
                            rm -f "${OUTPUT_FILE}"
                            exit 1
                        fi
                        MATCH_FOUND=true
                        MATCH_FILE="$option_file"
                    fi
                done
            fi
        done < <(find "$entry" -maxdepth 1 -type f -print0 | sort -zV)
        
        # If no match, error
        if [ "$MATCH_FOUND" = false ]; then
            echo "Error: no matching option found for directory '$(basename "$entry")'" >&2
            rm -f "${OUTPUT_FILE}"
            exit 1
        fi
        
        # For matching directory files, substitute #MODEL_NAME# with BASE_MODEL
        cat "$MATCH_FILE" | sed "s/#MODEL_NAME#/$BASE_MODEL/g" >> "${OUTPUT_FILE}"
    fi
done