---
name: koopa-workflow-guidance
description: >-
  Coding and workflow guidance, verification, plan mode etiquette, subagent
  discipline, session hygiene, and git commit conventions. Use when planning
  multi-step coding work, deciding whether to delegate, or managing plans and
  commits.
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

## Coding and change discipline

- Make only the requested change. State assumptions, and ask before choosing
  between materially different approaches or changing load-bearing behavior.
- Handle errors at system boundaries such as user input, external APIs, and
  file I/O. Trust internal code; do not add fallbacks for impossible states.
- Verify the behavior the change is meant to provide. Run relevant tests,
  linters, and type checkers when available; do not report completion based
  only on a plausible diff.
- Fix lint and type errors instead of suppressing them. Do not override project
  configuration.
- Use installed tools from `PATH`, not paths into a project's `.venv`, unless
  that project explicitly requires it. Do not install tools or packages without
  the user's approval. Surface the exact command or koopa app name and let the
  user approve it.
- Do not reach for tools outside the current project unless the user asks.
  Leave commits and pushes to the user, and never add AI attribution to commit
  messages.
- Never use hardcoded `/tmp` paths for scratch files; use `mktemp` or the
  language's temporary-file helper. Never put sensitive data in scratch files.
- Avoid em-dash punctuation in prose.

## Shared authoring conventions

- Keep system-generated plan filenames unchanged; the plan UI may depend on the
  exact filename.
- Use two-space indentation for JSON.
- For deep research, pair web research with GitHub code search when available.
- For Obsidian session reports, use the vault's dated
  `YYYY/MM/DD/<slug>.md` location and the `type: report`, `title`, and `date`
  frontmatter. See `koopa-obsidian`.
- For Git history surgery, see `koopa-git-history-surgery`.

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
