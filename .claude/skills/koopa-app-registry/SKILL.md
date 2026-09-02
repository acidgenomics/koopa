---
name: koopa-app-registry
description: >-
  koopa command syntax, app.json registry semantics, tool-inclusion scope, and
  installer/version-check machinery. Use when composing koopa commands, reasoning
  about successor/default/completions semantics, importing atuin history, deciding
  whether a tool belongs in koopa, writing a new installer, wiring auto-update
  for apps with non-version metadata (build IDs, per-platform hashes), debugging
  GNU/Savannah mirror failures (unreachable hosts, wrong mirror paths, the
  dead-host circuit breaker) in version-check or source-download code, or
  reasoning about why an app was (or wasn't) flagged as needing a rebuild —
  dependency-staleness detection compares installed state, not app.json's target,
  or debugging a binary-package push/pull issue (why a push must run from the
  canonical '/opt/koopa' prefix, KOOPA_BUILDER gating, or a tarball uploaded from
  the wrong prefix that a puller can never extract).
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

- **New app entry** (brand new name in the registry): run `koopa develop generate-completion`.
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

### Checking Python-version compatibility for a new `python-package` app

Confirming that every *direct* dependency ships a `cp3XX` wheel for the target
Python version is necessary but not sufficient. A transitive dependency pulled
in through an extras marker can carry its own `requires-python` exclusion that
a direct-dependency sweep never sees.

Case in point: adding `tooluniverse` (pinned to `python3.14` at first) passed a
full check of every direct dependency's PyPI wheel listing, then failed at
`pip install` with `ResolutionImpossible`. Root cause: `tooluniverse`'s own
`pyproject.toml` lists `markitdown[all]` as a *base* dependency (not optional),
and `markitdown[all]==0.1.7` pins `youtube-transcript-api~=1.0.0`, whose 1.0.x
series sets `requires-python = "<3.14,>=3.8"` — an explicit exclusion, not a
missing wheel. No newer `markitdown` release loosens that pin. `no_binary` and
`extra_packages` can't work around a `requires-python` exclusion.

The reliable check is to attempt the actual `pip install` (or `koopa install
<app>`) rather than inferring compatibility from wheel filenames. When it fails
with `ResolutionImpossible`, read which package sets the offending
`requires-python`, then pin the app below that ceiling with the minimal
necessary version drop — see `apache-airflow`, `azure-cli`, `dbt`,
`snowflake-cli`, `tabcmd` for the `dependencies: ["python3.13"]` +
`installer_args.python_version` + `python_version_pin: true` pattern.

## Version Check Machinery

### Architecture

`version_check.py` is the entire version-check implementation. Key landmarks:

- **`_SPECIAL_CASES`** — dict mapping app name → `_AppCheckSpec`. Checked first by
  `classify_app()`; apps not listed fall back to generic GitHub/PyPI/conda inference.
- **`_run_check`** — the per-app worker (nested inside `check_app_versions`). Calls
  `spec.check_fn`, runs the pre-release filter, writes the cache, then compares
  `_version_key(sanitize_version(...))` to decide outdated/current/pinned-too-high.
- **`update_app_json`** — recomputes `r.is_outdated` from `VersionCheckResult` and
  writes `version`/`date` for every outdated app. `is_outdated` is a property that
  re-evaluates on the stored `latest_version`; setting `latest_version = current`
  (not `None`) suppresses an app across report, write, and cache uniformly.
- **Cache** — `~/.cache/koopa/version-check.json`, 24-hour TTL. A cached pre-release
  is treated as a cache miss so a stale beta from a previous run can't leak.

### Safe investigation flags

Always pass `--no-update` when testing a version-check fix — it skips the `app.json`
write so a bad result can't corrupt the registry:

```sh
koopa develop check-app-versions --no-update boost git
```

`--reset-cache` forces fresh network lookups, bypassing the 24h cache:

```sh
koopa develop check-app-versions --reset-cache --no-update boost
```

### Holding a version back permanently (`version_exclude`, `version_granularity`, `version_match`, `version_pin`)

A hold written only as prose in an entry's `notes` array is not enforced —
`version_check.py` never reads `notes`. The next `check-app-versions` run
silently re-bumps the version, undoing the hold. This is exactly what
happened to `node`: a `notes` entry said "held below 26.8.0" (that
conda-forge release stamps its own build as `v26.8.0-alpha.0.0.0`, which
fails npm's engine check), but nothing enforced it, so the next run re-bumped
to 26.8.0 anyway. Use one of these fields instead, checked in
`check_app_versions()` / `update_app_json()`:

| Field | Shape | Effect |
|---|---|---|
| `version_exclude` | array of version strings | Never write these exact versions. Self-heals: once upstream ships a version not on the list, the pin bumps normally with no further edit. |
| `version_granularity` | `"minor"` | Accept a bump only when the major or minor component changes; hold a patch-only bump. |
| `version_match` | another app's name | Bump only when this app and the named app agree on the same latest version; hold both otherwise (e.g. `xorg-xcb-proto` must match `xorg-libxcb`). |
| `version_pin` | `true` | Drop the app from checking entirely (`emacs`, `nettle`). Use only when the app should never be checked again — most holds should use `version_exclude`, so the app keeps getting checked and the hold expires on its own. |

`check-app-versions` audits every `version_exclude` list up front, regardless
of which apps are in scope for that run, and reports two failure shapes so a
dead hold doesn't linger unnoticed: a **stale hold** (every excluded version
is already below the current pin, so it does nothing) and a **contradiction**
(the current pin is itself on its own exclusion list).

### Recovery when a bad version is written to app.json

If `check-app-versions` runs without `--no-update` before a fix is in place (or a
pre-release guard fires only after the fact), the bad version lands in `app.json` as
`current`. At that point the pre-release guard correctly does **not** suppress it
(an app pinned to a pre-release can still receive pre-release updates). Fix:

1. Edit `app.json` directly — revert `version` and `date` to the last known-good values.
2. Add `version_exclude` naming the bad version, so the fix survives the next
   `check-app-versions` run. Editing `version`/`date` alone reverts the symptom but
   not the cause — the next run just re-bumps it, since nothing recorded the version
   as bad.
3. Run `koopa develop format-app-json` to normalize.
4. Re-run `check-app-versions --reset-cache --no-update <app>` to confirm the version
   is now reported as held, not outdated.

### Pre-release suppression

`_is_prerelease(version)` (regex-based, fleet-wide) suppresses any upstream candidate
whose version string contains an explicit pre-release marker (`alpha`, `beta`, `rc`,
`dev`, `pre`, `preview`, `snapshot`, `nightly`, `canary`) — unless the app is itself
already pinned to a pre-release. Single-letter stable suffixes (`1.1.1w`, `1.2.3a`)
are intentionally not matched. The guard lives in `_run_check`, before `cache.put`.

Boost is the canonical example: boostorg publishes betas as GitHub's non-prerelease
"latest" release, so GitHub's own `prerelease` flag doesn't filter them.

### GNU/Savannah host unreliability (version-check + download)

The GNU project's own infrastructure — `ftpmirror.gnu.org`, `ftp.gnu.org`,
`download.savannah.nongnu.org`, `download-mirror.savannah.gnu.org` — is
unreliable from many corporate networks (firewall-blocked outright, or subject
to intermittent SSL handshake timeouts under concurrent load). This affects two
independent code paths that both needed the same fix:

- **`version_check.py`**: `_check_gnu()` / `_check_nongnu()` scrape a directory
  listing for the newest tarball. Both route through the shared
  `_fetch_first_reachable(bases)` helper, which tries `_GNU_DIR_BASES` /
  `_NONGNU_DIR_BASES` in order — verified-reachable third-party mirrors
  (`mirrors.kernel.org/gnu/`, `ftp.wayne.edu/gnu/`, `mirrors.ocf.berkeley.edu/gnu/`,
  `mirror.csclub.uwaterloo.ca/gnu/` and the `/nongnu/` equivalents) come before the
  GNU/Savannah hosts themselves.
- **`download.py`**: `_gnu_mirrors()` / `_savannah_mirrors()` build the fallback
  URL list for the actual source-tarball download (used by `install_gnu_app()`
  and the S3 mirror-upload path). These derive the mirror-relative path from the
  **primary URL's own path** (stripping a leading `gnu/` or `releases/` segment),
  not by composing `f"{name}/{filename}"`. Composing from `name`/`filename` breaks
  any app whose real tarball path isn't flat — `gcc` lives at
  `gcc/gcc-{version}/gcc-{version}.tar.xz` (versioned subdirectory) and `wget2`
  lives under the `wget/` parent directory, so the naive form 404s on every
  mirror. `mirror.rit.edu` was dropped from the list entirely — its TLS cert
  doesn't match its own hostname, so it fails for everyone, not just behind a
  firewall.

**Dead-host circuit breaker** (`version_check.py`, module-level `_dead_hosts`
set + `_dead_hosts_lock`): a host that times out on connect/handshake is
recorded and skipped for the rest of the process — a blocked host would
otherwise burn a full timeout on every one of the 30+ GNU-installer apps in a
single `check-app-versions` run. Only a `TimeoutError` or a `URLError` whose
`.reason` is `TimeoutError`/`ssl.SSLError` trips the breaker; an HTTP error
status (404, etc.) never does, since a 404 for one package says nothing about
the host's reachability for another. Reuse `_fetch_first_reachable()` for any
new multi-host-fallback check rather than re-deriving this logic.

**Verifying a src_url change actually reaches a mirror**: `koopa develop
mirror-src <app>` runs the same `download_with_mirror()` + S3-upload path used
by `check-app-versions` after a version bump, with `strict=True` so a failed
download raises instead of silently printing "Mirror upload skipped". Use it to
confirm a `src_url` or mirror-list fix actually resolves before trusting the
next full `check-app-versions` run.

## Private Staged-Artifact Apps (cellranger, bcl-convert)

Apps gated behind a `private: true` + `installer_artifact` app.json entry (10x
Genomics tools currently: `cellranger`, `bcl-convert`) require the vendor's
EULA-gated tarball to be staged in the private artifacts S3 bucket before
install works — koopa has no rights to redistribute or mirror it automatically.

### Maintainer upgrade path

1. `koopa develop check-app-versions <app>` reports the new upstream version
   but does **not** bump `app.json`. `update_app_json()` (`version_check.py`)
   checks `installer_artifact_key()` (`app.py`) against `s3_object_exists()`
   and holds the pin, printing "artifact not staged" — this gate runs
   regardless of `--no-update`.
2. Download the vendor's Linux tarball from the `url` in `app.json` (accepting
   their terms-of-service page).
