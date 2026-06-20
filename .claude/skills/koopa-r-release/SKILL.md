# koopa R Package Release

## Hosting

R packages are hosted at `https://r.acidgenomics.com` via a drat repository in
`~/git/personal/r-acidgenomics-com` (GitHub: `acidgenomics/r-acidgenomics-com`).

- **S3 bucket:** `r-REDACTED_ACCOUNT_ID-us-east-1-an` (us-east-1)
- **CloudFront distribution:** `REDACTED_CF_DIST_ID`
- **AWS profile:** `acidgenomics`
- **CloudFront ID env var:** `AWS_CLOUDFRONT_DISTRIBUTION_ID_R` (optional — falls back to
  `AWS_CLOUDFRONT_DISTRIBUTION_ID`, then the hardcoded default above)

The drat repo layout:
- `src/contrib/` — source tarballs (`<Pkg>_<ver>.tar.gz`) + `PACKAGES*` manifests
- `bin/macosx/big-sur-arm64/contrib/<Rminor>/` — macOS arm64 binaries
- `bin/macosx/big-sur-x86_64/contrib/<Rminor>/` — macOS x86_64 binaries

## Implementation

All publish logic lives in `lang/python/src/koopa/cran.py` (mirror of `pypi.py`).

## Commands

### `koopa app r publish <package-dir>`

Build source + macOS binary tarballs, insert both into the local drat repo, sync
`bin/` + `src/` to S3, invalidate the three `PACKAGES*` CloudFront paths, and print
the user-owned drat-repo git commands.

```sh
# Standard publish (with R CMD check):
koopa app r publish ~/git/personal/r-syntactic

# Skip R CMD check (faster, use when check already passed):
koopa app r publish ~/git/personal/r-syntactic --no-check

# Build + insert locally only, skip S3 sync (dry-run equivalent):
koopa app r publish ~/git/personal/r-syntactic --no-deploy

# Skip CloudFront invalidation (rarely needed):
koopa app r publish ~/git/personal/r-syntactic --no-invalidate

# Use a non-default drat repo path:
koopa app r publish ~/git/personal/r-syntactic --repo /path/to/drat
```

The default drat repo is `ACIDGENOMICS_REPO` env var, or `~/git/personal/r-acidgenomics-com`.

**macOS arch caveat:** `R CMD INSTALL --build` produces a binary for the *current*
architecture only. Publishing from an arm64 machine updates `big-sur-arm64/contrib/`
only. To populate `big-sur-x86_64/`, publish again from an Intel machine. The source
tarball (`src/contrib/`) is arch-independent and is always updated.

### `koopa app r deploy [--jekyll]`

Sync `bin/` + `src/` to S3 and invalidate CloudFront — 1:1 replacement for the
(now-broken) bash `deploy` script in `r-acidgenomics-com`. Add `--jekyll` to also
build and deploy the Jekyll site.

```sh
# Sync packages + invalidate CloudFront:
koopa app r deploy

# Also rebuild and deploy the Jekyll site:
koopa app r deploy --jekyll

# Skip CloudFront invalidation:
koopa app r deploy --no-invalidate
```

### `koopa app r archive`

Move superseded package versions into `Archive/` subdirectories — replacement for
the `archive` Rscript in `r-acidgenomics-com`. Calls
`drat::archivePackages(repopath=<repo>, type="both")` then prints the user-owned git
commands to commit the result.

```sh
koopa app r archive
```

## User-owned git steps (after publish/archive)

These are printed to stderr by the commands. Run manually in the drat repo:

```sh
# After publish:
git -C ~/git/personal/r-acidgenomics-com add ./
git -C ~/git/personal/r-acidgenomics-com commit -m "Add syntactic_0.8.0.tar.gz."
git -C ~/git/personal/r-acidgenomics-com push

# After archive:
git -C ~/git/personal/r-acidgenomics-com add ./
git -C ~/git/personal/r-acidgenomics-com commit -m "Update archive"
git -C ~/git/personal/r-acidgenomics-com push
```

## End-to-end release procedure

1. **Pre-flight:** confirm version in `DESCRIPTION` (`Version: X.Y.Z`, `Date: YYYY-MM-DD`).
2. **Quality gate (run by koopa):** `R CMD check --as-cran --no-manual` (unless `--no-check`).
3. **Publish:** `koopa app r publish ~/git/personal/r-<pkg>` — builds source + binary,
   inserts into drat, syncs S3, invalidates CloudFront.
4. **Commit drat repo** (user-owned): `git -C ~/git/personal/r-acidgenomics-com add ./`
   → `git commit -m "Add <pkg>_<ver>.tar.gz."` → `git push`.
5. **Archive** (periodically): `koopa app r archive` → commit with "Update archive".
6. **Verify:** install from the live index (smoke test below).

## Verification smoke test

```sh
tmp=$(mktemp -d)
TMP_LIB="$tmp" Rscript -e '
  lib <- Sys.getenv("TMP_LIB")
  install.packages("syntactic", repos = "https://r.acidgenomics.com", lib = lib)
  library(syntactic, lib.loc = lib)
  cat("OK", as.character(packageVersion("syntactic", lib.loc = lib)), "\n")
'
rm -rf "$tmp"
```

Replace `syntactic` with the package you just published.

## DESCRIPTION conventions (R package releases)

- `Version: X.Y.Z` — manual bump; no bumpver.
- `Date: YYYY-MM-DD` — update to release date.
- `License: Apache License (>= 2)` — the CRAN shipped-template form; do NOT use
  `| file LICENSE`.
- `LICENSE.md` at repo root — Apache-2.0 Markdown text (`usethis::use_apache_license()`
  output); do NOT ship a plain `LICENSE` file.
- `.Rbuildignore` must reference `^LICENSE\.md$` (not `^LICENSE$`).

## NEWS.md format

Top heading is the new release; each version gets its own `## <Pkg> X.Y.Z (YYYY-MM-DD)`
section. Sections: `Major changes:`, `Minor changes:`, `Bug fixes:`, `License changes:`.
Omit empty sections.

## Version-bump rule

If the pending `Version:` matches what is already published in the drat repo
(`src/contrib/PACKAGES`), bump the patch version before publishing — the drat repo
treats same-version uploads as conflicts. The three commands (`publish`, `deploy`,
`archive`) do not auto-bump; do it manually in `DESCRIPTION` and `NEWS.md`.

## Analogies to Python publish

| Concept | Python | R |
|---|---|---|
| Command | `koopa app python publish` | `koopa app r publish` |
| Module | `koopa/pypi.py` | `koopa/cran.py` |
| Build tool | `uv build` | `R CMD build` + `R CMD INSTALL --build` |
| Package index | PEP 503 HTML at bucket root | drat CRAN-style `PACKAGES*` |
| Insert | hand-rolled index regen | `drat::insertPackage` (R) |
| Sync | `aws s3 sync` (Python) | `aws s3 sync` (Python, via `aws.py`) |
| Version management | bumpver | manual in DESCRIPTION |
| Index URL | `https://python.acidgenomics.com/` | `https://r.acidgenomics.com/` |
