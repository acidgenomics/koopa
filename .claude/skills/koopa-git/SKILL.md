---
name: koopa-git
description: >-
  koopa git workflow: develop→main PR pattern, merge conflict resolution,
  tag management, and how to avoid rebase hell. Use when dealing with PR
  conflicts, moving tags, or pushing a release branch.
---

# koopa Git Workflow

## Branch model

- `develop`: active development. All work lands here.
- `main`: release snapshots only. Updated exclusively via PR from `develop`.
- Tags (`vX.Y.Z`) sit on `develop` at the **bumpver commit** (or the
  "Prepare release" commit if bumpver ran first, see `koopa-release`).

## Pushing a release

After the CHANGELOG + bumpver commits are on `develop`:

```sh
git push origin develop
git push origin vX.Y.Z         # or --force if re-tagging (see below)
```

Then open (or merge) the `develop`→`main` PR on GitHub.

## Merge conflicts on the develop→main PR

The tag points to a merge commit on `main` (the previous PR), so
`vPREV..HEAD` looks enormous; that's expected, not a real conflict.

The actual conflict is almost always just `CHANGELOG.md` (and occasionally
`pyproject.toml`), because `main` lags behind `develop` by one or more
release cycles. `develop`'s version is always the correct one: it is a
strict superset.

**Fix: merge main into develop with `-X ours`**

```sh
git fetch origin
git merge -X ours origin/main
git push origin develop
```

`-X ours` auto-resolves every conflict by keeping `develop`'s version.
No interactive editor, no rebase, no cherry-pick warnings.

**Never** use `git rebase origin/main` here: the branch history is shared
with the remote and has already been merged into `main` multiple times.
Rebasing causes every previously-merged commit to be "skipped" as a
cherry-pick duplicate, then explodes on the first real conflict.

## Moving a tag after the fact

If bumpver ran before the "Prepare release" commit, the tag sits one commit
behind HEAD. Re-tag and force-push:

```sh
git tag -f vX.Y.Z          # moves tag to current HEAD
git push origin vX.Y.Z --force
```

If the remote already has the tag at the right SHA, `git push` reports
"Everything up-to-date"; that's fine, no action needed.

## Checking tag placement

```sh
git rev-parse vX.Y.Z       # SHA the tag points to
git log --oneline -1        # current HEAD
```

The tag should sit on the bumpver commit (`Bump version to vX.Y.Z.`).

## Always `git fetch` before trusting an `origin/*` ref

`origin/main` and `origin/develop` are local, cached copies of the remote's
last known state at your last fetch, not a live read of GitHub. Comparing
them (`git diff origin/main origin/develop`, `git rev-parse origin/main`)
without a fresh `git fetch origin` first can report a gap that no longer
exists, or miss one that just opened.

Confirmed live: after a real `develop`→`main` merge already happened on
GitHub, `git diff origin/main origin/develop --stat` still showed the old,
pre-merge difference, because the local clone hadn't fetched since before
the merge. `gh pr create` then correctly refused with "No commits between
main and develop"; GitHub's own server-side state was right the whole
time; the local remote-tracking refs were just stale. A plain `git fetch
origin` before re-checking made the diff empty.

Run `git fetch origin` immediately before any check that reasons about
`origin/*` refs, not just once per session. Treat `gh pr create`'s own
refusal as a stronger signal of the true state than a local diff you
haven't just refreshed.

## Escaping a bad rebase

If you accidentally started a rebase, abort immediately:

```sh
git rebase --abort
```

This restores the autostash and puts you back on `develop` at HEAD.
The `[!]` dirty-tree indicator afterward is normal: just the stashed
`todo.org` changes coming back.
