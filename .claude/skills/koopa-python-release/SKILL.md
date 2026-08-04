---
name: koopa-python-release
description: >-
  Acid Genomics Python package release — python.acidgenomics.com PEP 503
  S3+CloudFront index at /simple/, same-domain docs at /<name>/, categorized
  landing page at /, koopa app python publish/publish-docs/publish-assets/
  reindex, quality gate (ruff/pyright/ty/pytest/numpydoc lint), pytest
  --doctest-modules wiring, pkgdown-shaped docs/ structure (index.md +
  reference/index.rst + changelog.md), CHANGELOG format, smoke test, uv run
  venv-shebang gotcha, Sphinx docs-build RST/numpydoc pitfalls, tracked
  acidgenomics CSS theme for pydata-sphinx-theme (dark mode +
  specificity fixes). See koopa-r-release for the R analog.
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
   numpydoc lint src/<name>/
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
- `ruff`'s `[tool.ruff.lint.pylint] max-positional-args` is frequently
  scaffolded at `2`, which fires `PLR0917` on nearly every public function
  with more than 2 typed positional params — not a real defect. Check the
  actual max arity in the reported violations
  (`ruff check src/ 2>&1 | grep PLR0917 | grep -oE '\([0-9]+ >' | sort -V`)
  and set `max-positional-args` to that ceiling, not an arbitrary round number.

### `numpydoc lint` + doctest gate

Every package's `[tool.numpydoc_validation]` in `pyproject.toml` is enforced by
two things, both required for a real release (not just for building docs):

- `pytest.ini_options` sets `testpaths = ["src", "tests"]` and
  `addopts = "... --doctest-modules"`, so a plain `pytest` run executes every
  `Examples` doctest in `src/` alongside the hand-written test suite. Pytest's
  own doctest runner enables `ELLIPSIS` by default — a bare `doctest` module
  invocation (`python -m doctest file.py`) does not, so a doctest that passes
  under `pytest` can still fail under `python -m doctest` and vice versa;
  treat `pytest` as authoritative since that's what the gate runs.
- `numpydoc lint src/<name>/` checks docstring *structure* (every `Parameters`
  entry has a description, every function has a `Returns`/`Yields` section)
  — this is a separate tool from `pytest --doctest-modules`, which only checks
  that `Examples` *content* is correct. Run both; each catches things the
  other can't.
- `[tool.numpydoc_validation]` needs `exclude = ['\._\w']` to skip private
  (underscore-prefixed) functions/methods. `numpydoc`'s `node_name` is dotted
  module-qualified (e.g. `case_conversion._camel_case`), so `exclude = ['^_']`
  never matches — the underscore is never at the start of `node_name` once
  inside a module. A "private" module whose own functions have no individual
  underscore prefix (e.g. `_file_utils.py` holding `file_ext`, `init_dir`,
  etc.) isn't caught by this regex either; document those functions for real
  rather than widening the exclude, since a broader pattern risks masking
  genuine gaps.
- **`numpydoc lint`'s parser crashes (raises `ValueError`, not a lint
  finding) on a bare URL in a `See Also` section** — this aborts the whole
  run, not just that one docstring. `See Also` expects `name : description`
  cross-reference entries; move URLs to `Notes` instead (see the RST section
  below — this is the same underlying numpydoc parser, just triggered by
  `lint` instead of `sphinx-build`).
- A custom module-docstring section header other than the standard numpydoc
  set (`Parameters`, `Returns`, `Notes`, `Examples`, ...) — e.g. a hand-rolled
  `Public API` heading — fails with `GL06 Found unknown section`. Fold it
  into `Notes` instead of inventing a new heading.
- Mark network-dependent or slow doctests (live HTTP calls, downloading a
  multi-MB reference database) with `# doctest: +SKIP` on each line rather
  than fixing them to run fast — they're illustrative, not unit tests. A
  doctest that silently never ran until this gate was wired in is exactly
  the kind of thing worth checking for: re-verify the *literal expected
  output* of every doctest you touch by actually running it, since a
  docstring can look plausible and still assert the wrong value (case,
  precision, or exact string) with nothing ever having caught it before.
