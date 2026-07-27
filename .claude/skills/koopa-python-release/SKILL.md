---
name: koopa-python-release
description: >-
  Acid Genomics Python package release — python.acidgenomics.com PEP 503
  S3+CloudFront index at /simple/, same-domain docs at /<name>/, generated
  landing page at /, koopa app python publish/publish-docs/reindex, quality
  gate, CHANGELOG format, smoke test. See koopa-r-release for the R analog.
---

# Acid Genomics Python Package Release

## Hosting

Python packages are hosted at **python.acidgenomics.com** — a private PEP 503
"simple" index backed by S3 (bucket `python-<account-id>-us-east-1-an` via
`koopa_s3_bucket("python")` in `aws.py`) and served via CloudFront. Packages
are NOT published to public pypi.org.

All Python materials (packages, docs, landing page) live on the same domain
and bucket. Layout:

| URL | S3 key | Produced by |
|---|---|---|
| `python.acidgenomics.com/` | `index.html` | `reindex` (generated landing page) |
| `.../simple/` | `simple/index.html` | `reindex` (PEP 503 root) |
| `.../simple/<name>/` | `simple/<name>/index.html` | `reindex` (per-package) |
| `.../packages/<file>` | `packages/<file>` | `publish` |
| `.../<name>/` | `<name>/index.html` | `publish-docs` (Sphinx) |

- Publish tooling: `koopa app python publish <package-dir>`
- Docs tooling: `koopa app python publish-docs <package-dir>`
- Reindex tooling: `koopa app python reindex`
- Implementation: `lang/python/src/koopa/pypi.py`

## Consumer install

```sh
# one-off
uv pip install --index-url 'https://python.acidgenomics.com/simple/' syntactic

# project pyproject.toml
[[tool.uv.index]]
name = "acidgenomics"
url = "https://python.acidgenomics.com/simple/"

[tool.uv]
sources.syntactic = { index = "acidgenomics" }
```

## Release checklist (e.g. `py-syntactic`)

Applies to any package in `~/git/personal/py-<name>` that uses `bumpver` +
`uv_build`. Adapt as needed for other projects.

### Pre-flight

1. Confirm version in `pyproject.toml` (`version = "X.Y.Z"` and
   `current_version = "vX.Y.Z"` under `[tool.bumpver]`).
2. Run all quality gates:
   ```sh
   ruff format --check src/ tests/ docs/
   ruff check src/ tests/ docs/
   pyright
   ty check
   pytest
   ```
3. All gates must be green before proceeding.

### bumpver (if version not yet bumped)

`bumpver` is configured with `tag = false`, `push = false`, `commit = true`.
Running `bumpver update --patch` (or `--minor`/`--major`) bumps two lines in
`pyproject.toml` and creates a single commit — no tag, no push. The user owns
tagging and pushing.

### Quality gate notes

- `pyright` and `ty check` must exclude `tests/` (test files import `pytest`,
  a PATH dev tool not in the venv). Add to `pyproject.toml`:
  ```toml
  [tool.pyright]
  exclude = ["tests", ".venv"]

  [tool.ty.src]
  exclude = [".venv", "**/__pycache__", "**/.*", "tests"]
  ```
- `ty check` can fail with `Invalid VIRTUAL_ENV` if the shell has a stale env
  var (e.g. after moving the repo). Fix with:
  ```toml
  [tool.ty.environment]
  python = ".venv"
  ```
  This overrides `VIRTUAL_ENV` and points `ty` directly at the local venv.
- `pytest` needs `pythonpath = ["src"]` in `[tool.pytest.ini_options]` for
  src-layout packages to be importable without a venv install.

### Publish

```sh
koopa app python publish ~/git/personal/py-syntactic
```

This runs `uv build`, uploads wheel + sdist to S3, regenerates the PEP 503
index HTML under `simple/` (scoped `--delete` cannot touch `packages/` or
per-package docs), re-generates the landing page at `/`, and invalidates
CloudFront `/*`.

Requires: AWS profile `acidgenomics` configured; `AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON`
set (or `AWS_CLOUDFRONT_DISTRIBUTION_ID` as fallback) — loaded from
`<koopa-root>/.env` if not already in the environment.

### User-owned (git)

```sh
git tag vX.Y.Z
git push origin main
git push origin vX.Y.Z
```

Merging `develop`→`main` via PR before tagging is the standard flow.

### Verification

After publish, confirm the package is installable:
```sh
tmp=$(mktemp -d)
uv venv --quiet "$tmp/venv"
uv pip install --python "$tmp/venv/bin/python" \
    --index-url 'https://python.acidgenomics.com/simple/' \
    syntactic
"$tmp/venv/bin/python" -c "import syntactic; print(syntactic.__all__)"
rm -rf "$tmp"
```

## pypi.py index layout

The PEP 503 index lives under the `simple/` prefix. The S3 bucket structure is:

```
packages/                         <- wheels + sdists (never touched by reindex sync)
simple/index.html                 <- root listing: <a href="syntactic/">syntactic</a>
simple/syntactic/index.html       <- per-package: links to ../../packages/<file>#sha256=...
index.html                        <- generated landing page (separate cp, not in simple/ sync)
<name>/                           <- Sphinx docs (published by publish-docs)
```

`_sync_index_to_s3` targets `s3://bucket/simple/` with `--delete`; this confines
deletion to the `simple/` subtree so packages and docs are never at risk.

## Documentation

```sh
koopa app python publish-docs ~/git/personal/py-syntactic
```

This builds Sphinx docs via `uv run --extra docs sphinx-build -W -b html docs/ <tmp>/html`,
syncs to `s3://python-<acct>-us-east-1-an/syntactic/` (same bucket as packages),
and invalidates CloudFront `/*` on the same distribution.

Docs are served at **https://python.acidgenomics.com/syntactic/** — no separate
subdomain, no separate bucket, no separate CloudFront distribution.

`--delete` in the docs sync is scoped to `<name>/`, so it cannot touch `simple/`
or `packages/`.

A package name equal to `simple` or `packages` is rejected at publish-docs time
to prevent any possible collision with the index/artifacts prefixes.

Requires: same AWS profile + `AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON` as `publish`.
No additional env vars needed. `AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON_DOCS` is
not used and does not need to be set.

### Verification

```sh
# Dry-run docs build locally (no AWS required):
cd ~/git/personal/py-syntactic
uv run --extra docs sphinx-build -W -b html docs/ /tmp/docs-test

# After publish-docs:
curl -sI https://python.acidgenomics.com/syntactic/ | head -5

# Confirm package index is unaffected:
koopa app python reindex
curl -sI https://python.acidgenomics.com/simple/syntactic/ | head -5
```

## Landing page

`reindex` auto-generates `index.html` at the bucket root from each wheel's
`Summary` field (read via `zipfile` while the wheel is local for hashing).
Flat alphabetical list with links to per-package docs (`/<name>/`) and an
install note pointing at `/simple/`. No curated categories — fully automatic
on every `publish` or `reindex`.

## CHANGELOG format (py-* packages)

Keep-a-Changelog style, version at top. Example heading:

```markdown
## 0.1.0 (2026-06-19)
```

Sections: `### Features`, `### Bug Fixes`, `### Changes`, `### Tests`.
Omit empty sections.

## R analog

R packages are hosted at `r.acidgenomics.com` via a drat repo in
`~/git/personal/r-acidgenomics-com`, using the same AWS account/profile/
CloudFront pattern. The Python index reuses that infra with a hand-rolled
PEP 503 generator in place of drat.
