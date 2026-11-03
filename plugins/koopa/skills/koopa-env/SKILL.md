---
name: koopa-env
description: >-
  Why a tool resolves inside the koopa prefix instead of Homebrew or the
  system, how to check that, and how koopa activation behaves in
  non-interactive and agentic sessions. Use when a command resolves to an
  unexpected binary, when PATH order looks wrong, or when working inside an
  SSH/CI/agent harness session that needs koopa's tools on PATH, when asking
  which shell an agent runs, what KOOPA_BUCKET is, when BSD `sed -i` fails
  on macOS and `gsed` is the fix, or when `timeout` is a missing command on
  macOS and `gtimeout` is the fix.
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

### A bare tool name over `ssh host 'cmd'` runs the system binary

Without activation, `PATH` has no koopa directory. A bare `tmux`, `bash`, or
`chezmoi` resolves to the system copy (for example `/usr/bin/tmux` 3.2a on
Ubuntu LTS), not the koopa copy that the interactive shell uses. This fails
silently in two ways:

- A **read** reports the wrong version or config, so you describe a binary
  that the user never runs. Confirmed 2026-11-02: `tmux -V` over ssh said 3.2a
  while the live server ran koopa tmux 3.8.
- A **write** uses the wrong binary or renders the wrong path. A chezmoi
  template that calls `lookPath "bash"` rendered `default-shell` as
  `/usr/bin/bash` instead of the koopa bash. Confirmed 2026-11-02.

Fix: call the tool by its full path (`~/.local/share/koopa/bin/<tool>`). For a
tool that looks up other tools, such as `chezmoi` with `lookPath`, also put koopa
first on `PATH` for that one command:

```sh
ssh host 'export PATH=$HOME/.local/share/koopa/bin:$PATH; chezmoi --source=<tree>/chezmoi diff <target>'
```

Run `chezmoi diff <target>` before `apply`. A changed binary path in the diff
(`default-shell`, a `lookPath` result) means the `PATH` is wrong. To see the
binary that a live process uses, run `ps -eo pid,args | grep '[t]mux'`.

## On macOS, `sed` is BSD sed: use `gsed` for in-place edits

macOS ships BSD `sed`. `sed -i 's/a/b/' file` fails there with `undefined label`,
because BSD `sed -i` needs a backup-suffix argument (`sed -i '' ...`). koopa
provides GNU sed as `gsed`, and `gsed -i` works the same on macOS and Linux.
Prefer the Edit tool for a small known change. For a scripted bulk edit, use
`gsed -i`. Check it first with `command -v gsed`.

The koopa plugin's `guard_hook_writes.py` treats `gsed -i` like `sed -i`, so
both still ask before they touch protected hook or settings files.

## On macOS, `timeout` does not exist: use `gtimeout`

macOS has no `timeout`. A call to it prints `timeout: command not found`. Do not
try `timeout` on macOS. koopa provides GNU `timeout` as `gtimeout` (from the
`coreutils` app), and it takes the same arguments:

```sh
gtimeout 30 <command>
```

Exit code 124 means the command ran out of time. Check that `gtimeout` exists
with `command -v gtimeout`. If it is missing, use
`perl -e 'alarm 30; exec @ARGV' <command>`.

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
