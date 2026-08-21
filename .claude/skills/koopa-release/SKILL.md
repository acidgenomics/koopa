---
name: koopa-release
description: >-
  koopa release procedure — CHANGELOG authoring, bumpver contract, pre-release
  gate, and what stays with the user. Use when preparing a release, writing
  release notes, or understanding what "prepare the release" entails.
---

# koopa Release Procedure

## What bumpver does (and doesn't do)

`bumpver` is configured in `pyproject.toml` with `tag = false`, `push = false`,
`commit = true`. Running `bumpver update` (or equivalent) bumps two lines in
`pyproject.toml`:

- `version = "<pep440>"` (no `v` prefix)
- `current_version = "v<version>"` (with `v` prefix)

It creates a single commit `Bump version to vX.Y.Z.` — **no tag, no push**.
Tagging, pushing, and merging `develop`→`main` are always the user's job.

## Release checklist

1. **Version bump** — already done by `bumpver` (the `Bump version to vX.Y.Z.`
   commit). Confirm `pyproject.toml:3` reads the new version, and confirm the
   3 plugin manifest versions moved too (`.claude-plugin/marketplace.json` and
   the two under `plugins/koopa/`) — all wired via `[tool.bumpver] file_patterns`.
2. **Write CHANGELOG.md** — prepend a new section directly above the previous
   `## koopa X.Y.Z (...)` heading. See format below.
3. **Pre-release gate** — all must pass:
   ```sh
   pytest lang/python/tests/
   ruff check lang/python/src/
   ruff format --check lang/python/src/
   pyright lang/python/src/
   ```
4. **User-owned** — tag, push, and merge:
   ```sh
   git tag vX.Y.Z
   git push origin develop
   git push origin vX.Y.Z
   # then open a PR: develop -> main
   ```

## CHANGELOG.md format

File: `CHANGELOG.md` at the repo root.

Section heading: `## koopa X.Y.Z (YYYY-MM-DD)`
- Bare version — no `v` prefix.
- ISO date in parentheses — use the date of the version-bump commit.
- No blank line between `## heading` and the first subsection heading.

Subsections (in order, omit if empty):
- `Major changes:` — substantive user-facing changes, ~4-6 bullets.
- `Minor changes:` — small fixes, housekeeping, version bumps.
- `New apps:` — **only present when new top-level keys were added to
  `etc/koopa/app.json`** this cycle. Verify with:
  `git diff vPREV..HEAD -- etc/koopa/app.json | grep -E '^\+  "[a-z]'`

Bullet style: `-` list, wrapped at ~80 columns, two-space continuation indent.
Match the style of the surrounding entries exactly.

### Determining the commit range

Previous release tag: find the prior `Bump version to vX.Y.Z.` commit or the
existing `vPREV` git tag. The range is `vPREV..HEAD` (or `PREV_BUMP_SHA..HEAD`
if the tag hasn't been created yet for the previous release).

### What to include / exclude

- Include: license changes, new modules, new CLI commands, new apps, significant
  shell/config parity work, performance fixes, version-check improvements.
- Exclude: Claude config/skills/rules reorganizations (internal tooling), todo
  updates, merge commits, `Prepare release` housekeeping commits.
- `New apps:` entries: name, version, one-line description, default/non-default.

## Version source of truth

`pyproject.toml:3` — `version = "X.Y.Z"`. Read at runtime by
`koopa_version()` in `lang/python/src/koopa/version.py`. No other file
hardcodes the koopa version.
