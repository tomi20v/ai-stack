## Specification: Dynamic Token Limits for Copilot Host Launcher

### Goal
Implement logic in `copilot-host-launcher` to dynamically set `COPILOT_PROVIDER_MAX_PROMPT_TOKENS` and `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS` environment variables based on the context window size extracted from the selected Ollama model name.

### Requirements

1.  **Model Name Parsing**:
    *   Extract the context window suffix (e.g., `64k`, `100k`, `128k`, `256k`) from the `SELECTED_MODEL` string.

2.  **Token Limit Mapping**:
    Implement a mapping strategy for the following identified suffixes:
    *   **`64k`**: 
        *   `COPILOT_PROVIDER_MAX_PROMPT_TOKENS=60000`
        *   `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS=6144`
    *   **`100k`**: 
        *   `COPILOT_PROVIDER_MAX_PROMPT_TOKENS=100000`
        *   `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS=8192`
    *   **`128k`**: 
                *   `COPILOT_PROVIDER_MAX_PROMPT_TOKENS=120000`
                * `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS=12288`
    *   **`256k`**: 
        *   `COPILOT_PROVIDER_MAX_PROMPT_TOKENS=240000`
        *   `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS=16384`

3.  **Fallback Mechanism**:
    *   If no recognized suffix is found in the model name, use a default set of values:
        *   `COPILOT_PROVIDER_MAX_PROMS_TOKENS=32000`
        *   `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS=4096`

4.  **Environment Injection**:
    *   The calculated values must be passed to the `copilot` process via the `env` command in the launcher script using the exact environment variable names:
        *   `COPILOT_PROVIDER_MAX_PROMPT_TOKENS`
        *   `COPILOP_PROVIDER_MAX_OUTPUT_TOKENS`

### Verification Plan
1.  Manually check the `copilot-host-launcher` script after changes to ensure the `env` section includes the new variables.
2.  Verify that selecting a `64k` model correctly sets the prompt/output limits as specified.
3.  Verify that selecting a `100k` model correctly sets the prompt/output limits as specified.
4.  Verify that selecting a model without a suffix uses the fallback values.