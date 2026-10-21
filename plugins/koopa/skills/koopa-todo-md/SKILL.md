---
name: koopa-todo-md
description: >-
  Markdown todo.md conventions for project task tracking. Use when the user
  asks to add, update, complete, or review project TODOs or plans, pastes a
  `- [ ]` checkbox item, or when deciding where to track tasks. Covers file
  location, checkbox syntax, structure, notes, and when to mark work done.
---

# todo.md Conventions

Track plans and tasks in one `todo.md` at the **project repo root**. Do not use
`.claude/todo.md`, a plan file, or any other location for project tasks.

## Task states

Use GitHub-flavored task list syntax:

- `- [ ]`: open task
- `- [x]`: done and verified

Mark a task `- [x]` only when the work is **verified complete** (tests pass,
output checked). A plausible-looking diff is not enough.

## File layout

````markdown
# TODO

## Category

- [ ] Short imperative task title

  Optional note, indented two spaces under the task.
  https://link-to-issue-or-reference

  ```text
  Pasted output, error text, or a command goes in a fenced block.
  ```

- [x] Completed task title
````

- One `#` title, then one `##` heading per category.
- One task per top-level list item. Keep the title to one line.
- Indent notes, links, and code blocks two spaces so they stay inside the item.
- Use a nested `- [ ]` list for subtasks. Do not nest more than one level.
- Put a blank line between tasks that have notes. Tasks without notes may be
  adjacent.

## Workflow

1. **Add**: append the task under the fitting category. Create the category if
   none fits.
2. **Find**: when the user pastes a `- [ ]` item, locate it in `todo.md` by title
   text and read the whole item, notes included. Treat it as the task spec.
3. **Complete**: change `[ ]` to `[x]` after verification. Leave the item in
   place so the history stays readable.
4. **Review**: list open items with `grep -n '^\s*- \[ \]' todo.md`.

## Rules

- Edit only the items the user asked about. Do not reorder, reword, or prune
  other items.
- Never delete a task without approval. Mark it done, or ask.
- Do not copy secrets, tokens, or personal data into notes.
- Keep `todo.md` committed with the code it tracks. The user runs the commit.
- Add the file to `.gitattributes` as `export-ignore` when a release tarball
  must not carry it (koopa does this).

## Note for koopa / Acid Genomics projects

`AGENTS.md` in the koopa repo states: plans and TODOs go in `todo.md` at the
repo root, not `.claude/todo.md`. This skill applies the same convention to any
project that follows that pattern.
