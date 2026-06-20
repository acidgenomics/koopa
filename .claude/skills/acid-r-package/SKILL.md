# Acid Genomics R Package Development Conventions

Applies to all packages under `~/git/personal/r-<pkgname>` (acidgenomics org).
Reference implementation: pointillism 0.8.0 (2026-06-20).

## Tooling Stack

| Tool | Config | Notes |
|---|---|---|
| formatter | `air.toml` (per-project) | No global config — air walks up from file; must exist at package root |
| linter | `~/.lintr` (global, chezmoi-managed) | No per-project `.lintr` — project file **replaces** global, never merges |
| docs | `roxygen2 8.0.0` | Single-line `@importFrom` required (see below) |
| check | `AcidDevTools::check()` | Wraps lint + rcmdcheck + BiocCheck |

## `air.toml`

All packages carry this identical 8-line file. The canonical source is
`~/git/personal/r-pipette/air.toml`. Copy verbatim — do not vary any field:

```toml
[format]
default-exclude = false
exclude = []
indent-style = "space"
indent-width = 4
line-ending = "lf"
line-width = 80
persistent-line-breaks = true
```

Air has **no global config fallback** — per-project `air.toml` is required and
must be **git-tracked** (not gitignored). Untracked `air.toml` is invisible to
fresh clones and `koopa app r publish`.

## `~/.lintr` (chezmoi source: `opt/dotfiles/chezmoi/dot_lintr`)

Single global file; **no per-project `.lintr` files** — any local `.lintr` in a
package directory silently *replaces* the global rather than merging. Remove
with `git rm -f .lintr` on all packages.

To change `~/.lintr`: edit `opt/dotfiles/chezmoi/dot_lintr`, then:
```sh
chezmoi apply --source=~/.local/share/koopa/opt/dotfiles/chezmoi ~/.lintr
```

### Current critical settings (2026-06-19)

```r
# Disabled — S4 @importFrom symbols cause ~200 false positives:
object_usage_linter = NULL,

# NOT in the config (removed — S4 method args shadow base exports):
# object_overwrite_linter  ← opt-in linter, do NOT add it

# NOT in the config (removed — S4 class name quoting is required):
# keyword_quote_linter  ← produces ~100 false positives in S4 code

# Object naming: allow camelCase, CamelCase, dotted.case, and as.* coerce generics:
object_name_linter(
    styles = c("camelCase", "CamelCase", "dotted.case"),
    regexes = c("^as\\.")   # S4 coerce generics (e.g. as.DataFrame)
),

# Complexity limit bumped from default 15 to 45:
cyclocomp_linter(complexity_limit = 45L),
```

### DCF format rule

`exclusions:` key must appear on the line **immediately after** the closing `)`
of the `linters_with_defaults(...)` block — no blank line between them. A blank
line starts a new DCF record and the exclusions key is silently dropped.

### lintr parser crashes on Unicode-escaped named vector keys

lintr 3.3 crashes (`subscript out of bounds`) when parsing files containing
`"\uXXXX" = value` syntax in named vector literals. This is a lintr bug.

**Fix**: restructure using `setNames()` with separate `object` and `nm` args,
using actual UTF-8 characters in `nm` — or namespace with `base::setNames()`.

```r
## BAD (crashes lintr 3.3):
myMap <- c("Α" = "Alpha", "Β" = "Beta")

## GOOD (lintr-safe):
myMap <- setNames(
    object = c("Alpha", "Beta"),
    nm     = c("Α", "Β")           # actual UTF-8, not \uXXXX escapes
)
```

Note: `setNames` is in base R and requires no `@importFrom`. Do NOT write
`@importFrom base setNames` — `base` does not export `setNames` in the
`@importFrom` sense and roxygen2 will warn.

## `.gitignore` Convention

**Per-package `.gitignore` should be minimal.** The global
`~/.config/git/ignore` (chezmoi-managed) covers: `.RData`, `.Rcheck`,
`.Rhistory`, `.Rproj.user`, `doc/`, `docs/`, `tests/testthat/_problems/`.

Standard per-package `.gitignore`:
```
# This file intentionally minimal — see ~/.config/git/ignore for global patterns.
```

