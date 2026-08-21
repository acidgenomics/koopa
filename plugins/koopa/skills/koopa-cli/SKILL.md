---
name: koopa-cli
description: >-
  Command syntax for koopa: a shell bootloader that installs apps into its own
  prefix instead of the system package manager. Use when a task calls for
  installing a CLI tool, updating apps, or listing what koopa manages, so you
  reach for `koopa install`/`koopa update`/`koopa list` instead of `brew`,
  `apt`, or `pip install --user`.
---

# koopa CLI

## Install an app

`koopa install <app>` — not `koopa app install <app>`. The `app` subcommand
does not take an install action.

`koopa reinstall <app>` and `koopa uninstall <app>` follow the same pattern.

## Update

| Command | What it does |
|---|---|
| `koopa update` | Pulls the koopa repo and updates installed apps. Does **not** touch system apps. |
| `koopa update koopa` | Only pulls and updates the koopa repo itself. |
| `koopa update system` | Runs every system update (Homebrew, system R/Python, TeX). Requires admin; raises if not. |
| `koopa update system <app>...` | Runs only the named system app(s), e.g. `koopa update system r tex-packages`. |

App names are valid only with `system`: `koopa update koopa r` is an error.
System updates are opt-in, never part of the default `koopa update` sweep.

## List and inspect

- `koopa list` — installed apps.
- `koopa list --all` — every app koopa knows about, installed or not.
- `koopa app <name> <subcommand>` — app-specific helpers (for example `koopa
  app git ...`, `koopa app aws ...`). Run `koopa app --help` for the current
  list; it changes as apps are added.

## Configure

- `koopa configure user <app> [<app>...]` — configure for the current user.
- `koopa configure system <app> [<app>...]` — requires admin; system-wide.

## Before reaching for another package manager

If a tool might already be one koopa manages, check first:

```sh
koopa system which <tool>
koopa list --all | grep -i <tool>
```

See the `koopa-env` skill for why this matters and how PATH resolution works.
