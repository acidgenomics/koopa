---
name: koopa-env
description: >-
  Why a tool resolves inside the koopa prefix instead of Homebrew or the
  system, how to check that, and how koopa activation behaves in
  non-interactive and agentic sessions. Use when a command resolves to an
  unexpected binary, when PATH order looks wrong, or when working inside an
  SSH/CI/agent harness session that needs koopa's tools on PATH, when asking
  which shell an agent runs, or what KOOPA_BUCKET is.
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
host 'cmd'`, CI steps, agentic harnesses) do **not**: PATH and environment
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

## Which shell an agent harness runs

Claude Code's Bash tool picks its shell from the `CLAUDE_CODE_SHELL`
environment variable: a path to a bash or zsh binary. An invalid value silently
falls back to auto-detection, which uses `$SHELL` when it is bash or zsh. Set it
in the `env` block of the user-level `settings.json` (for example
`"CLAUDE_CODE_SHELL": "/path/to/zsh"`). Documented for Claude Code, but not
re-verified here against your installed version.

Check from inside a session rather than assume:

```sh
echo "bash=${BASH_VERSION:-none} zsh=${ZSH_VERSION:-none} shell=$SHELL"
```

Exactly one of the two version variables is set in the shell actually running.
`$SHELL` is the login shell, not necessarily the running one.

How Copilot CLI and Codex choose their shell is undocumented and unverified
here. Run the same check there. Remember that the agent shell is
non-interactive, so koopa activates only with `KOOPA_AUTO_ACTIVATE=1`.

## KOOPA_BUCKET

`KOOPA_BUCKET` is the directory of koopa's dated notes bucket (typically an
Obsidian vault). `_koopa_activate_today_bucket` resolves it from an existing
`KOOPA_BUCKET` that is a directory, else `~/bucket`, else `~/Documents/bucket`,
resolves symlinks, and exports it, then repoints the `~/today` and
`~/Documents/today` links at `<bucket>/YYYY/MM/DD`. It runs in koopa-activated
interactive shells only, so a non-interactive agent shell has it only if it
inherited the variable from the parent process. If no bucket directory exists it
is not set.

The plugin's `guard_report_path.py` hook reads it first when finding a notes
vault: `KOOPA_BUCKET`, then `OBSIDIAN_VAULT_DIR`, then Obsidian's own registry
(`obsidian.json`). With none of those found, the hook does nothing. To see the
value in use: `[ -n "${KOOPA_BUCKET:-}" ] && echo set || echo unset`.

`KOOPA_BUCKET` is always the symlink-resolved path, so it can differ as a string
from the path a tool reports. `~/Documents` is often a symlink (for example into
OneDrive), so `~/Documents/bucket` (what `obsidian vaults` lists) and
`KOOPA_BUCKET` can be the same directory. Never conclude they are different
vaults from a string comparison: run `realpath` on both first.
