# Apache-2.0 License File Conventions (Acid Genomics)

Applies to all repos under `~/git/personal/` and `~/.local/share/koopa/`.

## How GitHub detects licenses

GitHub uses the Ruby `licensee` gem. It normalizes the LICENSE file body
(strips markdown, collapses whitespace, normalizes quote characters) and
computes similarity against SPDX canonical texts. Detection requires ≥98% match
— any abridged or *substantively* altered text drops below the threshold and the
repo shows `NOASSERTION` in the sidebar.

**Content is what matters, not filename or cosmetics.** `LICENSE`, `LICENSE.md`,
`LICENSE.txt` are all recognized equally. The normalizer makes these invisible
to detection:

- format (plain text vs markdown headings/emphasis)
- straight `"` vs curly `“”` quotes
- trailing whitespace / extra blank lines

So only *wording* changes (missing clauses, swapped words) break detection.

Verify detection status — this is the ground truth, not the rendered sidebar:
```sh
gh api repos/acidgenomics/<repo> --jq '.license.spdx_id'
# Apache-2.0 = detected; NOASSERTION = not detected
```

Detection runs only on the repo's **default branch**. Pushing the fix to a
non-default branch (e.g. koopa's `develop`) leaves the sidebar unchanged — the
canonical `LICENSE` must reach `main`:
```sh
gh api repos/acidgenomics/<repo> --jq '.default_branch'
```

## Canonical sources by repo type

### Python packages + koopa + dotfiles → `LICENSE` (plain text)

Source: GitHub's own reference copy, guaranteed to match licensee exactly.

```sh
gh api /licenses/apache-2.0 --jq '.body' > LICENSE
```

Verify after writing:
```sh
grep -c 'consequential' LICENSE   # must be 1 (corrupted copies say "exemplary")
```

### R packages → `LICENSE.md` (markdown-formatted)

Source: the usethis bundled template, which is the CRAN-expected format.

```sh
cp "$(Rscript -e 'cat(system.file("templates/license-apache-2.md", package="usethis"))')" LICENSE.md
```

Or locate it directly:
```
/Library/Frameworks/R.framework/Versions/4.6/Resources/site-library/usethis/templates/license-apache-2.md
```

`LICENSE.md` must appear in `.Rbuildignore` (CRAN prohibits bundling standard
license text in the package tarball):
```
^LICENSE\.md$
```

`DESCRIPTION` field: `License: Apache License (>= 2)`

Verify:
```sh
grep -c 'consequential' LICENSE.md   # must be 1
grep 'LICENSE' .Rbuildignore         # must show ^LICENSE\.md$
```

## The corruption that triggered this audit

All plaintext `LICENSE` files across koopa, dotfiles, and all `py-*` packages
once shared an abridged variant (MD5 `7216c64b041f0b8284981ca10dddaf1c`, 193
lines, 10805 bytes). Key missing/altered content vs canonical:

- §8 "Limitation of Liability": said **"exemplary damages"**, canonical says
  **"consequential damages"** — the single fastest check.
- §1 "Contribution" definition: truncated (dropped "any work of authorship,
  including the original version of the Work…").
- §1 "Derivative Works" definition: dropped "whether in Source or Object form".
- Several §4 redistribution clauses were abridged.

The R `LICENSE.md` files used the markdown-reflowed usethis format, which has
canonical text. So **R packages were already detected** (`Apache-2.0`) while
everything else was not (`NOASSERTION`).

Fixed 2026-06-20:

- **9 plaintext repos (real fix):** koopa, dotfiles, all 7 `py-*` — replaced the
  abridged `LICENSE` with `gh api /licenses/apache-2.0`. This is what flips
  `NOASSERTION` → `Apache-2.0`.
- **24 R repos (cosmetic only):** re-copied the installed usethis template into
  `LICENSE.md`. The sole diff was straight-quote → curly-quote typography, which
  licensee normalizes away — detection was already correct, so this commit is
  optional consistency, not a fix. Do not mistake an R `LICENSE.md` working-tree
  diff for a compliance problem; `grep -c consequential` was already 1.

## Scope of repos affected

| Repos | File | Source |
|---|---|---|
| `koopa`, `dotfiles` | `LICENSE` | `gh api /licenses/apache-2.0` |
| `py-acidbase`, `py-acidgenomes`, `py-acidplyr`, `py-cellosaurus`, `py-goalie`, `py-pipette`, `py-syntactic` | `LICENSE` | `gh api /licenses/apache-2.0` |
| all 24 `r-*` | `LICENSE.md` | usethis template |

R packages do NOT have a plain `LICENSE` file — `LICENSE.md` + `.Rbuildignore`
entry is the complete, correct setup.

## Adding a license badge (README)

Dynamic badge — renders "Apache-2.0" once detection is working:
```md
![License: Apache-2.0](https://img.shields.io/github/license/acidgenomics/<repo>)
```

koopa and dotfiles READMEs have this badge on the line after the lifecycle badge
(added 2026-06-20). Python package READMEs do not currently carry a badge.
