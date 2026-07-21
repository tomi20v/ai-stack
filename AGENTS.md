# AGENTS.md

# Rules

- Never skip Specification or Plan.
- Never modify unrelated code.
- Never guess. Ask if something is ambiguous.
- Implement exactly one vertical slice per session.
- Stop after the current slice is accepted.

---

# Repository Scope

Read only files that are directly relevant to the current task.

You may locate and read additional files only when they are needed to understand or modify the current target.

A file is relevant when it is:

- directly referenced by the target file;
- called, sourced, imported, included, or executed by the target file;
- required to understand the failing behaviour;
- required to implement or test the requested change.

Do not explore files merely because they are nearby, similar, share a folder, or may contain examples.

Do not read unrelated templates, implementations, tests, or configuration files unless the current task depends on them.

Before reading an additional file, identify the concrete dependency that makes it relevant.

If relevance is uncertain, ask before reading it.

# Exploration Limit

Follow dependencies outward from the current target only as far as required for the task.

Example:

- If fixing how `a.sh` calls `b.sh`, read `a.sh` and `b.sh`.
- Read files used by that call only if they affect the requested behaviour.
- Do not inspect templates processed elsewhere by `a.sh` when they are unrelated to the call.

# Workflow

## 1. Specification

Create:

```
00-specs/active/<path>.spec.md
```

Rules:

- One specification per source file.
- The specification contains ONLY the requested changes.
- If an archived specification exists, read it before writing the new specification.

Wait for user approval.

---

## 2. Plan

Create:

```
00-specs/active/<path>.plan.md
```

Format:

```
1 Slice name

1.1 [ ] Task
1.2 [ ] Task

2 Next slice

2.1 [ ] Task
```

Rules:

- Split work into vertical slices.
- Split each slice into small sequential tasks.
- One task = one checkbox.

Wait for user approval.

---

## 3. Implementation

Implement ONE vertical slice only.

For each task:

1. Briefly plan the implementation.
2. Implement only that task.
3. Mark the task complete.

Example:

```
1.2 [*] Task description
```

After the whole slice:

- Test it if practical.
- Otherwise explain exactly what the user should test.
- Wait for user acceptance.
- Do NOT begin the next slice.

---

# Specification

Repository:

```
00-specs/
    active/
    archived/
    plans/
```

The directory structure mirrors the project.

Example:

```
scripts/foo.sh
```

Files:

```
00-specs/active/scripts/foo.sh.spec.md
00-specs/active/scripts/foo.sh.plan.md

00-specs/archived/scripts/foo.sh.spec.md

00-specs/archived/plans/scripts/foo.sh.plan-YYMMDD-NN.md
```

---

# Archive Procedure

After the user accepts the implemented slice:

## 1. Update the plan

- Every implemented task must be `[ * ]`.
- No unfinished task may be `[ * ]`.

## 2. Archive the specification

If no archived specification exists:

- Move the active specification to:

```
00-specs/archived/<path>.spec.md
```

Otherwise:

- Merge the active specification into the archived specification.
- Preserve all unchanged requirements.
- Update only the implemented behaviour.
- Remove duplicate or obsolete requirements.

Delete the active specification afterwards.

## 3. Archive the plan

Rename:

```
<file>.plan.md
```

to

```
<file>.plan-YYMMDD-NN.md
```

where:

- YYMMDD = archive date
- NN = 01, 02, 03...

Never overwrite an archived plan.

Move it to:

```
00-specs/plans/<path>/
```

Delete the active plan afterwards.

---

# Before Stopping

Always perform this checklist in order:

- [ ] Update completed task checkboxes.
- [ ] Archive or update the specification.
- [ ] Archive the plan.
- [ ] Verify the archived plan filename uses `YYMMDD-NN`.
- [ ] Verify no archived plan was overwritten.
- [ ] Verify the active specification was removed.
- [ ] Verify the active plan was removed.
- [ ] Stop.
