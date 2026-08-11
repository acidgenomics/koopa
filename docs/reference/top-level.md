# Top-level commands

(koopa-install)=
## `install [app...]`

Install applications. No args installs defaults; --all installs all.

(koopa-reinstall)=
## `reinstall app...`

Reinstall applications, with optional reverse dependency rebuilds.

(koopa-uninstall)=
## `uninstall [app...]`

Remove installed applications. Defaults to uninstalling koopa itself.

(koopa-update)=
## `update [app...]`

Update applications to latest versions. Defaults to updating koopa.

(koopa-list)=
## `list [--all]`

List available apps. No args lists defaults; --all lists all.

(koopa-configure)=
## `configure app...`

Run post-install configuration for applications.

(koopa-app)=
## `app subcommand`

Application-specific utilities (e.g. koopa app salmon quant).

(koopa-run)=
## `run command`

Run a utility command (e.g. koopa run rename-snake-case).

(koopa-system)=
## `system subcommand`

System information and koopa management.

(koopa-admin)=
## `admin subcommand`

System administration commands (require sudo).

(koopa-develop)=
## `develop subcommand`

Developer and maintenance utilities.

## Install options

| Flag | Description |
| --- | --- |
| `--all` | Install all registered applications. |
| `--no-dependencies` | Skip dependency installation. |
| `--reinstall` | Force reinstall even if already installed. |
| `-D arg` | Pass additional arguments through to the installer. Can be repeated. |

## Reinstall options

| Flag | Description |
| --- | --- |
| `--all-revdeps` | Reinstall the specified apps and all of their reverse dependencies. |
| `--only-revdeps` | Reinstall only the reverse dependencies, not the specified apps. |

