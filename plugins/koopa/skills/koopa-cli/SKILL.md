---
name: koopa-cli
description: >-
  Command syntax for koopa, a shell bootloader that installs apps into its own
  prefix instead of the system package manager. Use when changing koopa's CLI
  architecture, installing a CLI tool, updating apps, switching koopa branches,
  recovering from a stale checkout, or listing what koopa manages.
---

# koopa CLI

## CLI architecture and recovery

Keep the core CLI on standard-library `argparse`, not a required framework such
as Typer. `bin/koopa` can fall back to bootstrap or system Python when the
virtual environment is unavailable; CLI startup and update/recovery must not
depend on third-party packages. Update may also run under the outgoing Python
version and restart with bootstrap Python before recreating the virtual
environment. Preserve existing command behavior and all six generated shell
completions when changing the CLI; see `koopa-completion`.

## Install an app

`koopa install <app>`: not `koopa app install <app>`. The `app` subcommand
does not take an install action.

`koopa reinstall <app>` and `koopa uninstall <app>` follow the same pattern.

## Under a coding agent

`koopa` refuses every command that changes the system when a coding agent runs it:
`install`, `reinstall`, `uninstall`, `update`, `configure`, `admin ...`,
`system prune-apps`, and `develop switch-to-main` or `develop switch-to-develop`
(including its legacy `system` alias). It exits 2 and prints the exact
command. Do not try to get around it: show the user that command and stop, so they
can run it in their own terminal. Read-only commands such as `koopa list` and
`koopa system which` run normally.

## Update

| Command | What it does |
|---|---|
| `koopa update` | Pulls the koopa repo and updates installed apps. Does **not** touch system apps. |
| `koopa update koopa` | Only pulls and updates the koopa repo itself. |
| `koopa update system` | Runs every system update (Homebrew, system R/Python, TeX). Requires admin; raises if not. |
| `koopa update system <app>...` | Runs only the named system app(s), e.g. `koopa update system r tex-packages`. |

App names are valid only with `system`: `koopa update koopa r` is an error.
System updates are opt-in, never part of the default `koopa update` sweep.

## Switching branches and recovering a stale checkout

On a Git-managed installation, `koopa develop switch-to-main` and
`koopa develop switch-to-develop` fetch the corresponding branch from `origin`
and fast-forward it, including when already on that branch. The legacy
`koopa system switch-to-develop` is an alias. These commands require a clean
tracked worktree and a reachable origin; they preserve local commits and
refuse a divergent fast-forward. If the fast-forward fails after a switch,
they attempt to restore the previous checkout. An archive installation cannot
use these commands.

Older versions only switched branches: a stale local `main` could break koopa.
If that happened, have the user check that the Git-managed installation is on
`main`, then run this in their own terminal using an available Git executable:

```sh
git -C /opt/koopa status --short --branch
git -C /opt/koopa pull --ff-only origin main
```

Replace `/opt/koopa` with the actual koopa prefix if different. Do not run the
pull if the branch is not `main`; resolve local changes or divergence rather
than resetting or discarding them. The updated commands must reach the machine
before it can use their new behavior.

## List and inspect

- `koopa list`: installed apps.
- `koopa list --all`: every app koopa knows about, installed or not.
- `koopa app <name> <subcommand>`: app-specific helpers (for example `koopa
  app git ...`, `koopa app aws ...`). Run `koopa app --help` for the current
  list; it changes as apps are added.
- `koopa app claude archive-plans` and `koopa app copilot archive-plans`: move
  old plan files into `archive/YYYY/MM/DD/`. See the `koopa-workflow-guidance`
  skill.

## Configure

- `koopa configure user <app> [<app>...]`: configure for the current user.
- `koopa configure system <app> [<app>...]`: requires admin; system-wide.

## Before reaching for another package manager

If a tool might already be one koopa manages, check first:

```sh
koopa system which <tool>
koopa list --all | grep -i <tool>
```

See the `koopa-env` skill for why this matters and how PATH resolution works.
