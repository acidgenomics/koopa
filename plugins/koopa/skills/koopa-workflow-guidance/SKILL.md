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
challenge assumptions. Don't call ExitPlanMode until explicitly given the green
light. Enter plan mode for architectural decisions or non-obvious tradeoffs.

## Operating Principles

- **Subagents**: use liberally to keep the main context clean. One task per agent.
- **Self-improvement**: after any correction, update the project's lessons rule:
  `.agents/rules/<prefix>-lessons.md` if the repo prefixes its rules, else
  `.agents/rules/lessons.md` (project-level only; `~/.agents/rules/dotfiles-lessons.md`
  is user-curated).
- **Verification**: never mark done without proof. Run tests, check logs.
- **Bug fixing**: given a bug report, just fix it.
- **Elegance**: for non-trivial changes, ask "is there a more elegant way?"
- **Session hygiene**: after two failed corrections, STOP and reset with a sharper prompt.

## Plan Files & Task Management

Save to `.claude/plans/`. Use system-assigned filenames as-is.
Plan → verify → track → explain → capture lessons.

## Git Commit Conventions

Subject ≤72 chars; body explains why. Never "update", "fix bug", "WIP", "changes".
No `Co-Authored-By:` trailers, commits are authored solely by the user.
