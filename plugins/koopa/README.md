# koopa plugin

Skills for using koopa in any project: what to run, why a tool resolves where
it does, and how to diagnose problems. That's the whole plugin — no commands,
agents, or hooks. An earlier draft added those plus a separate `koopa-dev`
plugin; both were cut. The commands/subagent/hook draft is preserved in the
`.claude/plans/help-me-develop-copilot-binary-nest.md` plan file if the idea
comes back later, but this plugin should stay skills-only.

## Contents

- `skills/koopa-cli` — command syntax: install, update, list, configure.
- `skills/koopa-env` — why a tool resolves from koopa vs. Homebrew/the system,
  and `KOOPA_AUTO_ACTIVATE` for non-interactive/agentic sessions.
- `skills/koopa-troubleshoot` — `koopa system check`/`info`, install logs, and
  why `koopa system prune-apps` needs confirmation before running.
