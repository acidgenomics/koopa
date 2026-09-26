---
name: koopa-bioconda
description: >-
  Procedures for maintaining Acid Genomics R package recipes in
  bioconda-recipes — recipe structure, Apache-2.0 license fields, GitHub
  Contents API PR workflow (never git push, repo is ~700 MB), autobump PR
  supersession, dependency tier ordering for CI, migration-lag dep solve
  failures, PR labeling/merge process via Mergify, and post-merge
  verification. Use when adding or updating an r-<pkg> bioconda recipe,
  triaging bioconda CI failures, or managing PRs against
  bioconda/bioconda-recipes.
---

# bioconda

Procedures for maintaining Acid Genomics R package recipes in
[bioconda-recipes](https://github.com/bioconda/bioconda-recipes).

## Recipe locations

All recipes live at `recipes/r-<pkgname>/meta.yaml` in bioconda-recipes.
Maintainer handles: `@acidgenomics`, `@mjsteinbaugh`.
Fork: `mjsteinbaugh/bioconda-recipes` — all edits go here, PRs target upstream.

## Canonical recipe structure (noarch R package)

```yaml
{% set version = "X.Y.Z" %}
{% set github = "https://github.com/acidgenomics/r-<pkg>" %}

package:
  name: r-<pkg>
  version: "{{ version }}"

source:
  url: "{{ github }}/archive/v{{ version }}.tar.gz"
  sha256: <hex>

build:
  number: 0
  noarch: generic
  run_exports:
    - {{ pin_subpackage('r-<pkg>', max_pin="x.x") }}

requirements:
  host:
    - r-base
    # + all Imports and Depends (with version pins)
    # + Suggests (bioconda convention: include in both host and run)
  run:
    - r-base
    # (mirror host exactly)

test:
  commands:
    - $R -e "library('<PkgName>')"

about:
  home: https://r.acidgenomics.com/packages/<pkg>/
  dev_url: "{{ github }}"
  license: Apache-2.0
  license_file: LICENSE.md
  license_family: APACHE
  summary: <one-line description from DESCRIPTION Title:>

extra:
  recipe-maintainers:
    - acidgenomics
    - mjsteinbaugh
```

## ALL packages are Apache-2.0 (as of 2026-06-20)

Every recipe must use:
```yaml
license: Apache-2.0
license_file: LICENSE.md
license_family: APACHE
```

Error on `license: AGPL-3` or `license_file: LICENSE` (no .md) — that is stale.
All 24 packages were relicensed in the 2026-06-20 sweep. The `LICENSE.md` file
(Apache-2.0 markdown from `usethis::use_apache_license()`) is present in every
release tarball ≥ the versions in the current recipes.

Verify before writing the recipe:
```sh
curl -fsSL https://github.com/acidgenomics/r-<pkg>/archive/v<ver>.tar.gz \
  | tar tz | awk -F/ '{print $2}' | grep -iE '^(LICENSE|LICENCE)' | sort -u
# Expected: LICENSE.md
```

## GitHub Contents API workflow (NEVER git push to bioconda-recipes)

The repo is ~700 MB — never clone or push. Use the GitHub Contents API.
All PRs must target `master` as base.

```sh
# 1. Get master SHA from upstream
MASTER_SHA=$(gh api repos/bioconda/bioconda-recipes/git/ref/heads/master \
  --jq '.object.sha')

# 2. Get current file SHA for existing recipes (needed for PUT)
FILE_SHA=$(gh api \
  "repos/bioconda/bioconda-recipes/contents/recipes/r-<pkg>/meta.yaml?ref=master" \
  --jq '.sha')

# 3. Create branch on fork
gh api repos/mjsteinbaugh/bioconda-recipes/git/refs \
  --method POST \
  --field "ref=refs/heads/<branch>" \
  --field "sha=${MASTER_SHA}"

# 4. Write the meta.yaml (stdin → base64)
CONTENT=$(python3 -c \
  "import base64,sys; print(base64.b64encode(sys.stdin.buffer.read()).decode())" \
  < meta.yaml)

# 5a. Update existing recipe (PUT with sha)
gh api repos/mjsteinbaugh/bioconda-recipes/contents/recipes/r-<pkg>/meta.yaml \
  --method PUT \
  --field "message=Update r-<pkg> to <ver>" \
  --field "content=${CONTENT}" \
  --field "sha=${FILE_SHA}" \
  --field "branch=<branch>"

# 5b. Create new recipe (PUT without sha — file doesn't exist yet)
gh api repos/mjsteinbaugh/bioconda-recipes/contents/recipes/r-<pkg>/meta.yaml \
  --method PUT \
  --field "message=Add r-<pkg> <ver>" \
  --field "content=${CONTENT}" \
  --field "branch=<branch>"

# 6. Open PR — always --base master
gh pr create \
  --repo bioconda/bioconda-recipes \
  --head "mjsteinbaugh:<branch>" \
  --base master \
  --title "Update r-<pkg> to <ver>" \
  --body "- Version <old> → <ver>\n- License: AGPL-3 → Apache-2.0\n- license_file: LICENSE → LICENSE.md"
```

**Branch naming:** `update-r-<pkg>-<ver>` for updates, `add-r-<pkg>-<ver>` for new recipes.

## Autobump PRs from the bioconda bot

The bot opens `bump/r_<pkgname>` PRs on new upstream tags. These only update
`version` and `sha256` — they do NOT fix license fields.

**Always supersede autobump PRs** with a fresh PR that also fixes:
- `license: Apache-2.0`
- `license_file: LICENSE.md`
- `license_family: APACHE`
- Updated dep version pins

```sh
# Find open autobump PRs for a package
gh pr list --repo bioconda/bioconda-recipes --state open \
  --search "r-<pkg> in:title" --json number,title,headRefName

# Close superseded autobump PR
gh pr close <number> --repo bioconda/bioconda-recipes \
  --comment "Superseded by #<new-pr> which also fixes license AGPL-3 → Apache-2.0 and license_file → LICENSE.md"
```

**Do NOT base your PR on the bot's bump branch** — bioconda lint CI only fetches
`origin/master` and will fail with:
```
fatal: Not a valid object name origin/bump/r_<pkg>
```
Always branch from `master` SHA and use `--base master`.

## Computing sha256

```sh
curl -fsSL https://github.com/acidgenomics/r-<pkg>/archive/v<ver>.tar.gz \
  | sha256sum | cut -d' ' -f1
```

Note: GitHub archive tarballs differ from CRAN-style tarballs in `src/contrib/`.
Never use an S3-derived checksum in a bioconda recipe.

## Dependency order for CI (must merge in tiers)

Bioconda CI must solve deps from already-built packages. Each tier's builds must
be live in the channel before the next tier's CI can pass.

```
Tier 1: r-goalie, r-acidgenerics, r-acidcli, r-syntactic  (no acid deps)
Tier 2: r-acidbase, r-acidroxygen, r-acidtest, r-acidmarkdown
Tier 3: r-acidplyr, r-pipette
Tier 4: r-acidexperiment, r-acidgenomes
Tier 5: r-acidsinglecell, r-basejump
Tier 6: r-acidplots, r-deseqanalysis, r-acidgsea, r-chromium, r-pointillism
Tier 7: r-cellosaurus, r-eggnog, r-panther, r-wormbase
```

## Current recipe inventory (as of 2026-06-20 sweep)

24 active packages; all Apache-2.0 in PRs #66513–#66535.

**New recipes added in sweep** (previously absent from bioconda):
- r-acidroxygen 0.3.3 — PR #66516
- r-acidtest 0.9.2 — PR #66520
- r-pointillism 0.8.0 — PR #66529

**r-aciddevtools**: intentionally omitted (dev-only package; CI would need many
extra Suggests installed). Add later if desired.

## Global r-base pin

```sh
curl -fsSL https://raw.githubusercontent.com/bioconda/bioconda-utils/master/bioconda_utils/bioconda_utils-conda_build_config.yaml \
  | grep -A1 "r_base:"
```

Current: `4.5.*`. All `noarch: generic` recipes rebuild automatically against the
current pin — no recipe-side `r-base` version pin needed.

### Dep solve failures (migration lag)

When CI fails with `ExplainedDependencyNeedsBuildingError`, the global pin has
advanced but upstream deps haven't been rebuilt yet. Fix: bump `build: number`
by 1 to trigger a rebuild. No other changes needed.

```sh
# Check which r-base a dep was built against
curl -fsSL https://api.anaconda.org/package/bioconda/r-<dep> \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
for f in sorted(d['files'], key=lambda x: x.get('upload_time',''))[-4:]:
    print(f['version'], f['attrs'].get('build'))
"
# Build string prefix: r43=4.3, r44=4.4, r45=4.5
```

## PR lifecycle and labeling

### When to add "please review & merge"

Only label a PR when **all CI checks are green**. Check before labeling:

```sh
gh pr list --repo bioconda/bioconda-recipes --state open \
  --author mjsteinbaugh \
  --json number,title,labels,statusCheckRollup \
  --jq '.[] | {
    n: .number,
    title: .title,
    labels: [.labels[].name],
    ci: (if (.statusCheckRollup | length) == 0 then "pending"
         elif (.statusCheckRollup | all(.conclusion == "SUCCESS" or .conclusion == "NEUTRAL")) then "ALL_GREEN"
         elif (.statusCheckRollup | any(.conclusion == "FAILURE")) then "FAILING"
         else "in_progress" end)
  } | "\(.n) [\(.ci)] \(.labels | join(",")) — \(.title)"' | sort -n
```

Label only `ALL_GREEN` PRs:
```sh
gh pr edit <number> --repo bioconda/bioconda-recipes \
  --add-label "please review & merge"
```

### Migration lag — most CI failures are not recipe bugs

When Tier 1 PRs (goalie, acidgenerics) are FAILING, all downstream tiers will
also fail with `Unsatisfiable dependencies` — they can't install the in-flight
Tier 1 packages because the r45 binaries don't exist in the channel yet.

**Do not attempt to fix** these downstream failures. They self-resolve once the
Tier 1 PRs merge and bioconda CI builds their r45 binaries (~10–30 min). Then
re-check CI on Tier 2, label green ones, wait for those to merge, and so on.

The failure message looks like:
```
Unsatisfiable dependencies for platform linux-64:
{MatchSpec("r-goalie>=0.7.0"), MatchSpec("r-base[version='>=4.5']")}
r-goalie [0.7.8|0.7.9] would require r-base >=4.4,<4.5.0a0
```
This means r-goalie doesn't have an r45 build yet — wait for Tier 1 to land.

### Closing stale/duplicate PRs

Close only PRs **older than 1 week** that are superseded or stale:
```sh
# List open PRs with creation dates
gh pr list --repo bioconda/bioconda-recipes --state open \
  --author mjsteinbaugh \
  --json number,title,createdAt \
  --jq '.[] | "\(.number) \(.createdAt[0:10]) \(.title)"' | sort -n

# Close a stale PR
gh pr close <number> --repo bioconda/bioconda-recipes \
  --comment "Superseded by #<new-pr>"
```

Never close today's active sweep PRs — they are waiting for tier-ordered CI.

## Merge process

bioconda uses **Mergify** — a human maintainer from `bioconda/bioconda-contrib`
must approve the PR, then Mergify auto-merges it into the queue.

**BiocondaBot does NOT approve PRs.** Requesting review from BiocondaBot is
harmless bookkeeping but won't unblock the merge.

Correct workflow once CI is green:
1. Add label "please review & merge"
2. Wait for a bioconda maintainer to approve (typically 1–7 days)
3. Mergify queues and merges automatically after approval

```sh
# Add label (do this; don't ping maintainers directly)
gh pr edit <number> --repo bioconda/bioconda-recipes \
  --add-label "please review & merge"
```

Check merge status:
```sh
gh pr view <number> --repo bioconda/bioconda-recipes \
  --json mergeStateStatus,statusCheckRollup \
  --jq '{mergeable: .mergeStateStatus, checks: [.statusCheckRollup[] | {name: .name, conclusion: .conclusion}]}'
```
`mergeStateStatus: BLOCKED` with all green CI = waiting for maintainer approval. Normal.

## Verification after merge

```sh
# Confirm build published (~10-30 min after merge)
curl -fsSL https://api.anaconda.org/package/bioconda/r-<pkg> \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
for f in sorted(d['files'], key=lambda x: x.get('upload_time',''))[-3:]:
    print(f['version'], f['attrs'].get('build','?'))
"
# Expect latest version with r45* build string

# Dry-run install to confirm dep solve
conda create -n test --dry-run -c bioconda -c conda-forge r-<pkg>=<ver>
```

## Checking existing recipe content

Because bioconda-recipes is not cloned locally, always read via GitHub API:

```sh
gh api "repos/bioconda/bioconda-recipes/contents/recipes/r-<pkg>/meta.yaml?ref=master" \
  --jq '.content' | base64 --decode
```

To check the repo has a recipe at all:
```sh
gh api "repos/bioconda/bioconda-recipes/contents/recipes/r-<pkg>" \
  --jq 'if type=="array" then "EXISTS" else .message end' 2>/dev/null \
  || echo "MISSING"
```
Note: `--jq '.type'` returns empty for directories (arrays) — use the above form.
