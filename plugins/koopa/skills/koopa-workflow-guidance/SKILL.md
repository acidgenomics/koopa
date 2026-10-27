---
name: koopa-workflow-guidance
description: >-
  Workflow orchestration guidance, plan mode etiquette, subagent discipline,
  session hygiene, and git commit conventions. Use when asked about plan mode,
  how to structure multi-step work, when to use subagents, when making a
  git commit, or when cleaning up old Claude or Copilot plan files
  (`koopa app claude|copilot archive-plans`).
---

# Workflow Orchestration

## Plan Mode

A conversation, not a race. Start by understanding the problem, ask questions,
challenge assumptions. Don't leave plan mode or request plan approval until
explicitly given the green light. Enter plan mode for architectural decisions or
non-obvious tradeoffs.

## Operating Principles

- **Subagents**: use liberally to keep the main context clean. One task per agent.
  A review agent finds candidates, not facts. Check each claim against ground
  truth (a file listing, a manifest, a measurement) before you edit or tell the
  user. In one long config review an agent called a file a duplicate that
  symlinks pointed to (deleting it broke the tree), called an intentional
  variant a typo, named setting names from memory that the installed
  extension's `package.json` contradicted, and called configs for installable
  tools dead. Tell the agent to verify each claim itself and to mark what it could
  not verify.
- **Self-improvement**: after any correction, update the project's lessons rule:
  `.agents/rules/<prefix>-lessons.md` if the repo prefixes its rules, else
  `.agents/rules/lessons.md` (project-level only; `~/.agents/rules/dotfiles-lessons.md`
  is user-curated).
- **Verification**: never mark done without proof. Run tests, check logs. The same
  applies to a sentence you are about to say: "those keys are real" or "that file
  is unused" needs a check first. When a check turns out wrong, say so, fix it, and
  record the lesson in the skill that owns it.
- **Bug fixing**: given a bug report, just fix it.
- **Elegance**: for non-trivial changes, ask "is there a more elegant way?"
- **Session hygiene**: after two failed corrections, STOP and reset with a sharper prompt.

## Plan Files & Task Management

Save to `.claude/plans/`. Use system-assigned filenames as-is.
Plan → verify → track → explain → capture lessons.

### Archiving old plans

Plan files pile up in the project. Clean them up with the koopa command for the
tool that wrote them. Run it from inside the project:

```sh
koopa app claude archive-plans --dry-run     # .claude/plans
koopa app copilot archive-plans --dry-run    # .copilot/plans
```

- Always run with `--dry-run` first and show the user the result. The real run
  moves files, so run it only after the user agrees.
- Plans older than `--days N` (default 14) move to
  `plans/archive/YYYY/MM/DD/`. The date comes from a `YYYY-MM-DD-` filename
  prefix, else from the file's modified time.
- A name collision in the archive overwrites the older file. Check the dry-run
  listing for repeated names.
- The Copilot command covers only the repo-local mirror in `.copilot/plans/`. It
  never touches the private `~/.copilot/session-state/*/plan.md` copies.

## Git Commit Conventions

Subject ≤72 chars; body explains why. Never "update", "fix bug", "WIP", "changes".
No `Co-Authored-By:` trailers, commits are authored solely by the user.
