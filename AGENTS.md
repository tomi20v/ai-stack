# AI Rules

## Development Process

Always follow this SDD workflow.

### 1. Specification

Before writing code:

* Create a natural-language specification named `<target>.spec.md`.
* Wait for user confirmation before continuing.

### 2. Plan

After the specification is approved:

* Create `<target>.plan.md`.
* Split the work into numbered vertical slices:

  * `1`, `2`, `3`, ...
* Split every slice into small, independently implementable tasks:

  * `1.1`, `1.2`, `2.1`, ...
* Format every task as:

```text
1.2 [ ] Task description
```

* Wait for user confirmation before continuing.

### 3. Implementation

Implement **exactly one vertical slice** at a time.

Within the current slice:

1. Work through the tasks in order (`1.1`, `1.2`, `1.3`, ...).
2. Before each task, briefly plan the implementation (do not save this plan).
3. Implement only the current task.
4. Mark the completed task in the plan:

```text
1.2 [*] Task description
```

After all tasks in the current slice are implemented:

5. Test the entire slice.
6. If it can be tested easily from the shell, perform the tests.
7. Otherwise, explain exactly what the user should test.
8. Wait for user confirmation that the slice is accepted.
9. **Stop. Do not begin the next slice.**

## SDD Files

All specifications and plans are stored under:

```text
00-specs/
 active/
 archived/
```

The directory structure under `active/` and `archived/` mirrors the project structure, so they will have subfolders for files which are in subfoldrs.

Example:

```text
some/fol/der.sh
```

has:

```text
00-specs/active/some/fol/der.sh.spec.md
00-specs/active/some/fol/der.sh.plan.md
```

### Specification lifecycle

While a feature is being implemented, both the specification and plan remain under `00-specs/active/`.

When the implementation is completed and accepted:

* If no archived specification exists, move the specification to:

```text
00-specs/archived/some/fol/der.sh.spec.md
```

* If an archived specification already exists, merge the completed specification into it in a meaningful way so that the archived specification represents the latest implemented behaviour. Remove duplicated or obsolete information where appropriate.

### Plan lifecycle

When implementation is completed and accepted:

* Archive the completed plan under:

```text
00-specs/archived/some/fol/
```

using the filename:

```text
der.sh.plan-YYMMDD-01.md
```

where:

* `YYMMDD` is the archive date;
* `01` is the first archived plan for that date;
* additional plans archived on the same day use consecutive numbers (`02`, `03`, ...).

Never overwrite an archived plan.

## Rules

* Never skip the Specification or Plan phases.
* Never work on more than one vertical slice in a single session.
* Always complete tasks sequentially within the current slice.
* Never begin the next slice automatically.
* Always stop after a slice has been implemented and tested.
* Keep tasks small enough to implement and review independently.
* Do not mark a task complete until it has been implemented successfully.
* If anything is ambiguous, ask instead of guessing.
* Do not refactor or modify unrelated code.
* Always maintain the mirrored directory structure under `00-specs/active/` and `00-specs/archived/`.
* Never overwrite archived plans.
* Keep the archived specification synchronized with the implemented behaviour after every completed change.

