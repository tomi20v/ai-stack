# Model Manager Plan

## Problem Analysis
The `model-manager.sh` script has a critical issue where it calls `template.sh` as a Python script instead of a bash script, causing a syntax error and resulting in empty files being created.

## Root Cause
In line 194 of `model-manager.sh`, the script uses:
```bash
python3 "${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

But `template.sh` is a bash script, not a Python script. This causes:
1. Syntax error due to bash-specific syntax (`set -euo pipefail`) being interpreted as Python
2. The script never executes properly, leading to empty file creation

## Vertical Slice 1: Fix Script Execution

### 1.1 [ ] Verify template.sh is executable
- Check if `template.sh` has execute permissions
- Add execute permissions if needed using `chmod +x`

### 1.2 [ ] Fix execution call in model-manager.sh
- Change line 194 from `python3 ...` to direct bash script execution
- Remove the Python invocation

### 1.3 [ ] Validate argument passing
- Ensure arguments are passed correctly to template.sh
- Verify that the script receives base_model and variant_name properly

### 1.4 [ ] Test the fix
- Run model-manager.sh and verify it creates proper Modelfiles
- Confirm no syntax errors occur during execution

## Implementation Details

### File: /home/tehhgoon/ai-stack-claude/model-manager.sh
**Change line 194 from:**
```bash
python3 "${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

**To:**
```bash
"${SCRIPT_DIR}/ollama-models/template.sh" "$selected_base" "$selected_version"
```

### File: /home/tehhgoon/ai-stack-claude/ollama-models/template.sh
**Verify shebang line is present:**
```bash
#!/bin/bash
```

**Ensure execute permissions are set:**
```bash
chmod +x /home/tehhgoon/ai-stack-claude/ollama-models/template.sh
```

## Verification Plan

1. Run `chmod +x /home/tehhgoon/ai-stack-claude/ollama-models/template.sh`
2. Execute `model-manager.sh` 
3. Select a base model and version
4. Verify that Modelfile is created with proper content (not empty)
5. Check that no syntax errors occur during execution

## Expected Outcome
After implementing these fixes:
- The script should execute without syntax errors
- Proper Modelfiles should be generated in the correct location
- The interactive selection process should work as intended