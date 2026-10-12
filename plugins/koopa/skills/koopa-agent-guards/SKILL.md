---
name: koopa-agent-guards
description: >-
  What the koopa plugin's agent guard hooks block or ask about, why, and the
  correct alternative for each. Use when a koopa hook blocked or asked about a
  command or a file write, when a deny message names a script such as
  block_uv.py or guard_rm.py, or when the user asks what the koopa plugin
  guards do and how to configure them.
---

# koopa agent guards

## What the guards are

The plugin registers Python hooks that run before a tool call
(`PreToolUse`). A block exits 2 and the harness reports the hook command, whose
path ends in the script name, together with the reason text that states the rule
(the reason itself does not always repeat the script name). They are strict on
purpose, with no per-hook switch and no override.

Three kinds of outcome: **block** (the call does not run), **ask** (the user
gets a permission prompt; the hook never denies), and **context** (a warning
or note, nothing is stopped).

## The hooks

| Script | Event and matcher | Decision | Matches | Do this instead |
| --- | --- | --- | --- | --- |
| `block_tmux_kill_server.py` | PreToolUse, Bash | block | `tmux ... kill-server` | `tmux kill-session -t <name>` for your own session |
| `block_destructive_git.py` | PreToolUse, Bash | block | `reset --hard`, `clean -fd`, any force push (`-f`, `--force*`, `+refspec`), `git rm -rf`, `checkout -- .`, `branch -D`, `git push origin main` or `master` | Use a non-destructive form, or stop and ask the user to run it. A push after `cd` or `git -C` into a different repo passes |
| `audit_secrets_before_push.py` | PreToolUse, Bash | block | a real `git push` whose outgoing range (`@{u}..HEAD`, else `origin/<branch>..HEAD`) holds a file named like `.env`, `.pem`, `.p12`, `credentials.json`, `secrets.*`, `*_key.*` | Remove the file from the commits, then push. History surgery needs the user |
| `guard_installs.py` | PreToolUse, Bash | block | `pip`, `npm`, `pnpm`, `yarn`, `cargo`, `gem`, `go install`, `brew`, `apt`, `dnf`, `yum`, `pacman -S`, `port`, `pipx`, `poetry add`, `cpan`, `uv add`, R `install.packages`, `koopa install`, `curl ... \| sh` | Name the command or the koopa app and let the user install it |
| `block_uv.py` | PreToolUse, Bash | block | `uv` or `uvx` in any form, also inside `bash -c`, `ssh host '...'`, substitutions | Use the project's own environment and scripts |
| `guard_broad_scan.py` | PreToolUse, Bash | block | `find`, `grep -r`, `rg`, `fd` rooted at `~`, `$HOME`, `/`, `/Users`, `/home`, or a bare `/Users/<name>` | Scope the scan to the project or a known subpath |
| `guard_rm.py` | PreToolUse, Bash | block, or allow | block: recursive-force `rm`, `find -delete`, `find -exec rm` unless every target is strictly inside `$TMPDIR`. allow: plain `rm` or `rmdir` inside `$TMPDIR` | Name exact files, or clean up under `$TMPDIR`, or ask the user |
| `guard_tmp.py` | PreToolUse, Bash and file-write tools | block | writing under `/tmp`, `/var/tmp`, `/dev/shm` (redirect, `tee`, `touch`, `mkdir`, `cp`/`mv` destination, `curl -o`, Write/Edit) | `mktemp -d`, then use that path |
| `guard_hook_writes.py` | PreToolUse, Bash | ask | a command that writes `.agents/hooks`, `.claude/hooks`, or `.claude/settings*.json` (`sed -i`, redirect, `tee`, `mv`, `rm`, `cp` onto it, interpreter code) | Edit the managed source and apply it, or let the user approve |
| `guard_report_path.py` | PreToolUse, Write/Edit/MultiEdit | block | a write to `reports/YYYY/MM/DD/`, `reports/YYYY-MM-DD/`, or directly under the project's top-level `reports/`, when a notes vault is detected | Write to the vault path named in the message |
| `guard_keywords.py` | PreToolUse, Edit/Write/MultiEdit/NotebookEdit | block | a configured keyword in the file path or new content, in a publishable repo | Move the content to a private repo, or the user allowlists the remote |
| `guard_env_files.py` | PreToolUse, Edit/Write/Read/Bash | block | `.env` or `.env.local` read or edited, by file tool or by any command naming it | Ask the user for the specific value. `source .env` is allowed |
| `guard_sensitive_paths.py` | PreToolUse, Bash | ask | a command referencing `~/Documents` or `~/Downloads` (`~`, `$HOME`, `${HOME}`, `/Users/<name>`) | Answer the prompt, or the user lists safe folders in `koopa.allowedPaths` |
| `guard_settings_keywords.py` | SessionStart and Stop, Claude Code only | context at start, block at Stop | a configured keyword in `$CLAUDE_PROJECT_DIR/.claude/settings.json` in a publishable repo | Move that permission entry to `.claude/settings.local.json` (gitignored) |
| `guard_workspace_root.py` | SessionStart, Claude Code only | context | session root not inside any git repo, so project `.mcp.json` and `.claude/settings.json` do not load | Reopen the editor on the intended repo. `CLAUDE_ALLOW_NONREPO_ROOT=1` silences it |

