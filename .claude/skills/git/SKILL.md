---
name: git
description: >-
  Notable git features and flags introduced in git 2.55 — new builtins
  (history, format-rev, url-parse), checkout -m autostash, config set advice,
  --graph-lane-limit, push to remote groups, --max-count-oldest, Linux fsmonitor.
  Use when reaching for a recent git command/flag, or unsure whether a 2.55 feature
  exists. For koopa's PR/tag/release workflow use koopa-git; for history rewriting
  use git-history-surgery.
---

# git 2.55 Reference

Applies to the git 2.55.0 build installed in koopa (`app/git/2.55.0/`). Every
command and flag here was verified against the installed build.

For the koopa develop→main PR / conflict / tag workflow, use `koopa-git`.
For history rewriting with `git filter-repo`, use `git-history-surgery`.

## Git alias philosophy

Aliases live in `opt/dotfiles/chezmoi/dot_config/git/alias`. The guiding
principle: **an alias earns its keep by saving keystrokes on things you type
constantly. Commands you'd look up once don't belong there.**

Corollaries:
- No cheat-sheet entries — if you need to look it up, look it up.
- No footguns wrapped in convenience — `clean -dfx` nukes gitignored files
  (`.env`, build caches); `stash clear` destroys all stashes silently. Strip
  the dangerous flags or remove the alias.
- One safe force-push alias (`pf = push --force-with-lease`) paired with the
  amend aliases (`u`, `ua`, `um`, `touch`) — never bare `push --force`.
- Hardcoded branch names (`upstream/main`, `origin/main`) belong in project
  config, not a global alias.

## New builtins

### `git history` — single-commit editing without interactive rebase

Replaces the common `git rebase -i HEAD~N` just-to-touch-one-commit pattern:

```sh
git history fixup <commit>    # amend a commit's content
git history reword <commit>   # change a commit's message
git history split <commit>    # break a commit into smaller pieces
```

Shared flags: `--dry-run`, `--update-refs=(branches|head)`,
`--empty=(drop|keep|abort)`. `fixup` additionally takes `--reedit-message`.

### `git format-rev` — pretty-format revisions on demand *(EXPERIMENTAL)*

> **Warning:** This command is experimental. Behavior may change without notice.

Format one revision expression per line, or resolve commit SHAs embedded in
running text:

```sh
# stdin-mode=lines: one rev expr per input line
git log --format="%H" | git format-rev --stdin-mode=lines --format="%an <%ae>"

# stdin-mode=text: replace SHA-looking tokens in free-form text
git format-rev --stdin-mode=text --format="%s" < commit-message.txt
```

### `git url-parse` — expose git's internal URL parser

Extract components from any URL git understands:

```sh
git url-parse https://github.com/org/repo.git
git url-parse -c host https://github.com/org/repo.git   # just the host component
```

Useful for scripting around git remote URLs without fragile sed/awk.

## Changed behavior on existing commands

### `git checkout -m` now auto-stashes

`git checkout -m <branch>` previously gave one shot at resolving conflicts if
local changes overlapped with the branch diff. Now it **auto-stashes first**,
switches, then reapplies. If reapply conflicts, the stash entry is preserved:

```sh
git checkout -m other-branch
# if conflicts after reapply:
# 1. resolve files
# 2. git stash drop   — or clear tree and git stash pop later
```

If local changes don't overlap with the branch diff at all, no stash is created
and the switch is seamless.

### `git config <key>=<value>` gives a helpful error

```sh
git config foo.bar=baz   # was silently wrong; now errors with:
#   hint: Did you mean: git config set foo.bar baz
```

The `set` subcommand form has been the canonical write path since git 2.43;
this nudge makes the typo visible.

### Sideband terminal control sequences disabled by default

Control sequences coming over the sideband from a remote (e.g. `git push/fetch`
progress) are now stripped except for ANSI color escapes. Prevents terminal
emulator glitches from malicious or buggy servers.

### Hooks can run in parallel

Hook scripts defined via the configuration system can be configured to run
concurrently. Useful for slow pre-commit or pre-push hook suites.

## New flags on existing commands

### `--graph-lane-limit=<n>` / `log.graphLanes`

Cap the number of graph lanes shown by `git log --graph`. Lanes over the limit
are replaced with `~`:

```sh
git log --graph --graph-lane-limit=10 --oneline
# or persistently:
git config --global log.graphLanes 10
```

Default `0` = no limit. Negative values are treated as no limit. Fixes
unreadably wide graph output on repos with many long-lived branches.

### `--max-count-oldest=<n>`

Picks the **oldest** N commits in a range (inverse of `--max-count`):

```sh
git log --max-count-oldest=5 main    # show the 5 oldest commits reachable from main
git rev-list --max-count-oldest=3 HEAD
```

Handy for finding the initial commits in a range without reversing the full log.

### `git push <remote-group>`

Push to multiple remotes at once. Define a group in config:

```sh
git config remotes.all-remotes "origin backup"
git push all-remotes main   # pushes to origin then backup, same args each
```

Equivalent to running `git push origin main && git push backup main`. No special
behavior beyond being a shorthand — refspecs, options, and errors behave
identically to individual pushes.

### `git cat-file --batch` inline `mailmap` command

Toggle mailmap use mid-batch without restarting the process:

```sh
echo "mailmap true"  | git cat-file --batch   # enable mailmap for subsequent objects
echo "mailmap false" | git cat-file --batch   # disable
```

## Platform / daemon

### fsmonitor now available on Linux

The fsmonitor daemon (fast `git status` via OS filesystem events) now works on
Linux. Enable it the same way as on macOS/Windows:

```sh
git config core.fsmonitor true
git config core.untrackedCache true
```

Most useful on large repos with many files. Verify it started: `git fsmonitor--daemon status`.

## Notable fixes

**`git fetch --deepen=<n>` on a full clone is now a no-op.** Previously it
truncated the full clone's history to N commits deep — a significant footgun.
Now it correctly does nothing on a non-shallow repo.

**`http.emptyAuth=auto`** now tries Negotiate (Kerberos) before falling back to
manual credential prompts. Previously required explicitly setting
`http.emptyAuth=true` for SSO/Kerberos flows to work without a prompt.
