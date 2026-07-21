# Ollama Template Generator � Work Plan

## 1. Generate a Basic Modelfile

**Goal:** The script accepts valid arguments and creates the expected output file.

1.1 [*] Create `template.sh` with a Bash shebang.
1.2 [*] Make the script executable.
1.3 [*] Resolve the script directory independently of the current working directory.
1.4 [*] Require exactly two arguments: `base_model` and `variant_name`.
1.5 [*] Validate that `variant_name` starts with `base_model-`.
1.6 [*] Create the `<base_model>/` output directory when missing.
1.7 [*] Create or overwrite `<base_model>/Modelfile.<variant_name>`.
1.8 [*] Verify the script works when invoked from outside `ollama-models/`.

## 2. Assemble Top-Level Template Files

**Goal:** The generated Modelfile contains all unconditional template parts.

2.1 [*] Locate `_templates/` relative to the script.
2.2 [*] Exit with an error when `_templates/` does not exist.
2.3 [*] Read direct children of `_templates/` in ascending filename order.
2.4 [*] Detect top-level regular files.
2.5 [*] Append each top-level regular file exactly as stored.
2.6 [*] Add no separators, blank lines, or newlines between parts.
2.7 [*] Verify multiple top-level files are concatenated in the expected order.

## 3. Select Variant Options

**Goal:** Each template directory contributes the partial matching the requested variant.

3.1 [*] Remove the `base_model-` prefix from `variant_name`.
3.2 [*] Split the remaining string into exact option tokens using `-`.
3.3 [*] Detect top-level directories under `_templates/`.
3.4 [*] Inspect only direct child files of each template directory.
3.5 [*] Remove the leading `-` from each candidate filename for matching.
3.6 [*] Match candidate filenames exactly against the variant option tokens.
3.7 [*] Select exactly one matching file from each template directory.
3.8 [*] Append the selected file at the position of its parent directory in the top-level order.
3.9 [*] Exit with an error when a template directory has no match.
3.10 [*] Exit with an error when a template directory has multiple matches.
3.11 [*] Verify variants such as `xmodel-64k-claude` and `xmodel-128k-copilot`.

## 4. Apply Model-Name Substitution

**Goal:** Generated files contain the selected base model instead of the placeholder.

4.1 [*] Replace every occurrence of `#MODEL_NAME#` with `base_model`.
4.2 [*] Apply substitution to unconditional top-level files.
4.3 [*] Apply substitution to selected option files.
4.4 [*] Preserve all other content exactly.
4.5 [*] Verify multiple placeholders in one partial are all replaced.

## 5. Complete Error Handling

**Goal:** Every failure stops generation and returns a useful error.

5.1 [*] Enable strict Bash error handling.
5.2 [*] Write error messages to `stderr`.
5.3 [*] Return a non-zero exit code on any error.
5.4 [*] Reject nested directories inside template option directories.
5.5 [*] Handle unreadable template files as errors.
5.6 [*] Handle output directory or file creation failures as errors.
5.7 [*] Ensure failed generation does not report success.

## 6. Verify the Complete Generator

**Goal:** Confirm the script satisfies the specification with representative cases.

6.1 [*] Test generation with every currently supported context/tool combination.
6.2 [*] Verify an existing output file is overwritten correctly.
6.3 [*] Verify running the same command twice produces identical output.
6.4 [*] Verify top-level ordering with names such as `01`, `02`, `09`, and `10`.
6.5 [*] Verify template content is concatenated byte-for-byte except for `#MODEL_NAME#` substitution.
6.6 [*] Test invalid argument count.
6.7 [*] Test a variant with the wrong base-model prefix.
6.8 [*] Test a missing option match.
6.9 [*] Test multiple matches within one option directory.
6.10 [*] Test a missing `_templates/` directory.
6.11 [*] Confirm newly added template categories and options require no script changes.