3. Stage it: `koopa develop push-installer <app> <file>` uploads to the S3 key
   the `installer_artifact` template names (e.g.
   `installers/cellranger/{version}.tar.xz`).
4. Re-run `koopa develop check-app-versions --reset-cache <app>` — the artifact
   is now staged, so the pin bumps.
5. `koopa install <app>` extracts the tarball and asserts a top-level `bin/`
   directory before linking (`installers/cellranger.py`,
   `installers/bcl_convert.py`) — if the vendor changes their archive layout,
   this raises explicitly instead of leaving a dangling `bin -> libexec/bin`
   symlink.

Covered by `tests/test_installers.py`: the staged-artifact pin-hold, the
missing-`installer_artifact`-field case, and the archive-layout assertion.

## Binary Package Cache (push/pull)

Pre-built binary tarballs (a Homebrew-bottle equivalent) let non-builder hosts
skip compiling from source. Push and pull are two independent code paths in
`install.py`, gated separately — there is no single shared helper that
enforces their common invariant for free.

### The `/opt/koopa` absolute-path invariant

A tarball is archived with `tar -Pcz` (absolute paths preserved) and extracted
with `tar -Pxz`. A tarball built from any prefix other than `/opt/koopa`
embeds that other prefix's path, so it can never be extracted correctly
anywhere else — a pull would try to write into `/Users/someone/...` instead of
`/opt/koopa/...`. `_BINARY_PREFIX = "/opt/koopa"` in `install.py` names this
invariant once; every site below checks it independently:

