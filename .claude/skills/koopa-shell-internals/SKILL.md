---
name: koopa-shell-internals
description: >-
  Internals of koopa shell activation and update recovery. Use when optimizing
  shell startup, editing activation-path functions, caching plugin init output,
  debugging lazy-load wrappers, fixing update_koopa() merge/rebase recovery, or
  reasoning about non-interactive activation (SSH, CI, agentic harnesses).
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

## Non-Interactive Activation (opt-in; reverted default-on 2026-07-29)

Non-interactive shells (`ssh host 'cmd'`, CI steps, agentic harnesses) do **not**
activate by default. Set `KOOPA_AUTO_ACTIVATE=1` to opt in (PATH and environment
exports only, no prompt/alias/history machinery). A default-on version of this
shipped briefly on 2026-07-29 and was reverted the same day after reproducing real
hangs and stderr corruption — see "Why default-on was reverted" below before
re-attempting this.

### Which rc file each invocation actually reads (verified via `env -i`)

| Invocation | Files read |
|---|---|
| `ssh host 'cmd'` (bash) | `.bashrc` only (bash is built with `SSH_SOURCE_BASHRC`) |
| `bash -lc` | `.bash_profile` only |
| `bash -c` (no `SSH_CLIENT`) | none |
| `zsh -c` | **`.zshenv` only** — `.zshrc` is never read |
| `zsh -lc` | `.zshenv`, `.zprofile`, `.zlogin` |
| `zsh -ic` | `.zshenv`, `.zshrc` |

**Trap:** `.zshrc` is a dead end for `zsh -c`. If non-interactive zsh activation is
ever wanted, `~/.zshenv` is the only rc file that runs — but see the hazards below
before putting activation there. `.zshenv` runs for **every** zsh invocation,
including tool subprocesses (`zsh -c '...'` inside editors, scripts, etc.), not just
remote sessions.

### `KOOPA_FORCE=1` is not the non-interactive lever

`KOOPA_FORCE=1` also flips `_koopa_is_interactive` true (see
`lang/sh/functions/is/is-interactive.sh`), which turns on starship/atuin/prompt
machinery. Measured fallout under a non-TTY, `TERM=dumb` shell:

```
bash 5.3: atuin-bash.sh: line 783: bind: warning: line editing not enabled
zsh:      [ERROR] - (starship::print): Under a 'dumb' terminal (TERM=dumb).
```

