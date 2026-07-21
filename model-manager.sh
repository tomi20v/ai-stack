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

# Function to find orphaned models (models in ollama but without local configuration)
find_orphaned_models() {
    local orphaned_models=()

    # Get all models from ollama
    local ollama_models
    ollama_models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    if [ -z "$ollama_models" ]; then
        return
    fi

    # For each model in ollama, check if there's a local configuration
    while IFS= read -r model; do
        if [ -n "$model" ]; then
            # Check if this model has a corresponding local Modelfile
            local base_model=$(echo "$model" | sed 's/-.*$//')
            local modelfile_path="${OLLAMA_MODELS_DIR}/${base_model}/Modelfile.${model}"

            # If no local configuration exists, it's orphaned
            if [ ! -f "$modelfile_path" ]; then
                orphaned_models+=("$model")
            fi
        fi
    done <<< "$ollama_models"

    echo "${orphaned_models[@]}"
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

# Function to delete all variants of a base model
delete_all_variants() {
    local base_model="$1"

    echo "Deleting all variants for base model: $base_model"

    # Get confirmation
    echo -n "Are you sure you want to delete ALL variants for $base_model? (y/N): "
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Deletion cancelled."
        return
    fi

    # Find and remove all local Modelfile.* files for this base model
    local modelfile_dir="${OLLAMA_MODELS_DIR}/${base_model}"
    if [ -d "$modelfile_dir" ]; then
        echo "Removing local Modelfile configurations..."
        rm -f "${modelfile_dir}/Modelfile."*
    fi

    # Get all models that start with this base model name from ollama
    local ollama_models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep "^${base_model}-"))

    if [ ${#ollama_models[@]} -gt 0 ]; then
        echo "Removing models from Ollama..."
        for model in "${ollama_models[@]}"; do
            echo "Removing: $model"
            ollama rm "$model" 2>/dev/null || true
        done
    fi

    # Also remove the base model itself if it exists
    local base_model_full="${base_model}"
    local base_model_exists=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep "^${base_model_full}$")
    if [ -n "$base_model_exists" ]; then
        echo "Removing base model: $base_model_full"
        ollama rm "$base_model_full" 2>/dev/null || true
    fi

    echo "All variants for $base_model have been deleted."
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

    # Add deletion option to the list for existing versions
    local final_display=()
    for item in "${display_versions[@]}"; do
        if [[ "$item" == *" [v]" ]]; then
            # This is an existing version, add delete option
            final_display+=("${item} (d)elete")
        else
            # This is a new version, no delete option
            final_display+=("$item")
        fi
    done

    # Use the generic selection function
    local selected=$(select_from_list "Select Model Version" "${final_display[@]}")

    # Check if deletion was requested
    if [[ "$selected" == *" (d)elete"* ]]; then
        # Extract version name without the delete hint
        local version_name="${selected% (d)elete}"
        version_name="${version_name% [v]}"

        # Remove the Modelfile
        local modelfile_path="${OLLAMA_MODELS_DIR}/${base_model}/Modelfile.${version_name}"
        if [ -f "$modelfile_path" ]; then
            rm -f "$modelfile_path"
            echo "Deleted local Modelfile: $modelfile_path"
        fi

        # Remove from ollama
        echo "Removing model from Ollama: $version_name"
        ollama rm "$version_name" 2>/dev/null || true

        echo "Deleted variant $version_name for base model $base_model."

        # Return empty to indicate deletion was handled
        echo ""
    else
        echo "$selected"
    fi
}

# Main execution flow
main() {
    # Ensure ollama is available
    if ! command -v ollama &> /dev/null; then
        echo "Error: 'ollama' command not found. Please ensure Ollama is installed and in your PATH."
        exit 1
    fi

    # Check for orphaned models first
    local orphaned_models=($(find_orphaned_models))
    if [ ${#orphaned_models[@]} -gt 0 ]; then
        echo "----------------------------------------------------"
        echo "WARNING: Found orphaned models (models in Ollama but without local configuration):"
        echo "${orphaned_models[*]}"
        echo "----------------------------------------------------"
        echo -n "Do you want to remove these orphaned models? (y/N): "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            for model in "${orphaned_models[@]}"; do
                echo "Removing orphaned model: $model"
                ollama rm "$model" 2>/dev/null || true
            done
            echo "Orphaned models removed successfully."
        else
            echo "Skipping orphaned model cleanup."
        fi
        echo ""
    fi

    # Retrieve models
    local base_models=($(get_base_models))

    if [ ${#base_models[@]} -eq 0 ]; then
        echo "No base models detected."
        exit 0
    fi

    # Add delete option to each base model for the main menu
    local final_base_models=()
    for base in "${base_models[@]}"; do
        final_base_models+=("$base")
        final_base_models+=("${base} (delete all)")
    done

    while true; do
        # Step 1: Select Base Model
        local selected_base=$(select_from_list "Select Base Model" "${base_models[@]}")

        if [ -z "$selected_base" ]; then
            echo "No base model selected. Exiting..."
            break
        fi

        # Check if this is a deletion request (special case)
        if [[ "$selected_base" == *" (delete all)" ]]; then
            local base_model_name="${selected_base% (delete all)}"
            delete_all_variants "$base_model_name"
            continue
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
            echo "Modelfile $selected_version created successfully for base model $selected_base."
            # After successful creation, return to main menu
            continue
        else
            # If selected_version was empty, it means we broke out of the version selection (ESC pressed)
            continue
        fi
    done
}

main