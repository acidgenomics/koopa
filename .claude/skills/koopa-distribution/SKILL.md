---
name: koopa-distribution
description: >-
  koopa's install/distribution mechanics outside the default `curl | sh` path —
  pinned (non-git) release tree semantics, `git archive`/`export-ignore`
  behavior, and why packaging koopa through conda-forge or another package
  manager doesn't fit. Use when working on the release tarball, restricted-
  network/offline install docs, `.gitattributes`, or reasoning about whether a
  packaged/pinned koopa install can still manage apps or self-update.
---

# koopa Distribution

## A pinned (non-git) tree already fully supports app management

`_require_git_managed_install()` in `lang/python/src/koopa/cli_main.py` gates
on `lang/python/src` existing in the koopa prefix, **not** on `.git` being
present. A tarball extraction (no `.git` dir at all) passes this check and can
run `install`/`uninstall`/`configure` normally.

`update_koopa()` in `lang/python/src/koopa/install.py` calls `is_git_repo()`
(a plain `.git`-directory check in `git.py`). On a pinned tree this is False,
so it prints `alert_note("Pinned release detected at '<prefix>'.")` and
returns cleanly — it never attempts `git pull`. This is deliberate, existing
behavior, not something that needs new code to support restricted-network
distribution.

Verified end-to-end (extract `git archive HEAD` to a scratch dir, point
`KOOPA_PREFIX` at it): `koopa update`, `koopa list`, and `koopa install --help`
all work correctly against a pinned tree with zero apps installed.

## Why conda-forge (or any package manager) doesn't fit

koopa self-manages its own prefix: it writes `app/`, creates ~450 `bin/`
symlinks, and self-updates via `git pull`. That conflicts structurally with a
package manager's externally-managed, relocatable prefix (`conda update`
would clobber it). The only workaround — a "seed" package whose sole job is
to copy its payload out to `~/.local/share/koopa` — creates a silent
divergence bug: `conda update koopa` refreshes the staged copy inside
`$CONDA_PREFIX` while the live extracted tree is untouched, so the user
believes they updated and didn't. A draft `conda-recipe/` (recipe.yaml +
build.sh) existed for a while shipping a read-only Python-package subset (no
`activate.sh`, no `lang/`) and was removed rather than fixed — the pinned-
tarball path below is the actual fit for "install koopa from a reviewed,
pinned artifact on a restricted network."

## `git archive` reads `.gitattributes` from the committed tree

`export-ignore` rules in `.gitattributes` exclude paths from `git archive`
output (which is what GitHub's codeload tag tarballs use). Plain
`git archive HEAD` resolves attributes from the **committed** tree, not the
working tree — an uncommitted `.gitattributes` edit has no effect on it.

To test an uncommitted change, use `--worktree-attributes`:

```sh
git archive --format=tar --worktree-attributes HEAD | tar -t \
  | grep -cE '^\.claude/|^\.idea/|^CLAUDE\.md|^AGENTS\.md|^\.github/'
```

After committing, re-run the same check **without** `--worktree-attributes`
to confirm the committed rules take effect the way GitHub's codeload will see
them.

## Testing activation of an extracted/pinned tree

Non-interactive shells skip activation entirely by default (see
`koopa-shell-internals` for the full opt-in story). To exercise a pinned
tree's `activate.sh` in a script or test, force it the same way the installer
does:

```sh
env -i HOME="$scratch" KOOPA_FORCE=1 sh -c \
  '. "${scratch}/koopa/activate.sh"; echo "$KOOPA_PREFIX"'
```

Without `KOOPA_FORCE=1` this silently no-ops (exit 0, empty output) — a false
pass, not a failure you'll notice.

## Bootstrap Python has no restricted-network awareness

`bin/koopa` requires `/usr/bin/python3` to exactly match `.python-version`
(currently `3.12`); anything else (including a newer or older system Python)
falls through to running `bootstrap.sh`. `bootstrap.sh` downloads a Python
build directly from `python.org` or `koopa.acidgenomics.com/src` — it does
not consult `etc/koopa/vendor.json` or any mirror config at all. On a
`pull_priority: "vendor_only"` network this download fails outright. The only
workaround today is ensuring a matching system Python 3.12 is already at
`/usr/bin/python3` before koopa's first invocation; there's no way to route
the bootstrap step itself through an internal mirror.
