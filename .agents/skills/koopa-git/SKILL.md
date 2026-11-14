---
name: koopa-git
description: >-
  koopa git workflow, develop→main PR pattern, merge conflict resolution,
  tag management, and how to avoid rebase hell. Use when dealing with PR
  conflicts, moving tags, or pushing a release branch.
---

# koopa Git Workflow

## Branch model

- `develop`: active development. All work lands here.
- `main`: release snapshots only. Updated exclusively via PR from `develop`.
- Release tags (`vX.Y.Z`) identify the final tested release commit included
  in `main`, including fixes after the version bump. See `koopa-release` for
  post-merge verification and publication.

## Pushing a release

After release changes are on `develop`, open the `develop`→`main` PR.
After it is merged, use `koopa develop publish-release vX.Y.Z --pr NUMBER`
to verify, tag, push, and publish locally when the user has authorized the
publication; see `koopa-release` for prerequisites and recovery. This is the
only agent push exception: leave commits and branch pushes to the user, and
never force-push, move, or delete tags under it. The form without `--pr` only
publishes the archive. Release preparation alone does not authorize
publication or merging.

## Merge conflicts on the develop→main PR

Depending on the previous tag's placement, `vPREV..HEAD` can look much
larger than the PR diff; that alone is not evidence of a conflict.

The actual conflict is almost always just `CHANGELOG.md` (and occasionally
`pyproject.toml`), because `main` lags behind `develop` by one or more
release cycles. `develop`'s version is always the correct one: it is a
strict superset.

**Fix: the user merges main into develop with `-X ours`**

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

Before creating or pushing a release tag, check both local and remote
references. If an existing tag points elsewhere, stop and investigate; do
not move or force-push a published tag as part of agent release publication.
A published stable archive is immutable, so moving a tag can also make its
archive disagree with GitHub.

## Checking tag placement

Compare the local and remote tag's peeled commit to the verified release
commit, and confirm that commit is in the freshly fetched `origin/main`.
Do not assume the current `develop` HEAD or the bump commit is the release.

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
`todo.md` changes coming back.
