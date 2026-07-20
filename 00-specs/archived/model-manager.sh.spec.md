# Model Manager Specification

## Overview
The `model-manager.sh` script is a bash utility designed to help users select and manage Ollama models by providing an interactive interface for choosing base models and their variants (versions). It generates Modelfiles based on templates.

## Current Functionality
1. **Base Model Selection**: Lists available Ollama models (excluding those with -copilot, -claude, or -<digits>k patterns)
2. **Version Selection**: Allows users to select from generated version combinations for a chosen base model
3. **Template Processing**: Calls `template.sh` to generate Modelfiles based on selected variants

## Issues Identified
1. **Incorrect Script Execution**: The script incorrectly calls `template.sh` as a Python script instead of a bash script, causing a syntax error and resulting in empty files being created.
2. **Error Message**: "SyntaxError: invalid syntax" at line 6 in template.sh where `set -euo pipefail` is used.
3. **Execution Flow Problem**: The script appears to be calling `python3 "${SCRIPT_DIR}/ollama-models/template.sh"` instead of directly executing the bash script

## Root Cause Analysis
The problem is in line 194 of `model-manager.sh`:
```bash
python3 "${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

But `template.sh` is a bash script with bash-specific syntax (`set -euo pipefail`) that cannot be executed as Python.

## Expected Behavior
- User selects base model from available list
- User selects version/variant from generated combinations  
- Script should call `template.sh` with proper arguments (`<base_model> <variant_name>`)
- `template.sh` should generate a properly formatted Modelfile in the correct location

## Technical Requirements
### File Structure
```
ollama-models/
├── template.sh              # Template processor (bash script)
├── _templates/              # Template directory with partials
│   ├── 01 from
│   ├── 05 context
│   ├── 10 tool
│   └── 99 end
└── <base_model>/
    └── Modelfile.<variant_name>
```

### Current Problem in model-manager.sh (line 194)
```bash
python3 "${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

This line is calling `template.sh` as a Python script instead of executing it as a bash script, which causes the syntax error.

### Expected Fix
Change line 194 to:
```bash
"${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

## Test Cases
1. Run model-manager.sh and select a base model
2. Select a version/variant 
3. Verify Modelfile is created with proper content in the expected location
4. Confirm no syntax errors occur during execution

## Implementation Scope
This specification covers only the bug fix for incorrect script execution - no new features or functionality changes.