---
name: koopa-release
description: >-
  koopa release preparation and local agent-assisted publication, CHANGELOG,
  version bump, pre-release gate, merged-commit tagging, GitHub release,
  stable archive, source mirror, and website. Use when preparing or
  publishing a koopa release, or when a release PR has been merged.
---

# koopa Release Procedure

## What bumpver does (and doesn't do)

`bumpver` is configured in `pyproject.toml` with `tag = false`, `push = false`,
`commit = true`. Running `bumpver update` (or equivalent) bumps two lines in
`pyproject.toml`:

- `version = "<pep440>"` (no `v` prefix)
- `current_version = "v<version>"` (with `v` prefix)

It creates a single commit `Bump version to vX.Y.Z.`: **no tag, no push**.
Since `commit = true`, do not run it; prepare the version changes without
committing.

## Release checklist

1. **Version bump**: already done by `bumpver` (the `Bump version to vX.Y.Z.`
   commit). Confirm `pyproject.toml:3` reads the new version, and confirm the
   plugin manifest versions moved too: the canonical `plugins/koopa/plugin.json`
   plus its generated adapters (`.claude-plugin/marketplace.json`,
   `plugins/koopa/.claude-plugin/plugin.json`,
   `plugins/koopa/gemini-extension.json`), all wired via
   `[tool.bumpver] file_patterns`. Confirm with
   `koopa develop generate-agent-config --check`.
2. **Write CHANGELOG.md**: prepend a new section directly above the previous
   `## koopa X.Y.Z (...)` heading. See format below.
3. **Website documentation**: update the relevant `docs/*.md` pages for
   user-facing changes. The site publish command regenerates the CLI reference
   and default app stack, then builds Sphinx with warnings as errors:
   ```sh
   koopa develop publish-docs --dry-run
   ```
   Run this from the koopa prefix containing the release changes. Publishing
   does not happen automatically when the release is merged.
4. **Pre-release gate**: all must pass. Run the whole gate in one command:
   ```sh
   koopa develop check
   ```
   or the individual checks it wraps:
   ```sh
   ruff check lang/python/src/
   ruff format --check lang/python/src/
   pyright lang/python/src/
   ty check lang/python/src/koopa
   pyrefly check
   numpydoc lint $(find lang/python/src/koopa -name '*.py')
   pytest lang/python/tests/
   ```
5. **Release PR**: title the `develop`→`main` PR with the bare tag, for example
   `v0.41.0`. Leave commits and branch pushes to the user; do not merge a PR
   unless authorized.
6. **After merge**: when asked to publish or complete the release, carry out
   the local publication procedure below rather than leaving tagging, release
   publishing, or documentation refresh as manual handoffs. A request to
   prepare a release alone does not authorize publication or merging.

## Local post-merge publication

Use the local koopa installation and its existing `acidgenomics` AWS profile.
Do not set up GitHub Actions or store AWS credentials on GitHub. See
`koopa-aws-env` for the local configuration. Once the user asks to publish a
merged release, the repository permits the agent to create and push its new
tag through the full command below. This exception does not permit commits,
branch pushes, or force-pushing, moving, or deleting tags. Do not merge a PR
unless authorized.

Run the end-to-end command from a clean checkout of the merged release:

```sh
koopa develop publish-release vX.Y.Z --pr 123
```

The `--pr` form orchestrates the entire flow below; do not repeat the steps
manually after it succeeds. It requires authenticated local `gh` and AWS
access, the `acidgenomics` profile, and a clean release tree matching
`origin/main`. The existing `koopa develop publish-release vX.Y.Z` form
remains archive-only. Do not run the full form speculatively: it creates and
pushes a tag, publishes the archive and docs, creates a GitHub release, and
deletes the previous GitHub release while preserving its tag.

When the tag needs pushing, the pre-push hook runs the quality gate again after
the command's own preflight gate. This duplication is expected; do not bypass
the hook or its corporate-identity guard.

The automated sequence and its safeguards:

1. **Verify the release**: use `gh pr view` to confirm that the intended
   `develop`→`main` PR is merged and obtain its merged head and merge commit.
   Run `git fetch origin` before inspecting remote-tracking refs. Choose the
   final tested release commit actually included in `origin/main`, including
   any fixes after the version bump; do not blindly tag the bump commit. For
   a squash merge, use the merged commit on `main` if the PR head is not an
   ancestor. Confirm the selected commit has the expected `pyproject.toml`
   version and changelog, and the checkout used to build the docs has exactly
   that committed tree with no uncommitted changes affecting publication.
   Do not switch branches or overwrite local changes to make this true.
