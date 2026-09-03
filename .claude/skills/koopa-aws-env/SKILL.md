---
name: koopa-aws-env
description: >-
  koopa AWS environment configuration — the gitignored <koopa-root>/.env,
  dotenv_value()/aws_account_id()/koopa_s3_bucket() helpers in aws.py, required
  vars, bucket naming, lazy-eval rule, and why KOOPA_BUILDER also lives in this
  file. Use when adding an AWS secret, wiring a bucket/CloudFront ID, or
  debugging a missing AWS env var or a misdetected builder in release tooling.
---

# koopa AWS Environment Configuration

## Purpose

Private AWS identifiers (account ID, S3 bucket names, CloudFront distribution IDs)
are kept out of source code and stored only in `<koopa-root>/.env` (gitignored).
This file documents the pattern, the required variables, and how to extend it.

## `.env` location and loader

- **File:** `<koopa-root>/.env` (i.e. `~/.local/share/koopa/.env` on a typical install)
- **Gitignored:** yes — `.env` is listed in `.gitignore` at the repo root
- **Loader:** `dotenv_value(key)` in `lang/python/src/koopa/aws.py`
  - Hand-rolled line-by-line parser (`_parse_dotenv()`); no third-party dependency
  - Skips blank lines and `#` comments
  - Splits on the first `=`; strips whitespace from key and value
  - Checks `os.environ` first, then falls back to the parsed `.env` dict —
    real environment variables always win
  - **Never writes to `os.environ`.** A prior version (`load_dotenv()`) copied
    every key in `.env` into `os.environ` as a side effect of reading one.
    `_has_private_access()` calls this path on nearly every install, so the
    whole file (account ID, every CloudFront ID, anything else in `.env`) was
    republished into every subprocess koopa spawns that doesn't route through
    `safe_build_env()` — exactly the exposure koopa's own direnv-revert step
    (`revert_direnv_env()` in `koopa.system`) exists to remove. `dotenv_value()`
    returns one value and touches nothing else.
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

# Builder designation (optional — see koopa-app-registry's "KOOPA_BUILDER
# gating" section for what this flag controls)
KOOPA_BUILDER=1

# Public PyPI upload token, read by pypi.py's publish() via dotenv_value().
# Needs an account-scoped token for a brand-new project's first upload; a
# project-scoped token can't create the project it's scoped to.
UV_PUBLISH_TOKEN=<token>
```

`KOOPA_BUILDER` is not an AWS identifier, but `.env` is a valid home for it
precisely because `dotenv_value()` reads `.env` for any key, not only
`AWS_*` ones. `install.py`'s `can_build_binary()` calls it directly. Use
`can_build_binary()` to answer "is this host a builder" — not `info.json`'s
recorded `KOOPA_BUILDER` field (see "Failure modes" below).

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
dotenv_value(key: str) -> str
    # Returns os.environ[key] if set, else the value from <koopa-root>/.env,
    # else "". Never mutates os.environ.

aws_account_id() -> str
    # dotenv_value("AWS_ACCOUNT_ID"); raises RuntimeError if unset

koopa_s3_bucket(role: str) -> str
    # Returns "{role}-{account_id}-us-east-1-an"
    # Examples: koopa_s3_bucket("r"), koopa_s3_bucket("artifacts")
```

Always call these **inside functions** (never at module scope) to preserve lazy
evaluation — importing a module must never crash when `.env` is absent.

## CloudFront distribution IDs

Distribution IDs are never hardcoded in source. Each publish module reads its own
var with a generic fallback, both via `dotenv_value()`:

- `cran.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_R` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`
- `pypi.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_PYTHON` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`
- `site.py` → `AWS_CLOUDFRONT_DISTRIBUTION_ID_KOOPA` → `AWS_CLOUDFRONT_DISTRIBUTION_ID`

## How to add a new secret

1. Add the value to `<koopa-root>/.env` under a clear `AWS_*` or `KOOPA_*` key.
2. In the consuming function, call `dotenv_value("YOUR_KEY")` (or
   `aws_account_id()` / `koopa_s3_bucket()`, which call it internally).
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

A binary miss for an app whose app.json entry has an `installer` key different
from its own name (`python3.10`–`python3.14` → `python`, `openssl3`/`openssl4`
→ `openssl`) used to be fatal instead of falling back to a source build:
`install_app()`'s fallback checked only `has_python_installer(config.name,
...)`, which is `False` for those names, so the raw `aws s3 cp` 404 was
re-raised. Fixed by resolving the same `installer` key both branches already
used for the non-binary path (`_run_python_installer()` in `install.py`).

`install_info.py`'s `_ENVIRON_ALLOWLIST` records `KOOPA_BUILDER` straight from
`os.environ` into a completed build's `info.json`. On a host where the flag
lives only in `.env`, this field reads as absent even though
`can_build_binary()` (via `dotenv_value()`) correctly returns `True` — the
allowlist is an honest snapshot of the process environment, not of every place
a `KOOPA_BUILDER`-consuming function might resolve it from. Don't use
`info.json` to answer "was this a builder"; call `can_build_binary()` (or
inspect `.env` directly).

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
