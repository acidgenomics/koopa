---
name: koopa-git-history-surgery
description: >-
  Rewrite git history safely with git filter-repo. Use when removing
  secrets or sensitive files from commits, rewriting author/committer emails
  across history, de-duplicating doubled commits, or any commit-level surgery.
---

# Git History Surgery with git filter-repo

## Removing Sensitive Files from Git History

Use `git filter-repo`, not delete-and-recreate. Deleting the repo loses
settings, branch protections, access controls, and issue/PR history.

```sh
git filter-repo \
    --path path/to/sensitive-file \
    --invert-paths \
    --force
```

`git filter-repo` removes the remote as a safety measure, re-add it after:

```sh
git remote add origin <url>
git push --force --set-upstream origin main
```

Teammates must then re-clone or hard reset:

```sh
git fetch --all && git reset --hard origin/main
```

**Known issue**: `git filter-repo` crashes if any git config value contains a
literal newline (e.g. a multi-line alias). Workaround:

```sh
GIT_CONFIG_NOSYSTEM=1 HOME=/dev/null git filter-repo --path ... --invert-paths --force
```

## Rewriting Commit Identity History

Use `git filter-repo --mailmap` for pure identity rewrites (wrong author/email):

```sh
# mailmap format: canonical <right@email.com> <wrong@email.com>
cat > mailmap << 'EOF'
USER NAME <USER EMAIL> <wrong.name@corp.com>
EOF

GIT_CONFIG_NOSYSTEM=1 HOME=/dev/null git filter-repo --mailmap mailmap --force
git remote add origin <url>
git config --local user.name  "USER NAME"
git config --local user.email "USER EMAIL"
```

**Choose tool based on whether commits are unique:**

- Offending commits have **distinct trees** (real unique work) → use `--mailmap`.
  Filter-repo preserves graph topology and rewrites identity metadata only.
- Offending commits are **duplicates** (history doubled by botched cleanup +
  git pull re-merge) → use a `git commit-tree` replay to de-duplicate.
  Filter-repo cannot collapse duplicate lineages.

**How to check before choosing:**

```sh
# Count distinct trees for bad-email commits: must equal commit count for mailmap to be safe
git log --all --format='%T %ae' | grep 'corp\.com' | awk '{print $1}' | sort -u | wc -l
```

**Verification after mailmap rewrite** (all must pass before force-push):

```sh
# 1. No bad identities remain (must print nothing):
git log --all --format='%ae%n%ce' | grep -iE 'corp\.com'

# 2. Good bots preserved (count should be unchanged):
git log --all --format='%ce' | grep -c 'noreply@github\.com'

# 3. Commit count unchanged:
git rev-list --all --count
```

Always bundle-backup first and keep it until the force-push is confirmed:

```sh
git bundle create backup.bundle --all
```