2. **Preflight**: run `koopa develop check` and a documentation dry run.
   Check the source mirror using the release's `bootstrap.sh` and
   `.python-version` and confirm the exact bootstrap source URLs needed by
   the stable installer are available under `https://koopa.acidgenomics.com/src/`.
   `koopa develop audit-src-mirror` checks registry entries and reports
   missing objects; it does not by itself prove every tagged bootstrap URL
   is available. Use `koopa develop mirror-src <name>...` for missing
   registry sources and retry the relevant audit. Do not use `--prune`.
   The automated full-release command checks the mirror before tagging,
   tries to repair a failed audit, and stops if the mirror or recheck fails,
   including for unrelated missing app sources.
3. **Tag**: inspect both local and remote tags first. If `vX.Y.Z` exists at
   the intended commit, reuse it; if it points elsewhere, stop rather than
   moving or force-pushing it. Otherwise create and push it at the verified
   commit, then confirm the remote tag.
4. **Publish the experimental stable archive**: archive-only `koopa develop
   publish-release vX.Y.Z` requires the tag to be an ancestor of the local
   `refs/heads/main`, not just `origin/main`. Fetch first and inspect that
   local branch; if absent, create a tracking branch without checking it out.
   If it is stale, fast-forward only after verifying it has no divergent local
   commits; never force-update or delete it. The `--pr` form instead checks
   freshly fetched `origin/main`, so no local `main` branch is needed.
   The full command publishes from the release prefix, then verifies
   `/releases/latest`, the archive checksum, and `/install-release`. CloudFront
   invalidation may take time to propagate. Git-managed installation remains
   the default.
5. **Publish the website**: build the docs from the verified release checkout
   and verify changed public pages and the generated app stack. The sync
   invalidates CloudFront but does not delete stale S3 keys. For removed or
   renamed pages, inspect `koopa develop prune-stale-docs`; delete confirmed
   stale keys only with explicit authorization.
6. **Publish the GitHub release**: create `vX.Y.Z` against the existing
   verified tag with its bare tag as the title and release notes from the
   matching changelog section. Verify it is the latest GitHub release before
   deleting the previous GitHub release with `gh release delete vPREV --yes`;
   never delete the prior tag. If a release already exists, inspect it and
   resume safely rather than creating a duplicate or overwriting its notes.
   Confirm both release metadata and the old and new tags afterward.

Each publish step has external side effects. On failure, report what succeeded
and what remains; do not claim the release is complete. Inspect existing tags,
release metadata, and published artifacts, then rerun the same `--pr` command
to resume safely when its checks permit; do not force-move conflicting tags.
If the user runs the command instead, inspect its outcome and independently
verify the public latest manifest, GitHub release, and new and previous remote
tags before reporting completion.

## CHANGELOG.md format

File: `CHANGELOG.md` at the repo root.

Section heading: `## koopa X.Y.Z (YYYY-MM-DD)`
- Bare version, no `v` prefix.
- ISO date in parentheses, use the date of the version-bump commit.
- Insert a blank line between `## heading` and the first subsection heading.

Subsections (in order, omit if empty):
- `Major changes:` substantive user-facing changes, ~4-6 bullets.
- `Minor changes:` small fixes, housekeeping, version bumps.
- `New apps:` **only present when new top-level keys were added to
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
- Exclude: agent config/skills/rules reorganizations (internal tooling), todo
  updates, merge commits, `Prepare release` housekeeping commits.
- `New apps:` entries: name, version, one-line description, default/non-default.

## Version source of truth

`[project]` in `pyproject.toml`: `version = "X.Y.Z"`. Read at runtime by
`koopa_version()` in `lang/python/src/koopa/version.py`. Plugin manifest
versions and `[tool.bumpver] current_version` must match.

## GitHub releases

When publishing a GitHub release for a koopa tag, set its name to the bare tag
exactly (for example, `v0.29.0`), not a product-prefixed name such as
`koopa v0.29.0`.

Koopa keeps only the newest GitHub release. After publishing `vNEXT`, delete
the prior GitHub release with `gh release delete vPREV --yes`; do not delete
the prior `vPREV` Git tag.
