# Acid Genomics Python Package Release

## Hosting

Python packages are hosted at **python.acidgenomics.com** — a private PEP 503
"simple" index backed by S3 (`s3://python-REDACTED_ACCOUNT_ID-us-east-1-an`) and served
via CloudFront. Packages are NOT published to public pypi.org.

- Packages: `s3://…/packages/<file>`
- Index: served at the bucket root (`/`) — `index.html` + `<name>/index.html`
- Publish tooling: `koopa app python publish <package-dir>` (calls `koopa.pypi.publish`)
- Reindex tooling: `koopa app python reindex`
- Implementation: `lang/python/src/koopa/pypi.py`

## Consumer install

```sh
# one-off
uv pip install --index-url 'https://python.acidgenomics.com/' syntactic

# project pyproject.toml
[[tool.uv.index]]
url = "https://python.acidgenomics.com/"
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
index HTML at the bucket root, syncs it (with `--exclude "packages/*"` to
protect wheels from `--delete`), and invalidates CloudFront `/*`.

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
    --index-url 'https://python.acidgenomics.com/' \
    syntactic
"$tmp/venv/bin/python" -c "import syntactic; print(syntactic.__all__)"
rm -rf "$tmp"
```

## pypi.py index layout

The index is served at the **domain root** (not `/simple/`). The S3 bucket
structure is:

```
packages/                     ← wheels + sdists (never touched by reindex sync)
index.html                    ← root listing: <a href="syntactic/">syntactic</a>
syntactic/index.html          ← per-package: links to ../packages/<file>#sha256=…
```

`_sync_index_to_s3` uses `--exclude "packages/*"` with `--delete` so that
reindexing never wipes uploaded artifacts.

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
