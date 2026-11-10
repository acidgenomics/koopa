---
name: koopa-troubleshoot
description: >-
  Diagnostic commands for a koopa installation (system checks, environment
  info, install logs, and stale app-version cleanup). Use when a koopa-managed
  tool misbehaves, an install failed, or you need a full report of koopa's
  version, prefix, and platform before debugging further.
---

# koopa Troubleshooting

## First checks

```sh
koopa system check    # runs validation checks; prints a pass/fail summary
koopa system info     # version, prefix, git commit, OS, shell versions
```

Run both before digging further. Most "tool not found" or "wrong version"
reports trace back to a failed check or a stale PATH, and `system info` shows
the koopa prefix and commit you are actually running.

## Install logs

`koopa develop log` opens the most recent `.koopa-install.log`-style temp log
from a failed or in-progress install. Use it when `koopa install <app>` exits
non-zero with no clear error on screen.

## Stale app versions

`koopa system prune-apps` removes old, unlinked versions of installed apps of
every type, keeping the currently linked version. koopa links compiled apps to
exact `app/<name>/<version>/lib` paths, so an old library can still be in use:
before deleting, ripgrep scans the app's reverse dependencies for the old path,
and a referenced version is kept and reported (for example, `Keeping zlib
1.3.2: still used by 'libxslt/...'`; reinstall that app to release it). Links in
`bin/` and `share/` into a deleted version move to the linked version, or are
removed when it has no such file. Without ripgrep, only `cli` apps are pruned.

This deletes files. Run `koopa system prune-apps --dry-run` first: it prints
what it would prune, keep, relink, and remove, changes nothing, and runs under a
coding agent. Confirm with the user before the real run, which the `koopa` CLI
refuses under an agent anyway.

## When a check fails

Read the specific check name in the failure output, then look at
`koopa.check` in the koopa source for what it validates (prefix ownership,
required directories, PATH sanity). Report the failing check name and the
exact error text back to the user rather than guessing a fix.
