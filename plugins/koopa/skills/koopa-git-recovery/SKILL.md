---
name: koopa-git-recovery
description: >-
  Diagnose and recover from common git branch/state accidents, wrong-branch
  reset, git alias side effects, untracked-file checkout collisions, and stash cleanup.
  Use when a git command moved the wrong branch pointer, a checkout was blocked by
  untracked files, or stash noise is showing in the prompt.
---

# Git Recovery Patterns

## `git reset --hard <ref>` moves the current branch, not the target ref

`git reset --hard <ref>` (and any alias wrapping it, e.g. `git nuke`) resets the
**currently checked-out branch** to `<ref>`. It does NOT switch branches.

**Symptom:** `git nuke develop` while on `feat/foo` leaves `feat/foo` pointing at
a `develop` commit; you are still on `feat/foo`.

**Diagnosis checklist:**
```sh
git reflog -n 8                          # see what actually moved
git rev-parse --short HEAD               # where am I now?
git rev-parse --short origin/feat/foo    # is remote still intact?
git rev-list --count origin/develop..develop   # is local develop stale?
```

**Recovery (no unpushed commits on the mangled branch):**
```sh
git fetch origin
git switch develop                       # tree must be clean first
git branch -f feat/foo origin/feat/foo   # restore pointer from remote
git merge --ff-only origin/develop       # fast-forward if local develop is behind
```

`git branch -f` refuses to move the checked-out branch, always switch off it first.

---

## Checkout blocked by untracked files

```
error: The following untracked working tree files would be overwritten by checkout
```

The files exist untracked in the current tree but are tracked on the target branch.
Git refuses to overwrite them.

**Options (in order of preference):**

1. **Commit them** if they belong to the current branch.
2. **Remove them** if they are stale/auto-generated artifacts:
   ```sh
   git clean -n    # dry run, see what would be removed
   git clean -fd   # remove untracked files and dirs
   ```
3. **Stash them** if you want to keep them temporarily:
   ```sh
   git stash -u    # -u includes untracked files
   git switch develop
   git stash pop
   ```

The `git reset --hard <target-branch>` workaround (as in `git nuke develop`) does
absorb untracked files by resetting the current branch to the target, but it
**moves the current branch pointer**, which is usually not what you want. Prefer
`git clean` or `git stash -u` instead.

---

## Stash noise in the prompt (`[$]` in starship)

Starship's `git_status` module shows `$` when the stash stack is non-empty. The
stash is repo-wide, it shows on every branch regardless of where the stash was
created.

**Clear all stashes when you no longer need them:**
```sh
git stash list    # review first
git stash clear   # drop all stashes
```

**Drop a single stash:**
```sh
git stash drop stash@{0}
```

---

## Quick branch-state orientation

```sh
git reflog -n 8                                        # recent HEAD movements
git log --oneline -5                                   # where is HEAD
git branch -vv                                         # local branches + tracking + ahead/behind
git rev-list --count origin/develop..develop           # local ahead of remote
git rev-list --count develop..origin/develop           # local behind remote
```