**Exception — packages with committed test data** (e.g. r-acidtest):
```
# This file intentionally minimal — see ~/.config/git/ignore for global patterns.
!data/
!data/*.rda
!data-raw/
```

Do NOT include `.RData`, `.Rcheck`, `.Rhistory`, `.Rproj.user`, or `docs/` in
per-package `.gitignore` — they are in the global.

## `DESCRIPTION` Conventions

```
Config/roxygen2/version: 8.0.0      # NOT RoxygenNote: 7.3.x
Roxygen: list(markdown = TRUE)
Config/testthat/edition: 3
Config/testthat/parallel: true
License: Apache License (>= 2)      # NOT AGPL-3; NOT "| file LICENSE"
```

Run `devtools::document()` last (after all hand-edits) so it regenerates `man/`
and `NAMESPACE` over a clean state.

## License Files

Apache-licensed packages use `LICENSE.md` (markdown, from
`usethis::use_apache_license()`) — **not** a plain `LICENSE` file.

In `.Rbuildignore`: `^LICENSE\.md$` (not `^LICENSE$`).

The `koopa-r-release` skill covers the full relicensing procedure.

## README Canonical Format

Header: line 3 must have both badges in this order — bioconda first, lifecycle
second. Use `https://` in all badge links; no `?style=flat`:

```markdown
[![Install with Bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg)](https://bioconda.github.io/recipes/r-<pkg>/README.html) ![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)
```

Conda install block (after R install block):
```markdown
### [Conda][] method

Configure [Conda][] to use the [Bioconda][] channels.

```sh
# Don't install recipe into base environment.
name='r-<pkg>'
conda create --name="$name" "$name"
conda activate "$name"
R
```
```

Link refs (before License section):
```markdown
[bioconda]: https://bioconda.github.io/
[conda]: https://docs.conda.io/
```

License section (always last):
```markdown
## License

Apache-2.0 — Copyright <YEAR> Acid Genomics LLC — see [LICENSE.md](LICENSE.md).
```

**Copyright year** = year of first git commit:
```sh
git log --all --reverse --format="%ad" --date=format:"%Y" | head -1
```

## roxygen2 8.x — `@importFrom` Format

**Breaking change from 7.x**: each `@importFrom` tag must be a single source
line. Multi-line continuation (`#'` wrapping) is an error.

**But `line_length_linter` fires at 80 chars.** Solution: split into multiple
separate `@importFrom` tags for the same package — one logical group per line:

```r
## OK (one tag per line, each ≤80 chars):
#' @importFrom BiocGenerics as.data.frame cbind counts counts<- do.call lapply
#' @importFrom BiocGenerics normalize organism organism<- sapply

## NOT OK (multi-line continuation — roxygen2 8.x error):
#' @importFrom BiocGenerics as.data.frame cbind counts counts<- do.call lapply
#' normalize organism organism<-
```

Never use `# nolint` on `#'` comment lines — roxygen2 8.x parses `#` and
`nolint` as additional function names to import.

## `setGeneric(name = "PascalCase")` — `object_name_linter` False Positive

`object_name_linter` fires on the string value passed to
`setGeneric(name = "SeuratMarkers")` because it looks like a PascalCase
variable. These are S4 generic names and cannot be renamed. Suppress with
`# nolint` on the `name =` line only:

```r
setGeneric(
    name = "SeuratMarkers", # nolint
    ...
)
```

## S4 Method Argument Order — `function_argument_linter`

`function_argument_linter` requires arguments without defaults to come before
arguments with defaults. For S4 method dispatchers that use `formals()` to set
defaults after the function definition, give the argument an explicit sentinel
default in the signature to satisfy lintr:

```r
## BAD — lintr sees method as having required arg after optional:
`correlation,matrix,missing` <- function(x, y = NULL, method) { ... }
formals(`correlation,matrix,missing`)[["method"]] <- .method

## GOOD — explicit default satisfies lintr; formals() still overrides at load:
`correlation,matrix,missing` <- function(x, y = NULL, method = .method) { ... }
formals(`correlation,matrix,missing`)[["method"]] <- .method
```

## AcidGenomes API Changes (≥ 0.8.x)