| Function | File | Enforcement |
|---|---|---|
| `_can_install_binary()` | `install.py` | soft gate, returns `False` off-prefix |
| `install_app_from_binary_package()` | `install.py` | hard `RuntimeError` at pull time |
| `_can_push_binary()` | `install.py` | soft gate, returns `False` off-prefix, one-shot `alert_note` |
| `push_app_build()` | `install.py` | hard `RuntimeError` via `_require_binary_prefix()` |
| `_handle_push_app_build()` (`koopa develop push-app-build`) | `cli_develop.py` | hard `RuntimeError` via the same `_require_binary_prefix()` |

**Gotcha:** `push_app_build()` and `_handle_push_app_build()` are two
independent tar-and-upload implementations of "push one app's build." A guard
added to one does not cover the other — there is no single choke point both
pass through, so both call `_require_binary_prefix()` explicitly. When adding
a new push code path, check for this invariant explicitly; don't assume
`_can_push_binary() is True` means the tarball being built is safe.

### KOOPA_BUILDER gating

`can_build_binary()` = `KOOPA_BUILDER=1`, read via `koopa.aws.dotenv_value()` —
checks `os.environ` first, then `<koopa-root>/.env`. `_can_push_binary()`
requires: `can_build_binary()` AND the `/opt/koopa` prefix AND (a configured
vendor push backend OR (`_has_private_access()` AND the `aws` CLI on PATH)).

