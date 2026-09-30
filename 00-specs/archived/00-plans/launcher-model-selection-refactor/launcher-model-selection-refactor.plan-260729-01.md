# Launcher Model Selection Refactor Plan

## 1. Refactor claude-launcher

1.1 [*] Remove `get_ollama_models()` function (lines 31-42)
1.2 [*] Remove `select_model()` function (lines 44-69)
1.3 [*] Add `source model-selection.sh "claude"` before model selection logic
1.4 [*] Update model selection section to use sourced script output

## 2. Refactor gemini-launcher

2.1 [*] Remove `get_ollama_models()` function (lines 6-18)
2.2 [*] Remove `select_model()` function (lines 20-45)
2.3 [*] Add `source model-selection.sh "-gemini"` before model selection logic
2.4 [*] Update model selection section to use sourced script output

## 3. Refactor copilot-launcher

3.1 [*] Remove `get_ollama_models()` function (lines 6-17)
3.2 [*] Remove `select_model()` function (lines 19-39)
3.3 [*] Add `source model-selection.sh "copilot"` before model selection logic
3.4 [*] Update model selection section to use sourced script output

## 4. Verification

4.1 [*] Test each launcher with `--dry-run` flag to verify model selection works
4.2 [*] Verify all launchers output the correct model name
4.3 [*] Confirm no duplicated model selection logic remains