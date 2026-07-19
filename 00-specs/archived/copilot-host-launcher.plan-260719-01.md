# Plan: Dynamic Token Limits for Copilot Host Launcher

## Slice 1: Implement Fixed Token Limit Baseline
1.1 [*] Add fixed `COPILOT_PROVIDER_MAX_PROMPT_TOKENS=32000` and `COPILOP_PROVIDER_MAX_OUTPUT_Tokens=4096` directly to the `env` command in `copilot-host-launcher`.
1.2 [*] Add an `echo` statement in `*copilot-host-launcher*` to print these values when running, to verify they are correctly passed to the environment.

## Slice 2: Implement Dynamic Token Limits Based on Model Name
2.1 [*] Implement a parsing function in `copilot-host-launcher` to extract context suffixes (64k, 100k, 128k, 256k) from the `SELECTED_MODEL`.
2.2 [*] Implement the mapping logic for the specified token limits (as defined in the spec).
2.3 [*] Update the `env` command in `copilot-host-launcher` to use these dynamically calculated variables.
2.4 [*] Update the debug `s echo statement to print the newly calculated tokens for verification against different model selections.