Any stderr during `ssh host 'cmd'` is a regression (breaks `scp`/`rsync` framing
expectations even when they don't literally share the channel). The correct lever
is `KOOPA_ACTIVATE=1` with `_koopa_is_interactive` left `false`, so every existing
`_koopa_is_interactive || return 0` guard keeps suppressing interactive-only code.

### Why default-on was reverted

The 2026-07-29 default-on attempt claimed "verified clean: 0 bytes stdout, 0 bytes
stderr" for the `KOOPA_ACTIVATE=1` path. That verification ran from a cwd with no
`.envrc` and does not generalize. Reproduced same-day, on the deployed code:

- **8.15s hang vs 0.01s legacy.** `_koopa_activate_direnv` runs
  `eval "$(direnv export)"` on the activation path, which executes arbitrary
  `.envrc` code in the cwd. A `.envrc` containing `sleep 8` blocked
  `ssh host 'cmd'` for 8 seconds. This is exactly the blocking-I/O class banned
  from the activation path by the "network / blocking I/O" table above — the
  default-on change reintroduced it via `.envrc`, on a far wider surface (any
  cwd, any teammate's `.envrc`). (Since bounded with `gtimeout` on both the
  startup export and the installed `cd` hook — see "`.envrc` execution is
  bounded by `gtimeout`" under "direnv Must Capture Its Baseline Last" — but
  that fix came later and doesn't retroactively excuse shipping default-on
  without it.)
- **106 bytes of stderr from a blocked `.envrc`; 48 bytes even on success**
  (`direnv: loading ...` / `direnv: error ... is blocked`). Corrupts the
  `ssh host 'cmd'` output channel.
- **The interactive gating (below) was applied only to `lang/sh/`.** The
  `lang/bash/` and `lang/zsh/` copies of `_koopa_activate_today_bucket` and
  `_koopa_check_multiple_users` had zero occurrences of `_koopa_is_interactive`,
  so on the shells people actually use, `~/today` still got rewritten and EC2
  still printed to stdout under a non-interactive shell. (Since fixed — see
  "Side-effect functions" below, now applied to all three shell families.)
- **Secrets loaded into every non-interactive shell.**
  `_koopa_activate_profile_files` sources `.profile-work`, `.profile-private`,
  `.secrets*`. Exported-variable count in `zsh -c` went 11 → 69.
- **The opt-out env var was unreachable when needed.** `zsh -c 'KOOPA_NO_AUTO_ACTIVATE=1 echo hi'`
  still hung 6s, because `.zshenv` had already run before the inline assignment
  took effect. Recovery required `ssh -o SendEnv`/`AcceptEnv` or a dotfile edit —
  no way to un-stick a session from the command line alone.

**Rule:** if non-interactive activation is revisited, `_koopa_activate_direnv`
(and anything else that can execute cwd-controlled code or block) must be
excluded from the non-interactive path entirely, not just gated on
`_koopa_is_interactive` inside functions that assume they'll still partially run.
Verify from three cwds: none, an authorized `.envrc`, and a *blocked* `.envrc` —
the no-`.envrc` case is not representative.

### Side-effect functions must be explicitly interactive-gated

Gating `__koopa_preflight` on interactivity is not enough — three functions run
regardless, gated only on `! _koopa_is_subshell`:

- `_koopa_activate_today_bucket` — `mkdir` + rewrites the `~/today` symlink
- `_koopa_check_multiple_users` — **prints to stdout** on AWS EC2
- `_koopa_activate_color_mode` — cache-file writes + background `koopa configure
  user color-mode` spawn

Each needs its own `_koopa_is_interactive || return 0` (or, for color-mode, gate
only the cache/spawn block and keep the `KOOPA_COLOR_MODE` export unconditional —
it's a plain env var non-interactive consumers benefit from too). Skipping this
means every `scp`/`rsync`/git-over-ssh mutates `~/today`, writes cache files, and
on EC2 can print to stdout mid-transfer. This gate must be applied in all three
shell families (`lang/sh/`, `lang/bash/`, `lang/zsh/`) — each has its own copy of
these functions, and the bundles (`lang/*/include/functions.sh`) must be
regenerated via `koopa develop cache-functions` after editing any of them.

### macOS system bash (3.2) silently activates nothing

`__koopa_header` in `activate.sh` routes on shell *name*, so bash 3.2 gets
`lang/bash/include/header.sh`, which version-gates out (`'1.'* | '2.'* | '3.'*`)
and returns 0 having loaded nothing — no error, just no PATH change. Route
`BASH_VERSION` matching `1.`/`2.`/`3.` to the POSIX header (`lang/sh/include/header.sh`)
instead, which works fine under bash 3.2.

### Re-activation short-circuit (only matters when `KOOPA_AUTO_ACTIVATE=1`)

Nested activation (parent shell activates, spawns a child that activates again)
would re-pay the full ~85ms cost every time, since PATH/env exports are inherited
but nothing checked for that. `__koopa_preflight` short-circuits (return 1, skip)
when non-interactive, `KOOPA_AUTO_ACTIVATE=1` is set, and `KOOPA_PREFIX/bin` is
already on `PATH`. Interactive shells still always re-run activation, since
prompt/alias state doesn't carry across shells the same way env vars do. Since
non-interactive activation is opt-in and off by default, this short-circuit is
dormant unless a caller explicitly sets `KOOPA_AUTO_ACTIVATE=1`.

### Verification (use `env -i`, not your current shell's PATH)

Testing with the current shell's inherited PATH produces false passes — e.g.
`command -v git` resolves via `/usr/bin/git` regardless of whether koopa activated.
Use a koopa-only binary like `bat` instead, and always start from `env -i`. Default
is off, so these should print nothing:

```sh
env -i HOME="$HOME" TERM=dumb PATH=/usr/bin:/bin bash -c '. "${HOME}/.profile"; command -v bat'
env -i HOME="$HOME" TERM=dumb PATH=/usr/bin:/bin zsh -c 'command -v bat'
env -i HOME="$HOME" SSH_CLIENT="1.2.3.4 1 2" TERM=dumb PATH=/usr/bin:/bin bash -c 'command -v bat'
```

The opt-in path (`KOOPA_AUTO_ACTIVATE=1`) should activate, and must be checked from
a cwd with a **blocked** `.envrc`, not just a clean one — that's the case the
2026-07-29 "verified clean" claim missed:

```sh
D="$(mktemp -d)"; cd "$D"; echo 'export FOO=bar' > .envrc   # deliberately not allowed
env -i HOME="$HOME" TERM=dumb KOOPA_AUTO_ACTIVATE=1 PATH=/usr/bin:/bin \
    bash -c '. "${HOME}/.profile"; command -v bat' >o 2>e
wc -c <o; wc -c <e   # bat found; stderr will be non-zero — expected with direnv on this path
```

## direnv Must Capture Its Baseline Last

### How `_koopa_activate_direnv` works (two-step)

1. **Hook sourcing** (order-independent): caches and sources `direnv hook <shell>`, which
   installs a precmd/chpwd hook. This step is safe at any activation position.
2. **`eval "$(direnv export <shell>)"`** (order-critical): this fires immediately at
   activation time. If the shell is already inside a directory with an `.envrc` (e.g. the
   koopa repo's `.envrc` which activates `.venv`), direnv loads the `.envrc` **and records the
   current PATH as its restore baseline** — the snapshot it will revert to on
   `direnv: unloading`.

### `.envrc` execution is bounded by `gtimeout` (added 2026-07-29)

`direnv export` evaluates the `.envrc` in the current directory, i.e. arbitrary code
(`sleep 60`, a network call, anything). This was the root cause of the hangs cited
above under "Why default-on was reverted" — but it isn't limited to the
non-interactive path. **The same eager `eval` runs unconditionally on the interactive
path too**, and — this is the part that's easy to miss — **`direnv hook <shell>`
installs a `precmd`/`chpwd`/`PROMPT_COMMAND` function that re-runs `direnv export` on
every subsequent `cd`**, not just at shell startup. A pathological `.envrc` therefore
wedges the shell both when the shell starts inside that directory *and* every time a
user later `cd`s into it.

Both call sites (the one-time startup export, and the installed `_direnv_hook`) are
now wrapped with `gtimeout` (`${KOOPA_PREFIX}/bin/gtimeout`, from the `coreutils` app —
present on macOS and Linux since koopa always installs GNU coreutils). Default bound:
5 seconds, overridable via `KOOPA_DIRENV_TIMEOUT` (seconds); `KOOPA_DIRENV_TIMEOUT=0`
disables the bound and restores the unbounded legacy call.

**The hook body cannot close over this function's locals.** `_direnv_hook` is defined
inside `_koopa_activate_direnv`, but it's *invoked* later, from `precmd_functions` /
`PROMPT_COMMAND`, after `_koopa_activate_direnv` has already returned. Bash/zsh don't
capture enclosing-function locals in a nested function the way a lexical closure
would — by the time `_direnv_hook` runs, this function's `local timeout=...` and
`local gtimeout=...` are already gone. The hook body must re-derive both from globals
(`KOOPA_PREFIX`, `KOOPA_DIRENV_TIMEOUT`) every time it fires, not reference the
enclosing function's locals. Verify this class of bug isn't reintroduced:

```sh
bash -c '
outer() {
  local secret="from_outer"
  inner() { echo "secret=${secret:-UNSET}"; }
}
outer
inner   # prints "secret=UNSET" — the closure does NOT work in bash/zsh
'
```

`gtimeout` (without `-v`) writes nothing of its own to stdout or stderr on timeout;
direnv's own `direnv: loading ...` notice on stderr still passes through either way,
since it's outside the `$(...)` capture that `eval` consumes. On timeout, the captured
stdout is empty, so the `eval` is a no-op for that directory — the shell continues
without direnv's exports rather than hanging.

**Testing trap:** `bash -c 'cd $dir; other_cmd'` and `zsh -c 'cd $dir; other_cmd'`
do **not** reliably exercise the hook the same way. zsh's `chpwd_functions` fires
synchronously on `cd` even under `-c`. Bash's `PROMPT_COMMAND` only fires at the next
*prompt redraw* — `bash -i -c '...'` never produces one, so a naive test that doesn't
also `eval "$PROMPT_COMMAND"` after the `cd` will falsely appear instant. Verify with:

```sh
D="$(mktemp -d)"; cd "$D"; printf 'sleep 30\n' > .envrc
"${KOOPA_PREFIX}/bin/direnv" allow .
cd "${KOOPA_PREFIX:-$HOME/.local/share/koopa}"

# zsh: chpwd fires on cd directly — should bound at ~5s, not 30s.
time zsh -i -c "cd $D; echo reached" </dev/null

# bash: must explicitly fire PROMPT_COMMAND to simulate a real prompt cycle.
time bash -i -c "cd $D; eval \"\$PROMPT_COMMAND\"; echo reached" </dev/null
```

Measured cost of the `gtimeout` wrapper itself: ~0ms (A/B'd via
`KOOPA_DIRENV_TIMEOUT=0` vs default, and against a `git stash` of the pre-fix files —
both landed in the same 145-210ms band across repeated `activation-speed-test` runs;
the spread is session/system load noise, not this change).

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
