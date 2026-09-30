1 Basic script structure

1.1 [ * ] Create model-selection.sh with shebang and set -euo pipefail
1.2 [ * ] Copy get_ollama_models() function from existing launchers
1.3 [ * ] Copy select_model() function with fzf support from existing launchers
1.4 [ * ] Add function to parse command line arguments (any string)
1.5 [ * ] Add function to display usage/help message

2 Model filtering logic

2.1 [ * ] Add function to filter models by keyword (copilot/claude/gemini)
2.2 [ * ] Implement case-insensitive matching
2.3 [ * ] Add function to sort and unique results

3 Output and error handling

3.1 [ * ] Add function to display matching models
3.2 [ * ] Add error handling for no models found (copy from launchers)
3.3 [ * ] Add error handling for invalid parameters
3.4 [ * ] Add validation to ensure ollama is running
3.5 [ * ] Copy fzf availability check from existing launchers

4 Integration

4.1 [ * ] Add main function to orchestrate the workflow
4.2 [ * ] Test with -copilot, -claude, -gemini parameters
4.3 [ * ] Verify output format matches expected behavior