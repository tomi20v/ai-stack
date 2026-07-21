# ollama-journald.sh.spec.md

## Overview
A shell script to facilitate following the `ollama` service logs using `journalctl` without requiring manual sudo for every command, by ensuring the user is part of the `adm` group.

## Requirements

### 1. Group Membership Check
- The script must check if the current user belongs to the `adm` group.
- If the user is `root`, the check should pass automatically.

### 2. User Interaction
- If the current user is **not** in the `adm` group:
    - Prompt the user with a question: "User is not in 'adm' group. Would you like to add them? (y/N)".
    - If the user responds with `y` or `Y`:
        - Execute `sudo usermod -aG adm $USER`.
        - Inform the user that the change requires a re-login to take effect, but proceed to attempt the command anyway.
    - If the user responds with anything else (e.g., `n`, `N`, or just Enter):
        - Proceed without attempting to add the user to the group.

### 3. Command Execution
- After the group check and potential modification, the script must execute:
  `journalctl -u ollama --no-hostname -f`
- This command should run regardless of whether the user was just added to the group or was already a member.

## Constraints
- The script must be executable as a standard shell script (e.g., `#!/bin/bash`).
- Use `sudo` only for the `usermod` command.
