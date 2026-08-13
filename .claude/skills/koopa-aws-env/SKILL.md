---
name: koopa-aws-env
description: >-
  koopa AWS environment configuration — the gitignored <koopa-root>/.env,
  load_dotenv()/aws_account_id()/koopa_s3_bucket() helpers in aws.py, required vars,
  bucket naming, lazy-eval rule. Use when adding an AWS secret, wiring a
  bucket/CloudFront ID, or debugging a missing AWS env var in release tooling.
---

# koopa AWS Environment Configuration

## Purpose

Private AWS identifiers (account ID, S3 bucket names, CloudFront distribution IDs)
are kept out of source code and stored only in `<koopa-root>/.env` (gitignored).
This file documents the pattern, the required variables, and how to extend it.

## `.env` location and loader

- **File:** `<koopa-root>/.env` (i.e. `~/.local/share/koopa/.env` on a typical install)
- **Gitignored:** yes — `.env` is listed in `.gitignore` at the repo root
- **Loader:** `load_dotenv()` in `lang/python/src/koopa/aws.py`
  - Hand-rolled line-by-line parser; no third-party dependency
  - Skips blank lines and `#` comments
  - Splits on the first `=`; strips whitespace from key and value
  - Uses `if key not in os.environ` — real environment variables always win
  - Called lazily (at use time), never at module import time

## Required `.env` variables

```sh
# AWS account
AWS_ACCOUNT_ID=<12-digit account ID>

# CloudFront distribution IDs (set the specific var; generic is the fallback)
AWS_CLOUDFRONT_DISTRIBUTION_ID_R=<id>          # r.acidgenomics.com
AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON=<id>     # python.acidgenomics.com (index + docs)
AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA=<id>      # koopa.acidgenomics.com (Sphinx docs site)
AWS_CLOUDFRONT_DISTRIBUTION_ID=<id>            # generic fallback (optional)
```

## S3 bucket naming convention

All private koopa buckets follow: `<role>-<account-id>-us-east-1-an`

| Role | Domain / purpose |
|---|---|
| `r` | r.acidgenomics.com R package repo |
| `python` | python.acidgenomics.com — PEP 503 index (`/simple/`), docs (`/<name>/`), landing (`/`) |
| `koopa` | koopa.acidgenomics.com Sphinx docs site (`/`) + source tarball mirror (`/src/`, koopa develop mirror-src) + install script (`/install`) |
| `artifacts` | Pre-built binary packages (`binaries/<os_slug>/<arch>/<name>/<version>.tar.gz`) + restricted installers |

## Key helpers (`lang/python/src/koopa/aws.py`)

```python
load_dotenv() -> None
    # Load <koopa-root>/.env into os.environ (no-op if file absent)

aws_account_id() -> str
    # Returns AWS_ACCOUNT_ID from env; raises RuntimeError if unset

koopa_s3_bucket(role: str) -> str
    # Returns "{role}-{account_id}-us-east-1-an"
    # Examples: koopa_s3_bucket("r"), koopa_s3_bucket("artifacts")
```

Always call these **inside functions** (never at module scope) to preserve lazy
evaluation — importing a module must never crash when `.env` is absent.

## CloudFront distribution IDs

Distribution IDs are never hardcoded in source. Each publish module reads its own
env var with a generic fallback:

- `cran.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_R` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`
- `pypi.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`
- `site.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`

Both call `load_dotenv()` (from `koopa.aws`) before reading the env var.

## How to add a new secret

1. Add the value to `<koopa-root>/.env` under a clear `AWS_*` or `KOOPA_*` key.
2. In the consuming function, call `load_dotenv()` (or `aws_account_id()` /
   `koopa_s3_bucket()` which call it internally), then `os.environ.get(...)`.
3. Raise `RuntimeError` with a clear message if the value is absent and required.
4. Never assign at module scope — always inside a function body.

## Failure modes

A machine can retain a stale `[acidgenomics]` stanza in `~/.aws/credentials`
(e.g. left over from a prior builder setup) after its `.env` (and thus
`AWS_ACCOUNT_ID`) has been lost or never provisioned — `.env` is gitignored, so
a fresh clone or re-provision never restores it. Before the fix,
`_has_private_access()` in `install.py` checked only for the credentials
stanza, so such a machine was treated as having private access, attempted a
binary install for any app, and aborted with `AWS_ACCOUNT_ID must be set` even
for apps (like `dotfiles`) that never touch AWS. `_has_private_access()` now
requires **both** the credentials stanza and a resolvable `aws_account_id()`,
emits a one-time `alert_note` when the account ID is missing, and the source
build proceeds normally like any public machine.

`koopa app koopa publish-docs` can fail on the *last* step only: the S3 sync
succeeds (content is live) but the CloudFront invalidation raises
`AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA (or AWS_CLOUDFRONT_DISTRIBUTION_ID) must
be set` if neither var is in `.env`. This leaves the new content uploaded but
still served from cache until an invalidation runs. Add the missing var to
`.env` for next time; to unblock the current publish without it, invalidate
directly with the distribution ID (`aws cloudfront list-distributions
--query 'DistributionList.Items[?Aliases.Items[0]==`koopa.acidgenomics.com`].Id'`)
rather than re-running the whole publish.

A push into the `artifacts` bucket's `binaries/` prefix must run from koopa
installed at `/opt/koopa` — tarballs are archived with absolute paths
(`tar -Pcz`), so a push from any other prefix uploads an object no
`/opt/koopa` host can ever extract. See the "Binary Package Cache" section of
the `koopa-app-registry` skill for the full enforcement list and an audit
recipe for finding an already-poisoned object.

## History

The account ID `REDACTED_AWS_ACCOUNT_ID` and CloudFront ID `REDACTED_CF_DISTRIBUTION_ID` were removed from
source and git history in June 2026 using `git filter-repo --replace-text`. The
`goalie/DESCRIPTION` artefact (accidentally committed working-directory R build output)
was removed in the same pass via `--path goalie/ --invert-paths`.

See `git-history-surgery` skill (user-global) for the filter-repo procedure.
