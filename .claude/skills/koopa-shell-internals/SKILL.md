---
name: koopa-shell-internals
description: >
  Internals of koopa shell activation and update recovery. Use when optimizing
  shell startup, editing activation-path functions, caching plugin init output,
  debugging lazy-load wrappers, or fixing update_koopa() merge/rebase recovery.
---

# koopa Shell Internals

## Git Recovery in update_koopa()

`git pull` may use either merge or rebase strategy depending on config and git version.
Handle both interrupted states before attempting to pull:

- **Merge state** (`.git/MERGE_HEAD`): call `git_merge_abort()`.
- **Rebase state** (`.git/rebase-merge` or `.git/rebase-apply`): call `git_rebase_abort()`.

Both are no-ops when no such operation is in progress — call them unconditionally before
every pull. Two-layer fix:

1. **Proactive**: abort any stuck merge/rebase before pulling (clears MERGING state).
2. **Reactive**: if the pull still fails (diverged history), fetch + hard reset to
   `origin/<branch>`.

## Shell Plugin Activation: Lazy Load vs Eager Init

Before caching or optimizing a plugin's init output, check whether it is already
**lazy-loaded** (the real init runs on first use, not at shell startup). Caching the
init output of a lazy-loaded plugin adds complexity with no warm-startup benefit — the
fork does not happen at startup regardless.

**Known lazy-loaded plugins in koopa (do NOT cache their init output):**
- `zoxide` — activated via the `z` alias (`_koopa_activate_zoxide; __zoxide_z`)
- `conda` — activated via the `conda` alias (`_koopa_activate_conda; conda`)

**Eagerly activated at startup (mtime-based caching in `~/.cache/koopa/shell-init/` is appropriate):**
direnv, starship, mcfly, pyenv, rbenv.

Rule: if a plugin is already lazy-loaded, focus on ensuring the lazy wrapper is
fork-free rather than caching the eager path.

## Activation Fork Budget

Every `$(...)` subshell in the activation path costs ~3–5ms on macOS.
Current thresholds: **bash ≤43 forks, zsh ≤39 forks** across activate/, export/,
and macos/ function directories plus the header.

### Patterns banned from activation-path functions

| Do NOT use | Use instead |
|---|---|
| `$(_koopa_bin_prefix)` | `${KOOPA_PREFIX:?}/bin` |
| `$(_koopa_is_macos)` / `$(_koopa_is_linux)` | `[[ "$OSTYPE" == darwin* ]]` |
| `$(_koopa_xdg_config_home)` / `$(_koopa_xdg_data_home)` | `${XDG_CONFIG_HOME:?}` / `${XDG_DATA_HOME:?}` |
| `$(_koopa_shell_name)` | `${KOOPA_SHELL##*/}` |
| `$(_koopa_boolean_nounset)` | `[[ -o nounset ]]` inline |
| `$(_koopa_add_to_path_string_start)` | inline fork-free dedup in `_koopa_add_to_path_start` |

### Patterns banned from activation-path functions (network / blocking I/O)

Any call that touches the network or a slow daemon is a cold-launch hang waiting
to happen — even calls that measure 0ms warm can stall for seconds on a cold
resolver, VPN wake, or idle daemon.

| Do NOT use | Why | Use instead |
|---|---|---|
| `hostname -d` | DNS domain lookup; blocks on cold resolver/VPN | file-based signal or skip |
| `hostname -f` | FQDN lookup; same DNS stall risk | `hostname -s` (local only) |
| `curl`, `wget`, `/dev/tcp` | network I/O | never on activation path |
| `scutil --get`, `networksetup` | may block on network daemon | guard with fast local check first |

**Concrete case (2026-06):** `_koopa_is_aws_ec2` called `hostname -d` to check for
`ec2.internal`. On corporate-managed Macs with VPN search domains this stalled for
seconds on every cold Ghostty launch — and reproduced on EC2 login shells too.
Fix: macOS short-circuit (`[[ "$OSTYPE" == darwin* ]] && return 1`) + drop the
`hostname -d` heuristic entirely, keeping only the local `/usr/bin/ec2metadata`
file-stat.

**Rule:** when editing any `is-*/` or `activate-*/` function, grep the function body for
`hostname`, `curl`, `wget`, `scutil`, `networksetup`, `dig`, `nslookup`. If found,
flag it and replace with a file-stat or env-var check.

### Verification (run before merging any shell changes)

```sh
koopa develop activation-fork-audit --verbose
koopa develop activation-speed-test
koopa develop pytest lang/python/tests/test_cli_develop.py::test_activation_fork_audit_passes
```
