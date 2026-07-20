#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OLLAMA_MODELS_DIR="${SCRIPT_DIR}/ollama-models"

# Function to get base models from ollama
get_base_models() {
    # Get list of all models from ollama (using fallback if JSON fails)
    local all_models
    all_models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    if [ -z "$all_models" ]; then
        return
    fi

    # Filter out models containing -copilot, -claude, or -<digits>k pattern
    echo "$all_models" | grep -vE '(-copilot|-claude|-[0-9]+k)'
}

# Abstracted source for version prefixes.
# Reads from ollama-models/_templates directory.
# Each subdirectory in _templates is a group of prefixes.
get_version_prefixes() {
    local templates_dir="${SCRIPT_DIR}/ollama-models/_templates"

    if [ ! -d "$templates_dir" ]; then
        return
    fi

    # Find all directories in _templates, sorted by name
    # For each directory, get its contents (the prefixes) as a space-separated string
    find "$templates_dir" -mindepth 1 -maxdepth 1 -type d | sort | while read -r template_group_path; do
        local group_name
        group_name=$(basename "$template_group_path")

        # Get the contents of this directory as a single line (space-separated prefixes)
        local prefixes
        prefixes=$(ls -A "$template_group_path" 2>/dev/null | tr '\n' ' ' | sed 's/ $//')

        if [ -n "$prefixes" ]; then
            echo "$prefixes"
        fi
    done
}

# Function to generate all combinations of versions for a given base model
generate_versions() {
    local base_model="$1"
    shift
    local prefix_groups=("$@")
    local current_combinations=("$base_model")

    for group in "${prefix_groups[@]}"; do
        local next_combinations=()
        # Split the group into individual prefixes
        read -r -a prefixes <<< "$group"

        for combo in "${current_combinations[@]}"; do
            for prefix in "${prefixes[@]}"; do
                next_combinations+=("${combo}${prefix}")
            done
        done
        current_combinations=("${next_combinations[@]}")
    done

    for combo in "${current_combinations[@]}"; do
        echo "$combo"
    done
}

# Refactored selection function to be generic
select_from_list() {
    local prompt_msg="$1"
    shift
    local items=("$@")

    if [ ${#items[@]} -eq 0 ]; then
        echo ""
        return
    fi

    if command -v fzf &> /dev/null; then
        printf "%s\n" "${items[@]}" | fzf --prompt="$prompt_msg: " --exit-0
    else
        {
            echo "Install fzf to get a better user experience, e.g., \"apt install fzy\""
            echo ""
            echo "Items found:"
            echo "----------------------------------------------------"
            for i in "${!items[@]}"; do
                printf "  %d. %s\n" "$((i+1))" "${items[$i]}"
            done
            echo "----------------------------------------------------"
        } >&2

        local choice
        echo -n "$prompt_msg (Enter number or press Enter to exit): " >&2
        read choice >&2

        if [[ -n "$choice" && "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#items[@]}" ] && [ "$choice" -gt 0 ]; then
            echo "${items[$((choice-1))]}"
        else
            echo ""
        fi
    fi
}

# Function to display the versions view
display_versions_view() {
    local base_model="$1"

    # Get prefix groups
    local prefix_groups=()
    while read -r group; do
        [[ -n "$group" ]] && prefix_groups+=("$group")
    done < <(get_version_prefixes)

    # Generate all possible versions
    local versions=($(generate_versions "$base_model" "${prefix_groups[@]}"))
    local display_versions=()

    for v in "${versions[@]}"; do
        local modelfile_path="${OLLAMA_MODELS_DIR}/${base_model}/Modelfile.${v}"
        if [ -f "$modelfile_path" ]; then
            display_versions+=("${v} [v]")
        else
            display_versions+=("$v")
        fi
    done

    # Use the generic selection function
    select_from_list "Select Model Version" "${display_versions[@]}"
}

# Main execution flow
main() {
    # Ensure ollama is available
    if ! command -v ollama &> /dev/null; then
        echo "Error: 'ollama' command not found. Please ensure Ollama is installed and in your PATH."
        exit 1
    fi

    # Retrieve models
    local base_models=($(get_base_models))

    if [ ${#base_models[@]} -eq 0 ]; then
        echo "No base models detected."
        exit 0
    fi

    while true; do
        # Step 1: Select Base Model
        local selected_base=$(select_from_list "Select Base Model" "${base_models[@]}")

        if [ -z "$selected_base" ]; then
            echo "No base model selected. Exiting..."
            break
        fi

        echo ""
        echo "Base model selected: $selected_base"
        echo "Entering version selection..."
        echo ""

        # Step 2: Select Version
        local selected_version=""
        selected_version=$(display_versions_view "$selected_base")

        if [ -z "$selected_version" ]; then
            echo "Returning to base model selection..."
            continue
        fi

        # Strip the [v] marker if present
        selected_version="${selected_version% [v]}"

        # Validate that we have a valid version
        if [ -n "$selected_version" ]; then
            local modelfile_path="${OLLAMA_MODELS_DIR}/${selected_base}/Modelfile.${selected_version}"

            # Call the template assembly script
            echo "Generating Modelfile for $selected_version..."
            "${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"

            echo "----------------------------------------------------"
            echo "FINAL SELECTION: $selected_version"
            echo "----------------------------------------------------"
            # After successful creation, return to main menu
            continue
        else
            # If selected_version was empty, it means we broke out of the version selection (ESC pressed)
            continue
        fi
    done
}

main