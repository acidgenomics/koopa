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

## Activation Change Ordering: cache-functions Before Shell Reload

When a change touches **both** a `functions/activate/*.sh` source file **and** a
call site in `lang/bash/include/header.sh` (or the zsh/sh equivalents), you must
run `koopa develop cache-functions` **before** reloading the shell.

`header.sh` calls the function by name. The function body is loaded from the
generated bundle (`lang/bash/include/functions.sh`), not from the source file
directly. If the shell reloads before the bundle is regenerated, `header.sh`
references a name that isn't in the bundle yet → `command not found` at activation.

**Safe sequence:**
1. Write the new `functions/activate/*.sh` file.
2. Add the call site to `header.sh`.
3. Run `koopa develop cache-functions`.
4. **Then** reload the shell.

**Unsafe:** steps 3 and 4 swapped. The shell reload in step 4 will fail with
`_koopa_activate_<new_function>: command not found`.

Same rule applies to any new function referenced in `header.sh` regardless of
source directory (`functions/core/`, `functions/activate/`, etc.). The bundle is
the runtime; the source tree is the authoring surface.

## direnv Must Capture Its Baseline Last

### How `_koopa_activate_direnv` works (two-step)

1. **Hook sourcing** (order-independent): caches and sources `direnv hook <shell>`, which
   installs a precmd/chpwd hook. This step is safe at any activation position.
2. **`eval "$(direnv export <shell>)"`** (order-critical): this fires immediately at
   activation time. If the shell is already inside a directory with an `.envrc` (e.g. the
   koopa repo's `.envrc` which activates `.venv`), direnv loads the `.envrc` **and records the
   current PATH as its restore baseline** — the snapshot it will revert to on
   `direnv: unloading`.

### The invariant

**`_koopa_activate_direnv` must be the last PATH-mutating step in activation.**

If it runs *before* any `_koopa_add_to_path_start` calls, the baseline is frozen at a
mid-activation PATH where `koopa/bin` precedes `/usr/local/bin`. On `direnv: unloading` the
PATH reverts to that snapshot, floating `koopa/bin` ahead of `/usr/local/bin` and shadowing
system tools.

Correct position in every shell header: **after the final `_koopa_add_to_path_start` block**
(the `/usr/local/bin` / `~/.local/bin` block), just before the aliases/today-bucket block.

### Failure signature

- Shell is launched *inside* a directory with an `.envrc`
- Navigate away → `direnv: unloading` is printed
- `which R` (or `whence -p R`, `which python`, etc.) resolves to a **koopa-managed** binary
  rather than the expected system tool

### Verification

```sh
# Should print /usr/local/bin/R (was koopa/bin/R before fix)
zsh -lic 'cd ~/.local/share/koopa; cd /tmp; whence -p R'

# Should still print /usr/local/bin/R (regression check)
zsh -lic 'cd /tmp; cd ~/.local/share/koopa; cd /tmp; whence -p R'

# PATH head — /usr/local/bin must precede koopa/bin after unload
zsh -lic 'cd ~/.local/share/koopa; cd /tmp; printf "%s\n" "${(@s/:/)PATH}" | head -5'
```

### Affected shells / exemptions

All shells with a `_koopa_activate_direnv` call are subject to this ordering constraint:
bash, zsh, fish, nushell, powershell. **elvish** has no direnv activation — exempt.

### Verification (run before merging any shell changes)

```sh
koopa develop activation-fork-audit --verbose
koopa develop activation-speed-test
koopa develop pytest lang/python/tests/test_cli_develop.py::test_activation_fork_audit_passes
```