Two homes for the flag, two different survival stories against koopa's own
direnv-revert step (`cli_main._revert_direnv_env`, see
`koopa.system.revert_direnv_env`):

- Set in a shell profile *before* direnv runs: it lands in direnv's
  pre-`.envrc` baseline, which gets restored on every
  `koopa install`/`reinstall`/`update`, not stripped.
- Set in `<koopa-root>/.env`: koopa's own `.envrc` loads `.env` through
  direnv's `dotenv_if_exists`, so the flag is absent from the pre-`.envrc`
  baseline and `revert_direnv_env()` deletes it from `os.environ` on every
  run. `dotenv_value()`'s `.env` fallback is what makes this home work anyway
  — without it, `can_build_binary()` reads `os.environ` only and a builder
  configured this way is silently demoted to a consumer.

Failure shape of the demotion (fixed, but worth recognizing if it recurs from
a future refactor): the builder attempts a binary pull instead of skipping to
a source build, gets a 404 (nothing was ever pushed for a builder), and
`_can_install_binary()`/`_can_push_binary()` end up `True` at once — a
combination `_can_install_binary()` exists specifically to prevent, since a
builder is supposed to always build from source and never install a binary
substitute. That inconsistency, not just the 404, is the tell.

### S3 key layout

`s3://<artifacts-bucket>/binaries/<os_slug>/<arch>/<name>/<version>.tar.gz`,
or `<version>-r<revision>.tar.gz` when the app.json entry's `revision > 0`
(`_binary_tarball_basename()`). A `.koopa-binary` marker file inside an
installed app's prefix means it was pulled as a binary, not built locally —
`push_missing_app_builds()`'s sweep skips any app carrying that marker.

### Silent-success trap

`push_app_build()` runs `aws s3 cp --only-show-errors` with `capture=True` and
used to have no success message at all — a push that ran and succeeded
looked identical to one that silently did nothing, even under `--verbose`.
Fixed with one `alert_success()` line after the upload. When debugging "it
looks like nothing happened," confirm whether the operation actually ran
before assuming it didn't: `--only-show-errors` on any `aws s3` call makes
success silent by design.

### Auditing a bucket for a wrong-prefix tarball

Stream an object and read its first tar entry without extracting anything to
disk:

```sh
aws s3 cp --profile acidgenomics --only-show-errors \
  "s3://<bucket>/binaries/<os_slug>/<arch>/<name>/<version>.tar.gz" - \
  | tar -tzf - | head -1
```

Expect a line starting `/opt/koopa/app/...`. Anything else means the object
was pushed from a non-canonical prefix and must be deleted — no `/opt/koopa`
host can ever extract it.

## Tool-Inclusion Scope

koopa includes AI agentic coding **CLI assistants** from **major vendors only**:
Anthropic, Google, OpenAI, Microsoft (GitHub), and Amazon. OSS community assistants
(aider, goose, OpenHands, etc.) are out of scope regardless of popularity — the
scope is intentionally narrow to vendor-backed products.

This limit does not extend to **agent-adjacent tooling** — software that drives
or reviews the output of the agent CLIs koopa already installs, rather than acting
as an agent CLI itself. `roborev` (category `AI`, `default: false`) is the first
example: it runs a git post-commit hook and feeds findings back to whichever agent
CLI is installed. Vendor is irrelevant for this class of tool; judge each on
whether it operates on top of the existing agent CLIs, not on who publishes it.
