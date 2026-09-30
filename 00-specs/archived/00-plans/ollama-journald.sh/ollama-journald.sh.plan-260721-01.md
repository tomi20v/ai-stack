# ollama-journald.sh.plan.md

## Slice 1: Happy path - Running the command for existing members

1.1 [*] Create `ollama-journald.sh` with shebang and the `journalctl` command.
1.2 [*] Verify the script runs the command successfully when the user is already in the `adm` group.

## Slice 2: Feature completion - Group membership check and interaction

2.1 [*] Implement the logic to check if the current user belongs to the `adm` group.
2.2 [*] Implement the interactive prompt and `usermod` execution for users not in the group.
2.3 [ ] Verify the script handles both "already in group" and "prompted/added to group" scenarios.

## Slice 3: Cleanup

3.1 [*] Archive specification and plan.
