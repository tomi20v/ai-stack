# claude-launcher: Accept model name from command line

## Important Notes

- This script launches a new Claude instance and will not exit
- Output cannot be observed from within Claude Code
- User will test manually by running the script in their terminal
- I will prompt for testing when ready

## 1. Add command line argument parsing

1.1 [*] Add `--model` flag to accept model name
1.2 [*] Add positional argument support for model name
1.3 [*] Parse command line arguments and store model name
1.4 [*] Skip interactive selection if model name is provided

## 2. Add Ollama model validation

2.1 [*] Create function to check if model exists in Ollama
2.2 [*] Validate model name against available models
2.3 [*] Display error if model not found

## 3. Test and verify

3.1 [*] Test with positional argument
3.2 [*] Test with --model flag
3.3 [*] Test interactive selection still works
3.4 [*] Test error handling for invalid model