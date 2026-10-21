---
name: koopa-workflow-guidance
description: >-
  Workflow orchestration guidance, plan mode etiquette, subagent discipline,
  session hygiene, and git commit conventions. Use when asked about plan mode,
  how to structure multi-step work, when to use subagents, or when making a
  git commit.
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

## Git Commit Conventions

Subject ≤72 chars; body explains why. Never "update", "fix bug", "WIP", "changes".
No `Co-Authored-By:` trailers, commits are authored solely by the user.