`makeTxToGeneFromEnsembl()` was removed. Build a `TxToGene` from Ensembl with:

```r
gr <- AcidGenomes::makeGRangesFromEnsembl(
    organism    = "Homo sapiens",
    level       = "transcripts",
    genomeBuild = "GRCh38",
    release     = 87L,
    ignoreVersion = TRUE
)
tx2gene <- AcidGenomes::TxToGene(gr)
```

## `AcidDevTools::check()` — Full Pre-Release Gate

```r
AcidDevTools::check(
    path      = "~/git/personal/r-<pkg>",
    lints     = TRUE,
    urls      = FALSE,
    cran      = FALSE,
    biocCheck = TRUE
)
```

Gate order: dependency check → lintr → urlchecker (urls=TRUE only) →
rcmdcheck → BiocCheck (when biocViews present).

**Always run from a temp directory** to prevent `*.Rcheck/` from being created
in your current working directory:

```r
old <- setwd(tempdir())
on.exit(setwd(old))
AcidDevTools::check(path = path.expand("~/git/personal/r-<pkg>"), ...)
```

**`check()` fails if any Suggests package is missing**, even before running
lints. Install all Suggests before running the gate.

**Parallel test failures under rcmdcheck**: `Config/testthat/parallel: true`
can crash in rcmdcheck's subprocess on macOS (fork resource limits). Run
`TESTTHAT_PARALLEL=false` as an env override — keep the DESCRIPTION setting as-is:

```r
Sys.setenv(TESTTHAT_PARALLEL = "false")
AcidDevTools::check(...)
```

**`valid()` test requires internet**: `AcidDevTools::valid()` calls
`utils::old.packages()` which needs network. Guard with `skip_if_not(goalie::hasInternet())`.

## `keyword_quote_linter` — Named List Elements

This linter was **removed from `~/.lintr`** due to pervasive S4 false
positives (S4 class definitions require quoted strings in `contains`, `slots`,
`prototype` — lintr cannot distinguish these from cosmetic quoting). The note
below is for reference only, in case it is re-enabled:

Quoted names in `list(...)` fire when the name is a valid R symbol:

```r
list("geneId" = val)    # BAD — fires linter
list(geneId = val)      # GOOD
```

Exception: `switch()` EXPR values are strings and must stay quoted.

## `leftJoin` — Type Coercion Before Join

`AcidPlyr::leftJoin()` enforces strict type matching on `by` columns. Coerce
`geneId` to `character` on both sides:

```r
markers[["geneId"]] <- as.character(mcols(ranges)[["geneId"]])
known[["geneId"]]   <- as.character(known[["geneId"]])
x <- leftJoin(x, known, by = "geneId")
```

## `future::plan()` — Defunct Backends

`"multiprocess"` was removed in future 1.32. Use `"multicore"`:

```r
if (isTRUE(future::supportsMulticore()) && !is.null(workers)) {
    future::plan("multicore", workers = workers)
}
```

## Running Tests

Always set locale to avoid S4 method dispatch encoding warnings:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
TESTTHAT_PARALLEL=false \
  R -q -e 'devtools::load_all("."); testthat::test_dir("tests/testthat")'
```

`Config/testthat/parallel: true` stays in DESCRIPTION — `TESTTHAT_PARALLEL=false`
is a runner-only override for debuggable serial output.

## `@importFrom base` — Do Not Use

`base` package functions (`setNames`, `inherits`, `which`, etc.) are always
available in R without explicit import. **Never write `@importFrom base <fn>`**:
- roxygen2 warns: "Excluding unknown export from base: `setNames`"
- The function is unavailable to `@importFrom` regardless

Use the function unqualified. If `namespace_linter` flags it incorrectly, that
is a lintr false positive — add `# nolint` to that specific line.

## Version Bump Rule

If a package's `Version:` in DESCRIPTION matches what's already in
`src/contrib/PACKAGES` on S3, bump the patch before publishing — S3 overwrites
but the PACKAGES index must show a new version to be useful.

README, `.gitignore`, and `air.toml` changes do **not** require a version bump
or `koopa app r publish` — documentation-only PRs can be merged without
republishing to S3.

See `koopa-r-release` for the complete publish workflow.
