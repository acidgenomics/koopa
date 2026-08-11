---
name: koopa-dotfiles
description: >-
  Managing the opt/dotfiles standalone git clone — git state, committing changes,
  license/metadata updates, and the app.json pin rollout to hosts. Use when making
  changes to opt/dotfiles/ that need to be committed, when the clone is in a
  detached HEAD state, or when a fix that touches both the koopa repo and
  opt/dotfiles/chezmoi appears to not take effect on a remote host after koopa
  side changes land.
---

# koopa Dotfiles Repo Management

## Repo layout

`opt/dotfiles/` is a **standalone git clone** of `github.com/acidgenomics/dotfiles`,
not a submodule of koopa. It is cloned by `koopa install dotfiles` and pinned at a
specific commit (blobless partial clone with `partialclonefilter = blob:none`).

The chezmoi source tree lives inside it at `opt/dotfiles/chezmoi/`. See skill
`koopa-chezmoi-dotfiles` for editing dotfiles via chezmoi.

## Detached HEAD — always check before committing

`koopa install` pins the clone at a specific commit, leaving it in **detached HEAD**
state. Any `git commit` from a detached HEAD lands on no branch and will be
unreachable after a `git checkout`.

Before committing any change inside `opt/dotfiles/`, always check:

```sh
cd opt/dotfiles
git status         # "(HEAD detached at <sha>)" means detached
git checkout main  # re-attach to main before committing
```

Then commit normally and push to `origin` (`github.com/acidgenomics/dotfiles`).

## License

The repo carries a single top-level `LICENSE` file (no extension). There are no
per-file SPDX headers or package-metadata `license` fields.

In June 2026 the license was switched from AGPL-3.0 to Apache-2.0, matching koopa.
The Apache-2.0 text is the verbatim stock text (APPENDIX placeholders left unfilled);
the README carries the attribution line:

```
Apache-2.0 — Copyright 2016 Acid Genomics LLC — see [LICENSE](LICENSE).
```

To verify no AGPL traces remain: `grep -i "affero\|agpl" opt/dotfiles/LICENSE`
should return nothing.

## Pinned version — a fix touching both repos needs two pushes, and the pin auto-tracks main HEAD

The `dotfiles` app entry in `etc/koopa/app.json` pins `opt/dotfiles/` to an exact
commit SHA (`version` field, e.g. `"d1281d312911bcbb893a333f715fbe2e9aee6e77"`).
`koopa install dotfiles` on any host checks out exactly that SHA — pushing new
commits to `github.com/acidgenomics/dotfiles` main does not change what any host
installs until this pin advances.

**The pin is not hand-edited.** `koopa develop check-app-versions` (run without
`--no-update`) queries `github.com/acidgenomics/dotfiles`'s `main` branch HEAD via
`_check_github_head()` in
[version_check.py](lang/python/src/koopa/version_check.py) and, if it differs
from the pinned SHA, calls `update_app_json()` to rewrite `app.json`'s `version`
and `date` fields and drop any stale `revision` — this is the source of the
`"Update dotfiles"` commits you'll see in `git log -- etc/koopa/app.json`. Do not
manually edit the `dotfiles` entry's `version` field; run the check command
instead, from the koopa repo whose `opt/dotfiles/` clone already has the new
commit pushed.

**A fix that spans both `koopa` and `opt/dotfiles/chezmoi` needs, in order:**
1. Commit + push in `opt/dotfiles` (see detached-HEAD check above).
2. `koopa develop check-app-versions --reset-cache dotfiles` (no `--no-update`) to
   pull the new pin into `app.json`. **`--reset-cache` is not optional here:** the
   version cache has a 24h TTL (per `koopa-app-registry`), so if the check ran
   earlier the same day for any reason, the cached pre-push HEAD masks the commit
   you just pushed until the cache expires — the check reports "up to date" against
   stale data instead of fetching the new SHA.
3. Commit + push that `app.json` change in the koopa repo itself.
4. On every host that needs the fix, **including this one**: `git pull` (koopa
   repo) → `koopa install dotfiles` (re-clones at the new SHA into a new
   `app/dotfiles/<short-sha>/` and relinks `opt/dotfiles/` to it — the version-check
   step above only patches the `app.json` pin, it does not touch the local clone or
   symlink) → `koopa configure user dotfiles` (re-renders).

**Known failure mode:** shipping only the koopa-side half of a fix (e.g. a Python
probe bug) looks fully resolved once it's live, because most such bugs are
one-repo. But if the same investigation also touched a chezmoi template (as the
2026-08 stuck-light-mode fix did — the Python `gdbus` parse bug in `koopa`, plus a
tmux-hook trailing-newline fix in `opt/dotfiles/chezmoi/dot_config/tmux/
tmux.conf.tmpl`), the dotfiles half is invisible until steps 2–4 above happen.
Symptom on the host: `koopa install dotfiles` reports the **old** SHA as already
current, and the expected file never shows up in the `koopa configure user
dotfiles` pending-changes list. Check `git log -1 origin/main` in `opt/dotfiles`
against the `version` pin currently in `app.json` (or just run
`check-app-versions dotfiles` and look for "outdated") to confirm the SHA a fix
landed in has actually been promoted, not just pushed.
