# Acid Genomics R Package Development Conventions

Applies to all packages under `~/git/personal/r-<pkgname>` (acidgenomics org).
Reference implementation: pointillism 0.8.0 (2026-06-19).

## Tooling Stack

| Tool | Config | Notes |
|---|---|---|
| formatter | `air.toml` (per-project) | No global config — air walks up from file; must exist at package root |
| linter | `~/.lintr` (global, chezmoi-managed) | No per-project `.lintr` — project file replaces global, never merges |
| docs | `roxygen2 8.0.0` | Single-line `@importFrom` required (see below) |
| check | `AcidDevTools::check()` | Wraps lint + rcmdcheck + BiocCheck |

## `air.toml`

All packages carry this identical 8-line file. Copy from `~/git/personal/r-pipette/air.toml`:

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

Air has **no global config fallback** — per-project `air.toml` is required.

## `~/.lintr` (chezmoi source: `opt/dotfiles/chezmoi/dot_lintr`)

Single global file; no per-project `.lintr` files. Current critical settings:

```r
object_usage_linter = NULL,   # S4 @importFrom symbols cause ~200 false positives
```

DCF format rule: `exclusions:` key must appear on the line **immediately after** the
closing `)` of the `linters_with_defaults(...)` block — no blank line between them.
A blank line starts a new DCF record and the exclusions key is silently dropped.

To change `~/.lintr`: edit `opt/dotfiles/chezmoi/dot_lintr`, then:
```sh
chezmoi apply --source=~/.local/share/koopa/opt/dotfiles/chezmoi ~/.lintr
```

## DESCRIPTION Conventions

```
Config/roxygen2/version: 8.0.0      # NOT RoxygenNote: 7.3.x
Roxygen: list(markdown = TRUE)
Config/testthat/edition: 3
Config/testthat/parallel: true
License: Apache License (>= 2)      # NOT AGPL-3; NOT "| file LICENSE"
```

Run `roxygen2::roxygenise()` last (after all hand-edits) so it regenerates `man/`
and `NAMESPACE` over a clean state.

## roxygen2 8.x — `@importFrom` Format

**Breaking change from 7.x**: each `@importFrom` tag must be a single source line.
Multi-line continuation (`#'` wrapping) is an error.

**But `line_length_linter` fires at 80 chars.** Solution: split into multiple
separate `@importFrom` tags for the same package — one logical group per line:

```r
## OK (one tag per line, each ≤80 chars):
#' @importFrom BiocGenerics as.data.frame cbind counts counts<- do.call lapply
#' @importFrom BiocGenerics normalize organism organism<- sapply

## NOT OK (multi-line continuation — roxygen2 8.x error):
#' @importFrom BiocGenerics as.data.frame cbind counts counts<- do.call lapply
#' normalize organism organism<-

## NOT OK (single line >80 chars — lintr error):
#' @importFrom BiocGenerics as.data.frame cbind counts counts<- do.call lapply normalize organism organism<-
```

Never use `# nolint` on `#'` comment lines — roxygen2 8.x parses `#` and `nolint`
as additional function names to import.

## `object_overwrite_linter` — S4 Internal Variable Names

Common variable names (`df`, `data`, `col`, `norm`, `split`, `which`, `subset`,
`list`, `cumsum`) shadow base R functions and fire `object_overwrite_linter`.

Options (in order of preference):
1. Rename to a non-shadowing name when only 2-3 usages (e.g. `data` → `dat`,
   `list` → `plotList`).
2. `# nolint` at the declaration line when renaming would cascade widely.

Never suppress with `options(warn = -1)` or global `# nolint start` blocks.

## `keyword_quote_linter` — Named List Elements

Quoted names in `list(...)` fire when the name is a valid R symbol:

```r
## BAD (fires linter):
list("geneId" = val, "sampleName" = x)

## GOOD:
list(geneId = val, sampleName = x)

## Exception — names that ARE invalid symbols (e.g. contain dots) must be quoted:
switch(EXPR = x, "FindMarkers" = ..., "FindAllMarkers" = ...)  # strings, not names
```

`switch()` EXPR values ARE strings and should not be quoted per this linter.
Unquote `"FindMarkers"` → `FindMarkers`, etc. in `switch()` calls.

## `setGeneric(name = "PascalCase")` — `object_name_linter` False Positive

`object_name_linter(styles = "camelCase")` fires on the string value passed to
`setGeneric(name = "SeuratMarkers")` because it looks like a PascalCase assignment.
These are S4 generic names (not variables) and cannot be renamed. Use `# nolint`:

```r
setGeneric(
    name = "SeuratMarkers", # nolint
    ...
)
```

## `leftJoin` — Type Coercion Before Join

`AcidPlyr::leftJoin()` enforces strict type matching on `by` columns.
When joining marker DataFrames to annotation tables, coerce `geneId` to `character`
on both sides before calling `leftJoin`:

```r
markers[["geneId"]] <- as.character(mcols(ranges)[["geneId"]])
known[["geneId"]]   <- as.character(known[["geneId"]])
x <- leftJoin(x, known, by = "geneId")
```

## `future::plan()` — Defunct Backends

`"multiprocess"` was removed in future 1.32. Use `"multicore"` when the call is
already gated by `future::supportsMulticore()`:

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

## AcidDevtools::check() — Full Pre-Release Gate

```r
AcidDevTools::check(
    path      = "~/git/personal/r-<pkg>",
    lints     = TRUE,
    urls      = FALSE,
    cran      = FALSE,
    biocCheck = TRUE
)
```

Gate order: lintr → urlchecker (if urls=TRUE) → rcmdcheck → BiocCheck.
Errors on any lint or rcmdcheck ERROR/WARNING. Does NOT error on URL failures.
See `koopa-r-release` for the publish workflow after this passes.