## Rule for an agent

Never work around a block by rewording, splitting, quoting, or hiding the
command (a script that does the same thing, `bash -c`, a variable, a glob).
Take the documented alternative from the table. If there is none, stop, tell
the user which guard blocked it and why, and say they can run the command
themselves (in Claude Code, by typing `!` before it). For an ask, state what
you need and let the user answer the prompt.

## Configuration (git config)

`guard_keywords.py`, `guard_settings_keywords.py` and the git `pre-commit` hook
read the same keys. The keyword guard is **inert until configured**: the plugin
ships no keywords. Values below are made up.

```sh
git config --global --add koopa.keywords acmecorp
git config --global --add koopa.contentKeywords jdoe42
git config --global --add koopa.allowedRemotes git.acmecorp.example
git config --global --add koopa.allowedPaths Documents/notes
```

- `koopa.keywords`: checked in the file path and the new content.
- `koopa.contentKeywords`: new content only.
- `koopa.allowedRemotes`: case-sensitive substrings of the `origin` URL where the
  keywords are legitimate.
- `koopa.allowedPaths`: for `guard_sensitive_paths.py`; a path under the home
  directory starting with `Documents` or `Downloads`, matched on path segments.
- Deprecated aliases, still read as a union: `koopa.restrictedTokens`,
  `koopa.restrictedTokensContentOnly`, `koopa.corpRemoteAllowlist`.

Never print, echo, or copy configured values into code, commits, or chat. The
block messages do not echo them, and neither should you. Do not run `git config`
to change them; that is the user's call.

## Environment facts

- `CLAUDE_PROJECT_DIR`: the two session hooks do nothing unless it is set and
  non-empty. The secrets and report-path hooks also use it for the repo or
  project root.
- `AGENT_HOOK_HARNESS=copilot`: set by the Copilot registration so the two ask
  hooks print Copilot's bare `permissionDecision` shape instead of the
  `hookSpecificOutput` wrapper.
- `TMPDIR`: `guard_rm.py` only allows or accepts deletes inside it, and
  `guard_tmp.py` is inactive when it is unset or itself under `/tmp`. Create
  scratch with `mktemp`, and delete only what you created.

## Gotchas

- A guard blocks a command that **runs** the thing, not text that mentions it.
  `echo "uv sync"` or a commit message naming `reset --hard` passes. Only
  `guard_broad_scan.py` is text-based, one line at a time.
- Unparsable input fails open, with exceptions: `block_uv.py` fails closed on a
  broad pattern, `guard_rm.py` still denies obvious `rm -rf` text, and
  `guard_env_files.py` blocks on an internal error. Empty or malformed stdin
  exits 0 everywhere else.
- `rm` inside `$TMPDIR` is auto-approved only when the path has no variable
  other than `$TMPDIR`, no glob, no `~`, no `..`. A `cd` or `TMPDIR=` earlier in
  the command makes the hook distrust the targets.
- `guard_tmp.py` does not block `rm`, reads, or running a script that lives in
  `/tmp`. `guard_env_files.py` allows `source .env`, `. .env` and
  `load_dotenv(...)`, but `source .env && cat .env` is blocked.
- `.envrc`, `.env.example`, `.venv` and a `.env/` directory are not matched by
  the env guard.
- `guard_report_path.py` does nothing with no vault detected, and never blocks a
  delete or the source side of a move.
- `guard_hook_writes.py` and `guard_sensitive_paths.py` ask, never deny. They are
  speed bumps: a script that writes a protected file itself is not seen.
- Keyword matching is case-insensitive with a letter-or-digit boundary
  (`acmecorp` does not match `acmecorporation`), and a write is blocked only in
  an absolute path inside a git work tree whose `origin` is not allowlisted and
  whose path is not gitignored.
