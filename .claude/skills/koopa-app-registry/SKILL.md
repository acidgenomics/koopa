---
name: koopa-app-registry
description: >
  koopa command syntax, app.json registry semantics, and tool-inclusion scope.
  Use when composing koopa commands, reasoning about successor/default/completions
  semantics, importing atuin history, or deciding whether a tool belongs in koopa.
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

## Tool-Inclusion Scope

koopa includes AI agentic coding tools from **major vendors only**: Anthropic, Google,
OpenAI, Microsoft (GitHub), and Amazon. OSS community tools (aider, goose, OpenHands,
etc.) are out of scope regardless of popularity — the scope is intentionally narrow to
vendor-backed products.
