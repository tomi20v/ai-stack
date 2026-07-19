# Ollama Template Generator Specification

## Overview

Implement `template.sh`, a Bash script that generates an Ollama `Modelfile` by concatenating template partials stored under `_templates`.

The script resides inside `ollama-models/` and must resolve all paths relative to its own location, regardless of the current working directory.

---

# Inputs

The script accepts exactly two arguments:

```text
template.sh <base_model> <variant_name>
```

Example:

```bash
template.sh xmodel xmodel-64k-claude
```

Validate:

* exactly two arguments are provided;
* `variant_name` starts with `<base_model>-`.

On failure, print an error to `stderr` and exit with a non-zero status.

---

# Output

Generate:

```text
<base_model>/Modelfile.<variant_name>
```

relative to the script directory.

Create the `<base_model>` directory if necessary.

Overwrite any existing output file.

---

# Template Layout

Example:

```text
_templates/
��� 01 from
��� 05 context/
�   ��� -64k
�   ��� -128k
�   ��� -256k
��� 10 tool/
    ��� -claude
    ��� -copilot
```

This structure is dynamic. Files, directories and option files may be added or removed at any time. The script must not hardcode any category or option names.

Only direct child files are supported. Nested directories are not.

---

# Variant Parsing

The variant format is:

```text
<base_model>-<option>-<option>-...
```

Example:

```text
xmodel-64k-claude
```

produces the option tokens:

```text
64k
claude
```

obtained by removing `<base_model>-` and splitting the remainder on `-`.

---

# Assembly Rules

Process every direct child of `_templates` in ascending filename order (`01`, `02`, `09`, `10`, ...).

For each entry:

* **Regular file:** append its contents.
* **Directory:** select exactly one direct child file whose filename, after removing its leading `-`, exactly matches one option token.

Example:

```text
Variant:
    xmodel-64k-claude

Matches:
    05 context/-64k
    10 tool/-claude
```

If a directory has zero or multiple matches, terminate with an error.

Concatenate every selected part exactly as stored.

Do **not** insert separators, blank lines or newlines.

While appending, replace every occurrence of:

```text
#MODEL_NAME#
```

with the supplied `base_model`.

---

# Errors

Terminate with a non-zero exit code on any error, including:

* invalid arguments;
* invalid variant;
* missing `_templates`;
* missing or ambiguous option match;
* filesystem errors.

Write all error messages to `stderr`.

---

# Summary

1. Validate arguments.
2. Resolve paths relative to the script.
3. Parse option tokens.
4. Create the output directory.
5. Traverse `_templates` in filename order.
6. Append every top-level file.
7. Select one matching file from every top-level directory and append it.
8. Replace `#MODEL_NAME#` while appending.
9. Write `Modelfile.<variant_name>`.
10. Exit on any error.
