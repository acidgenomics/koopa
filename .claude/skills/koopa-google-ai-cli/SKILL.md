---
name: koopa-google-ai-cli
description: >
  Google AI CLI installer management for koopa — Antigravity CLI (agy) and Gemini CLI
  transition, versioned GCS download mechanics, self-update gate, manifest structure,
  and settings.json config path. Use when bumping the antigravity-cli version, debugging
  the installer, or managing the gemini-cli successor relationship.
---

# koopa Google AI CLI

## Product Transition

Gemini CLI → **Antigravity CLI** (`agy`), Go binary, as of 2026-06.

- Gemini CLI (`@google/gemini-cli`, npm) stopped serving consumer/free/individual accounts.
- Enterprise (Standard/Enterprise/Cloud contracts) continues to use Gemini CLI.
- The replacement is a native Go binary distributed as a prebuilt tarball from GCS.
- `gemini-cli` is kept in `app.json` with `"successor": "antigravity-cli"`, `"default": false`.
- `antigravity-cli` is `"default": false` because no documented self-update disable switch
  exists. Once Google adds one, flip to `true`.

## Distribution Mechanics

The upstream installer (`https://antigravity.google/cli/install.sh`) is manifest-driven:

1. Fetch `https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/<platform>.json`
2. Platform strings: `darwin_arm64`, `darwin_amd64`, `linux_amd64`, `linux_arm64`
   (`linux_*_musl` endpoints 404 — not published).
3. Manifest JSON: `{ "version": "1.0.10", "url": "https://storage.googleapis.com/...", "sha512": "..." }`

**The manifest `url` is a fully versioned, content-addressed GCS path** — not a floating
"latest" pointer. This enables install-time pinning by downloading from GCS directly.

## GCS URL Structure

```
https://storage.googleapis.com/antigravity-public/antigravity-cli/<version>-<build_id>/<dir>/<file>
```

The `build_id` is opaque and **not derivable from the version string** — it must be fetched
from the manifest and stored explicitly. The same `build_id` is shared across all platforms
for a given version.

## Asset Table

The `build_id`, per-platform `sha512` hashes, and `version` all live in the
`"antigravity-cli"` entry in `etc/koopa/app.json` — not in the installer.
The installer reads them at runtime via `import_app_json()`.

## Installer Module: `installers/antigravity_cli.py`

Pattern: `surrealdb.py` template + SHA512 verification layer.

Key design decisions:
- Downloads from the **versioned GCS URL directly** — never calls the Cloud Run manifest
  at install time. This is the pinning mechanism.
- Extracts the tarball, renames the extracted `antigravity` binary to `agy`.
- Verifies SHA512 with stdlib `hashlib` before touching the prefix.
- **Does not** run `agy install` — koopa's own bin-symlinking puts `agy` on PATH.
- On macOS: clears `com.apple.quarantine` via `xattr -d` (tolerates absence).

## Version Bump Procedure

`koopa develop check-app-versions` handles everything automatically:

- `_check_antigravity_cli()` fetches the `darwin_arm64` manifest for the version string.
- When `update_app_json()` writes a new version, `_fetch_antigravity_cli_extra_fields()`
  fetches all four platform manifests and updates `build_id` and `sha512` in `app.json`
  in the same pass.

To bump manually:

1. Fetch all four platform manifests:
   ```sh
   base="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"
   for p in darwin_arm64 darwin_amd64 linux_amd64 linux_arm64; do
     echo "=== $p ===" && curl -fsSL "$base/$p.json"
   done
   ```
2. Update `"version"`, `"date"`, `"build_id"`, and all four `"sha512"` values in
   the `"antigravity-cli"` entry in `etc/koopa/app.json`. No Python changes needed.
3. Run `koopa develop format-app-json` (no completions regen needed — name unchanged).

## Self-Update Gate

`agy` self-updates in the background during regular runs. As of v1.0.10, there is
**no documented user-configurable disable switch** in `settings.json` or via env var.

- `~/.gemini/antigravity-cli/settings.json` has 19 exported keys — none control updates.
- `AutoUpdate`/`AutoUpdateTime` exist as internal Go struct fields only.
- `AGY_BUSINESS_PAYGO_TIER` is the only `AGY_*` env var in the binary.

**Resolution:** keep `"default": false` until Google exposes a disable mechanism. When
re-evaluating, inspect `agy --help`, `agy update --help`, and the embedded settings docs:
```sh
strings $(which agy) | grep -A 200 'Configuration Settings.*settings\.json'
```

## Config and GEMINI.md Path

- **Config file:** `~/.gemini/antigravity-cli/settings.json`
- **Global instruction file:** `~/.gemini/GEMINI.md` (same path as Gemini CLI used)
  - Template source: `opt/dotfiles/chezmoi/dot_gemini/GEMINI.md.tmpl`
  - Loaded by both `agy` and the Antigravity IDE desktop app.
  - Un-ignored in `.chezmoiignore` via `!.gemini/GEMINI.md`.

The `~/.gemini/` root is shared between Antigravity CLI config and GEMINI.md.
The CLI's own settings live one level deeper at `~/.gemini/antigravity-cli/`.
