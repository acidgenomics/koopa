---
name: koopa-todo-org
description: >-
  Org-mode todo.org conventions for project task tracking. Use when the user
  pastes a `** TODO` heading, asks about project TODOs or plans, or when
  deciding where to track tasks or mark work complete.
---

# todo.org Conventions

## When a `** TODO` heading is pasted

1. Locate `todo.org` at the **project repo root** (not `.claude/todo.md` or
   anywhere else, the repo root only).
2. Find the matching entry by title text.
3. Read the full entry (including any notes/links under it) and treat it as the
   task spec.

## Org TODO keywords

- `** TODO`: open task
- `** DONE`: completed and verified

Mark an entry `** DONE` only when the work is **verified complete**, not on a
plausible-looking diff alone.

## File layout

```
* Category heading
** TODO Short task title
   Optional note line(s), indented with spaces.
   https://link-to-issue-or-reference
** DONE Completed task title
```

Heading depth is two stars (`**`) for tasks under a category. The file lives at
the repo root and is committed alongside code.

## Note for koopa / Acid Genomics projects

`CLAUDE.md` in the koopa repo explicitly states: plans/TODOs → `todo.org` at the
repo root, NOT `.claude/todo.md`. This skill generalizes that convention to any
project that follows the same pattern.
