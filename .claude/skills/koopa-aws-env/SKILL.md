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
AWS_CLOUDFRONT_DISTRIBUTION_ID=<id>            # generic fallback (optional)
```

## S3 bucket naming convention

All private koopa buckets follow: `<role>-<account-id>-us-east-1-an`

| Role | Domain / purpose |
|---|---|
| `r` | r.acidgenomics.com R package repo |
| `python` | python.acidgenomics.com — PEP 503 index (`/simple/`), docs (`/<name>/`), landing (`/`) |
| `koopa` | Source tarball mirror (koopa develop mirror-src) |
| `artifacts` | Pre-built binary packages + restricted installers |

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

Both call `load_dotenv()` (from `koopa.aws`) before reading the env var.

## How to add a new secret

1. Add the value to `<koopa-root>/.env` under a clear `AWS_*` or `KOOPA_*` key.
2. In the consuming function, call `load_dotenv()` (or `aws_account_id()` /
   `koopa_s3_bucket()` which call it internally), then `os.environ.get(...)`.
3. Raise `RuntimeError` with a clear message if the value is absent and required.
4. Never assign at module scope — always inside a function body.

## History

The account ID `REDACTED_AWS_ACCOUNT_ID` and CloudFront ID `REDACTED_CF_DISTRIBUTION_ID` were removed from
source and git history in June 2026 using `git filter-repo --replace-text`. The
`goalie/DESCRIPTION` artefact (accidentally committed working-directory R build output)
was removed in the same pass via `--path goalie/ --invert-paths`.

See `git-history-surgery` skill (user-global) for the filter-repo procedure.
