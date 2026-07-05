#!/bin/bash

# This script iterates through Modelfile.* files in the current directory
# and one level of subdirectories, and runs 'ollama create' for each,
# extracting the name from the filename.

found_any=false

while IFS= read -r f; do
    if [ ! -e "$f" ]; then
        continue
    fi
    found_any=true

    # Extract name: remove 'Modelfile.' prefix from the basename
    base_f=$(basename "$f")
    model_name="${base_f#Modelfile.}"

    echo "Creating model '$model_name' from '$f'..."
    ollama create "$model_name" -f "$f"
done < <(find . -maxdepth 2 -name "Modelfile.*")

if [ "$found_any" = false ]; then
    echo "No Modelfile.* files found in current directory or one level of subdirectories."
    exit 0
fi

echo "Done."
