---
name: koopa-troubleshoot
description: >-
  Diagnostic commands for a koopa installation: system checks, environment
  info, install logs, and stale app-version cleanup. Use when a koopa-managed
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

`koopa system prune-apps` removes old, unlinked versions of installed CLI
apps, keeping only the currently active version on disk. This deletes files.
Confirm with the user before running it, and prefer describing what it would
do rather than running it unprompted — there is no dry-run flag exposed on
the CLI surface, so treat every invocation as live.

## When a check fails

Read the specific check name in the failure output, then look at
`koopa.check` in the koopa source for what it validates (prefix ownership,
required directories, PATH sanity). Report the failing check name and the
exact error text back to the user rather than guessing a fix.