- **A function that prints progress messages breaks its own doctest** unless
  the example passes whatever silences it (`quiet=True` or equivalent) — the
  printed line becomes part of doctest's expected stdout and a plain
  `>>> result = my_func(...)` example fails because the expected block only
  has the return value, not the interleaved print. Either pass the quiet
  flag in the example or assign to `_`/`result` and don't show a return
  value at all if the function has no meaningful one.

### Running `pytest`/tools inside the package's own venv

Always use `uv run --extra develop pytest`, never a bare `pytest` on PATH —
koopa's own dev-tools-standalone convention (`pytest` as a global koopa app,
not a venv dependency) does NOT apply to `uv`-managed personal packages. Their
`pytest` lives in the `develop` extra and must run against the package's
own `.venv`.

**Symptom of getting this wrong:** `uv run pytest` silently resolves to a
*different* `pytest` (koopa's global one) and fails with
`ModuleNotFoundError: No module named 'numpy'` (or similar) even though the
package's own `.venv` has the dependency installed. Root cause is usually a
**stale shebang**: `.venv/bin/pytest`'s `#!` line hardcodes the venv's
absolute path at creation time. If the repo was ever cloned/moved (e.g.
`~/git/acidgenomics/py-foo` → `~/git/personal/py-foo`), the shebang still
points at the old, now-nonexistent path, so `./.venv/bin/pytest` fails with
`bad interpreter: ... no such file or directory` and `uv run` falls through
to a global `pytest` on PATH instead of erroring loudly.

Diagnose: `head -1 .venv/bin/pytest` — if it doesn't match the current repo
path, the venv is stale. Fix (non-destructive, no `rm -rf .venv` needed):
```sh
uv sync --extra develop --reinstall
```
This rewrites every entry-point script's shebang in place. Packages with
extra optional-dependency groups need those included too, e.g.
`uv sync --extra develop --extra bio --extra docs`.

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

**Blocked in an agent session:** `guard-installs.sh` (a `PreToolUse` hook)
rejects `uv pip install` when run from inside Claude Code — installs require
explicit user action. Substitute HTTP-only checks that prove the index and
artifact are correct without installing anything, and surface the real
install command for the user to run:

```sh
curl -sI 'https://python.acidgenomics.com/simple/syntactic/'   # 200
curl -sI 'https://python.acidgenomics.com/packages/syntactic-<ver>-py3-none-any.whl'
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

**No ReadTheDocs.** Do not scaffold or leave a `.readthedocs.yaml` in any
package — docs build entirely through `publish-docs`. If one is present
(leftover from an earlier scaffold, before this same-domain-docs setup
existed), delete it; the `docs/` source tree and its `[project.optional-dependencies] docs`
group stay, only the RTD-specific config file goes.

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

### `docs/` structure — pkgdown-shaped, not a flat API dump

Every package's `docs/` follows the same four-piece layout (mirroring
`r.acidgenomics.com`'s pkgdown sites, not a generic Sphinx API-reference
scaffold — these packages are libraries whose exported functions get called
directly, not consumed as an API surface):

```
docs/
├── conf.py              extensions += myst_parser; numpydoc_show_class_members = False
├── index.md             "Get started": narrative ported from README.md, with
│                        real worked examples as doctests (or +SKIP for
│                        network/slow ones)
├── reference/
│   └── index.rst        categorized `.. autosummary::` blocks, ~ short names,
│                        ONE ENTRY PER EXPORT — never a single module-level
│                        entry (that collapses to one flat kitchen-sink page)
└── changelog.md         ```{include} ../CHANGELOG.md``` with :start-line: 1
                        to skip the redundant "# Changelog" H1
```

Categories in `reference/index.rst` come from the R analog's `_pkgdown.yml`
`reference:` section (`~/git/personal/r-<name>/_pkgdown.yml`) — reuse that
curation rather than inventing new groupings. Verify the categorization is
exhaustive by diffing against `sorted(<pkg>.__all__)` in Python, not by eye;
with 70+ exports it's easy to silently drop one.

`docs/api.rst` and `docs/generated/<name>.rst` (the old single-module-entry
scaffold) should not exist in any package — delete them if found.

**macOS case-insensitive filesystem trap:** if a package exports both a
constant and a lowercase alias for the same object (e.g. `NA_STRINGS` and
`na_strings`), `autosummary_generate` writes `<pkg>.NA_STRINGS.rst` and
`<pkg>.na_strings.rst` — the same path on a case-insensitive filesystem. One
silently overwrites the other and the build emits `WARNING: autosummary:
stub file not found`. Reference only one of the two names in
`reference/index.rst`; mention the alias in prose in `index.md` instead.
Check every package's `__all__` for other lowercased duplicates before
assuming this doesn't apply.

**Install guide must match the README, not `pip install <name>`.** Sphinx
doc scaffolds (and stale hand-written ones) commonly default to
`pip install <name>` in the Installation section. That's wrong here — the
package doesn't exist on public PyPI, only on the private index — so it
sends readers straight into a `pip` failure or, worse, a same-named
malicious package on PyPI. Always match the README's install block exactly:

> ## Installation
>
> This package is hosted at [python.acidgenomics.com](https://python.acidgenomics.com/).
> We recommend using [uv](https://docs.astral.sh/uv/) to install.
>
> ```sh
> uv pip install \
>     --index-url 'https://python.acidgenomics.com/simple/' \
>     <name>
> ```

Check `README.md` and `docs/index.md` together whenever the index URL
changes — they drift independently and neither build/test/lint gate catches
a wrong-but-valid install snippet.

## Docs-build gotchas (`sphinx-build -W`)

`publish-docs` runs Sphinx with `-W` (warnings-as-errors), so any of these
block a real release, not just lint:

- **Google-style `Args:` docstring blocks break docutils.** These packages use
  numpydoc (`Parameters`/`Returns`/`Notes` sections), not Google style. A
  stray `Args:` block — especially one with a wrapped continuation line —
  produces `ERROR: Unexpected indentation.`. Convert to a numpydoc
  `Parameters` section (or, for a function with no complex params, just
  prose) to match the rest of the codebase.
- **A docstring mentioning a name ending in `_` as plain text breaks RST.**
  RST treats a bare word ending in `_` followed by whitespace as a hyperlink
  reference target. `"""Raised by assert_ when ..."""` fails with
  `ERROR: Unknown target name: "assert"` (RST strips the trailing
  underscore looking for a link). Fix: wrap it in double backticks —
  ``` ``assert_`` ``` — so it's rendered as literal code, not parsed as a link.
- **`See Also` expects a cross-reference list, not a bare URL.** numpydoc's
  `See Also` section parses `name : description` entries; a plain URL line
  fails signature-mangling with `Error parsing See Also entry '<url>'`. Move
  URLs to a `Notes` section instead (free-form prose, no special parsing).
- **numpydoc's per-class method autosummary conflicts with
  `sphinx.ext.autosummary`'s stub generation** on any class with several
  public methods, producing one `autosummary: stub file not found
  '<Class>.<method>'` warning per method (autodoc already documents each
  method inline on the same page; the numpydoc table just duplicates that
  with broken links). Fix in `conf.py`:
  ```python
  numpydoc_show_class_members = False
  ```

## Privacy leaks in published docs: local paths reaching S3

Sphinx's autodoc renders literal parameter *default values* into the
generated signature — including objects that stringify to an absolute
filesystem path. Any function with a default that resolves the local
environment at *import time* bakes whoever's machine built the docs
directly into the public page:

```python
# WRONG — evaluated once, at import time, in whichever environment
# happens to run `sphinx-build` (often the docs author's own checkout).
def download_thing(*, output_dir: Path = Path.cwd()) -> None: ...


# Renders publicly as:
#   output_dir: Path = PosixPath('/Users/<realname>/git/personal/py-foo')
```

This is the exact same root cause as Python's classic mutable-default-argument
trap — an expression in a `def` signature runs once, at *def* time, not once
per call — just surfacing as a privacy leak instead of a data-sharing bug.
**Fix:** default to `None` in the signature, resolve the real value inside
the function body:

```python
def download_thing(*, output_dir: Path | None = None) -> None:
    if output_dir is None:
        output_dir = Path.cwd()  # evaluated per call, not baked into the signature
    ...
```

Applies to any of `Path.cwd()`, `Path.home()`, `os.getcwd()`, or similar
environment-dependent calls used directly as a parameter default anywhere in
`src/`. Audit with:

```sh
grep -rn "Path\.cwd()\|os\.getcwd()\|Path\.home()" src/
```

A hit inside a function *body* is fine (evaluated per call); a hit in a
`def ...(param: Path = <expr>)` *signature* is the bug. `numpydoc lint` and
`sphinx-build -W` do not catch this — it's a semantically valid signature
that just happens to expose whoever built it. **Audit rendered HTML for
usernames/home-dir paths after any `publish-docs`, not just at
`sphinx-build` time** — grep the actual synced output, or the live pages,
for the local account name:

```sh
grep -rl "$(whoami)" /path/to/built/html/
```

**A second, structural leak path: Sphinx's own build cache.** By default
`sphinx-build` writes `.doctrees/` (pickled `environment.pickle` +
per-page `.doctree` files) inside the output directory, and those pickles
embed full absolute local paths (source file locations, `.venv` site-packages
paths) regardless of anything in `conf.py` or the docstrings — this is
Sphinx's own incremental-build bookkeeping, unrelated to doc content.
`publish_docs()` in `pypi.py` used to sync the whole output directory verbatim,
so `.doctrees/` (and the paths inside it) went to S3 on every publish, for
every package, invisibly — `grep -rl` against the rendered *HTML* won't find
this, since it's binary pickle data, not markup. Fixed by isolating the
doctree cache outside the synced tree entirely:

```python
subprocess.run([..., "sphinx-build", "-W", "-b", "html", "-d", doctree_dir, "docs/", out_dir], ...)
```

`-d PATH` (`--doctree-dir`) tells Sphinx to write its cache to a directory
that's never part of what gets synced — instead of trying to exclude
`.doctrees/*` from the sync afterward, which is one config drift away from
silently regressing back. If a leak like this is ever found on an
already-published package, deleting the HTML doesn't fix it retroactively —
the actual polluted prefix on S3 needs a direct `aws s3 rm --recursive`
before republishing:

```sh
aws s3 rm "s3://python-<acct>-us-east-1-an/<name>/.doctrees/" --recursive --profile acidgenomics
```

**Full-bucket audit** (catches both leak classes at once, across every
package, independent of what any single `sphinx-build` run looked like):

```sh
aws s3 sync s3://python-<acct>-us-east-1-an /tmp/s3-audit --profile acidgenomics --quiet
grep -rla "$(whoami)" /tmp/s3-audit/   # must be empty
```

## Same-domain acidgenomics CSS theme for Sphinx docs

`pydata_sphinx_theme`'s default look doesn't match the site's minimalist,
monospace-first Dracula-derived aesthetic (same one used by
`r.acidgenomics.com`'s pkgdown sites, sourced from `steinbaugh.com/css/`).
pkgdown and Sphinx render completely different DOM/class structures
(Bootstrap navbar classes differ, Pygments vs. pandoc/Rouge syntax-highlight
token conventions), so the two can't share one literal CSS file — the fix is
a purpose-written stylesheet that maps `pydata-sphinx-theme`'s own
`--pst-color-*` CSS variables onto the site's `--foreground-color` /
`--purple-color` / etc. palette (from `steinbaugh.com/css/colors.css`), plus
a Pygments token-class → color mapping that reuses the same short-code
convention (`.k` keyword, `.s` string, `.c` comment, ...) that Rouge/pandoc
also use — see `steinbaugh.com/css/rouge.css` + `rouge-light.css` for the
canonical mapping to replicate.

This stylesheet is tracked at `lang/python/src/koopa/assets/sphinx.css` in the
koopa repo (not hand-uploaded blind — it's reviewable in git like any other
source file) and published to
`s3://python-<acct>-us-east-1-an/css/sphinx.css` via:

```sh
koopa app python publish-assets
```

Implementation: `publish_assets()` in `pypi.py`. Every package's `conf.py`
references the S3 URL:

```python
html_css_files = ["https://python.acidgenomics.com/css/sphinx.css"]
```

One shared file, one absolute URL per package — no local `docs/_static/`
duplication, and a future palette change propagates to all packages' docs on
their next `publish-docs` run without touching any package repo. Re-run
`publish-assets` after editing the tracked CSS file; `publish-docs` does not
re-upload it.

**Two failure modes to check for whenever editing this file**, since a
passing `sphinx-build` says nothing about which CSS rule actually wins in
the browser — verify visually (toggle OS dark/light mode) after publishing:

- **Dark mode requires its own `--pst-color-*` block.** `colors.css` flips
  its palette via `@media (prefers-color-scheme: dark)` on `:root`, so a
  `html[data-theme="dark"] { --pst-color-primary: var(--purple-color); ... }`
  block (mirroring the light one) is required — without it, dark mode falls
  back to pydata's own unmapped defaults.
- **Syntax-highlight selectors must match Sphinx's own specificity, not just
  exist.** Sphinx's generated `_static/pygments.css` emits
  `html[data-theme="light"] .highlight .k { ... }` (specificity 0,3,1). A
  bare `.highlight .k { ... }` (0,2,0) in the shared stylesheet loses
  regardless of load order — the whole highlighting block silently becomes
  dead code. Scope every `.highlight .<tok>` rule under
  `html[data-theme="light"]`/`html[data-theme="dark"]` to match.

## Landing page

`reindex` auto-generates `index.html` at the bucket root from each wheel's
`Summary` field (read via `zipfile` while the wheel is local for hashing).
Categorized via `_LANDING_CATEGORIES` in `pypi.py` — a
`list[tuple[str, list[str]]]`, section order matters — with entries sorted
alphabetically (case-insensitive, by display name) within each section. Any
package not listed in `_LANDING_CATEGORIES` falls into an "Other" section so
nothing silently disappears from the page. Add new packages to
`_LANDING_CATEGORIES` when they're published, or they'll land in "Other"
until categorized. Regenerated automatically on every `publish` or
`reindex` — no manual step beyond keeping `_LANDING_CATEGORIES` current.

**No install snippet on the landing page, by design.** An earlier revision
included `Install: uv pip install --index-url ... <package>` in the footer
via `render_landing()`'s `install_note` param — removed because it's
confusing without per-package context (each package's own docs already has
a proper Installation section matching its README). The parameter still
exists on `render_landing()` (shared with the R site's caller in `cran.py`,
which never passed it either), but don't reintroduce it here.

**Categories are duplicated, not shared, across the two sites — keep them in
sync by hand.** `_LANDING_CATEGORIES` here and `_CATEGORIES` in `cran.py` (R
side) are independent lists; nothing enforces that a package with both a
Python and R implementation sits under the same heading on both
python.acidgenomics.com and r.acidgenomics.com. Update both files in the
same change when adding or recategorizing a package. Category assignment is
easy to get wrong on the first pass — `goalie` and `syntactic` both sat
under "Import/export" for a while simply because that's where an earlier
revision put them, not because either does any I/O; `acidplyr` isn't
"Infrastructure" just because other packages build on it, since users also
call it directly (it ended up with its own "Data manipulation" section).
Judge by what the package actually does for the person calling it, not by
where a sibling package already sits, and when genuinely unsure, ask rather
than pick whichever category "seems close enough."

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

Python's `/simple/` (index) + `/packages/` (wheels/sdists) split is PEP 503
canonical, matching `pypi.org`'s own layout — do not "fix" this to match R's
`/<name>/` docs convention. `/packages/` here holds real artifacts, not docs,
so it can never be repurposed the way R's `/packages/` prefix was. See
`koopa-r-release` for the R side of this: R's pkgdown docs moved from
`/packages/<name>/` to `/<name>/` specifically to converge on one rule across
both sites (artifacts under reserved prefixes, docs at `/<name>/`) — a move
that was only possible because R's `/packages/` never held artifacts.

The GitHub "Website" field on each `py-<pkg>` repo (independent of any URL in
the repo content itself) also needs setting/updating via `gh api -X PATCH` —
see `koopa-r-release`'s "Don't forget the GitHub Website field" note, including
the multi-account `gh auth` gotcha.
