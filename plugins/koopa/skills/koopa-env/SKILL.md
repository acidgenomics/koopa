---
name: koopa-env
description: >-
  Why a tool resolves inside the koopa prefix instead of Homebrew or the
  system, how to check that, and how koopa activation behaves in
  non-interactive and agentic sessions. Use when a command resolves to an
  unexpected binary, when PATH order looks wrong, or when working inside an
  SSH/CI/agent harness session that needs koopa's tools on PATH.
---

# koopa Environment

## Where a tool actually comes from

```sh
koopa system which <tool>     # real path of the koopa-managed binary
koopa system version <tool>   # version koopa installed
koopa system prefix           # koopa's own root, e.g. ~/.local/share/koopa
koopa system list path-priority
```

`koopa system prefix` returns the root every app lives under, for example
`<prefix>/app/<tool>/<version>/bin/<tool>`. `koopa system list path-priority`
shows the PATH order, which is the fastest way to diagnose "wrong version
resolved."

## Non-interactive sessions do not activate by default

Interactive shells activate koopa automatically. Non-interactive shells (`ssh
host 'cmd'`, CI steps, agentic harnesses) do **not** — PATH and environment
exports are opt-in there.

Set `KOOPA_AUTO_ACTIVATE=1` to opt in. This exports PATH and environment only;
it does not load prompt, alias, or history machinery. If a command that should
resolve to a koopa-managed tool instead reports "command not found" in an
agent session, check whether this variable is set.

## A project's own virtual environment still wins

koopa never shadows a project-local `.venv` or a `uv`-managed environment.
Those take priority on PATH when active. koopa only fills gaps: tools the
project itself does not provide.

## Do not confuse "koopa manages this" with "koopa activated this session"

`koopa list --all` tells you what koopa can install. `koopa system which
<tool>` tells you what is actually first on PATH right now. A tool can be
installed by koopa and still lose to a Homebrew copy earlier in PATH; checking
`list` alone will not reveal that.
