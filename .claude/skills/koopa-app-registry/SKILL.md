---
name: koopa-app-registry
description: >
  koopa command syntax, app.json registry semantics, tool-inclusion scope, and
  installer/version-check machinery. Use when composing koopa commands, reasoning
  about successor/default/completions semantics, importing atuin history, deciding
  whether a tool belongs in koopa, writing a new installer, or wiring auto-update
  for apps with non-version metadata (build IDs, per-platform hashes).
---

# koopa App Registry & Command Conventions

## Command Syntax

### Install command

`koopa install <app>` — NOT `koopa app install <app>`. The `app` subcommand does not
exist for installation.

### Atuin history import

Always use the explicit shell name — `atuin import bash` or `atuin import zsh`.
Never `atuin import auto` on macOS: `$SHELL` is `/bin/zsh` (system default) regardless
of what shell is actually running, so `auto` silently imports the wrong history.

## app.json Semantics

### `successor` field

If an entry has `"successor"` defined, it must also have `"default": false`. It makes
no sense to install an app by default when a known better alternative exists.

### Completion regeneration

Shell autocomplete definitions are **generated**, not hand-maintained:

- **New app entry** (brand new name in the registry): run `koopa develop generate-completions`.
- **Renaming / adding / removing a CLI command** in `cli_*.py`: run `koopa develop generate-completion`.
- Toggling `default: true/false` or bumping `version`/`date` on an existing entry does **not** require regeneration — the app name is already in the completion lists.

### Zsh version format

Zsh releases are `5.x.y` (e.g., `5.9.1`). Never a bare integer — `26` is a GNU project
release number, not a tarball version, and produces a 404 URL. Always verify the resolved
`src_url` tarball exists at `https://www.zsh.org/pub/` before bumping any zsh version.

## Installer Mechanics

### What the framework passes to installer `main()`

`install.py` calls every Python installer with exactly four keyword arguments:

```python
installer_fn(name=..., version=..., prefix=..., passthrough_args=...)
```

No arbitrary app.json fields are threaded through. If an installer needs extra
fields (e.g. `build_id`, per-platform hashes), it must read them itself from
`import_app_json()` — the same function used throughout `install.py`.

### Pattern for extra app.json fields in installers

```python
from koopa.io import import_app_json

entry = import_app_json().get(name, {})
build_id: str = entry.get("build_id", "")
sha512_map: dict[str, str] = entry.get("sha512", {})
```

Store those fields as top-level keys in the app.json entry. Always guard on
missing values and raise `RuntimeError` early.

### `extra_fields_fn` in `_AppCheckSpec` (version_check.py)

When an auto-updated app carries non-version metadata that must stay in sync
(e.g. `antigravity-cli` with `build_id` + per-platform `sha512`), wire an
`extra_fields_fn: Callable[[], dict[str, Any]]` onto its `_AppCheckSpec` in
`_SPECIAL_CASES`. `update_app_json()` calls it after writing `version`/`date`
and merges the result into the app.json entry atomically.

This ensures `koopa develop check-app-versions` never writes a stale `build_id`
when bumping the version.

## Tool-Inclusion Scope

koopa includes AI agentic coding tools from **major vendors only**: Anthropic, Google,
OpenAI, Microsoft (GitHub), and Amazon. OSS community tools (aider, goose, OpenHands,
etc.) are out of scope regardless of popularity — the scope is intentionally narrow to
vendor-backed products.
