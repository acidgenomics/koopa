---
name: koopa-update
description: >
  How `koopa update` works end to end — the pull+apps default sequence, the
  separate opt-in `koopa update system` mode, and the admin-gated system
  updates it runs (Homebrew, system R/Python, TeX). Use when reasoning about
  what `koopa update` does or doesn't touch, the is_admin() gate vs has_sudo(),
  the "System R is out of date" warning, or the update-system platform matrix.
  For update_koopa() git merge/rebase recovery see koopa-shell-internals.
---

# koopa update

## The three modes

| Command | What it does |
|---|---|
| `koopa update` | Full update — koopa pull + apps. Does **not** touch system apps (see below). |
| `koopa update koopa` | Only pull and update the koopa repo itself |
| `koopa update system` | Only run system updates (requires admin; raises `PermissionError` if not) |

All dispatched through `_handle_update()` in
`lang/python/src/koopa/cli_main.py:665`.

## System updates are opt-in only, not part of the default sequence

As of the 2026-08-06 change ("System updates are no longer run by default" —
see `CHANGELOG.md`), `update_system_apps()` runs **only** via the explicit
`koopa update system` mode, which early-returns at `cli_main.py:704-706`
before the rest of the function body executes. A prior version of this skill
documented step 4 of the default sequence as an unconditional call to
`update_system_apps()`; that call site was removed entirely (it had become
dead code — `system_updates` could only be true when `mode == "system"`,
which already returns earlier in the function — flagged by a code-quality
bot in PR #1224 and deleted). Plain `koopa update` (no mode) does not touch
Homebrew, system R, system Python, or TeX packages at all.

## Full-update sequence

Running `koopa update` (no mode) executes these steps in order:

1. **`update_koopa()`** → `=> Pulling koopa on develop (abc1234).`
   Pulls the latest koopa source. See `koopa-shell-internals` for the git
   merge/rebase recovery logic that runs here.

2. **Bootstrap + venv refresh, alias/unsupported-app cleanup, symlink repair.**
   Internal housekeeping, no user-visible output unless something changed.

3. **`update_stale_apps()` + `install_missing_default_apps()`** →
   `✓ All installed apps are up to date.` (or individual app update lines if
   anything was stale).

System apps are not part of this sequence — run `koopa update system`
separately (requires admin) to update Homebrew, system R, system Python, or
TeX packages. The rest of this skill (admin gate, platform matrix, Homebrew/R
internals) describes what `update_system_apps()` does when invoked that way.

## The admin gate

`update_system_apps()` (`lang/python/src/koopa/install.py:3360`) short-circuits
immediately unless the running user is an admin:

```python
if not is_admin():
    alert_note("Skipping system updates (admin/sudo access required).")
    return
```

**Why this "just works" silently on macOS for admin users:**
`is_admin()` (`lang/python/src/koopa/system.py:290`) is a **static group-membership
check**, not a live sudo probe:

- macOS: `grp.getgrnam("admin").gr_gid in os.getgroups()` — the user is in the
  macOS `admin` group. No password prompt, no `sudo -v`.
- Linux: membership in `sudo` or `wheel` group.
- Root (`os.geteuid() == 0`): always True on any platform.

**Contrast with related helpers (not used for the update gate):**

| Function | What it checks | Used for |
|---|---|---|
| `is_admin()` | OS admin-group membership (static) | `update_system_apps()` gate |
| `has_sudo()` (`system.py:316`) | Probes `sudo -v -n` — actual passwordless sudo | brew permission fixes |
| `is_owner()` (`system.py:280`) | `stat(koopa_prefix()).st_uid == getuid()` | koopa-prefix ownership checks |

**Only the explicit mode reaches this gate at all:** plain `koopa update`
never calls `update_system_apps()` (see "System updates are opt-in only"
above), so `is_admin()` is never consulted on that path — there is no
silent-skip case to reason about there anymore. `koopa update system`
(explicit): non-admin → `PermissionError("'koopa update system' requires
admin/sudo access.")`, raised at `cli_main.py:689`, before
`update_system_apps()` (and therefore its own internal `is_admin()` check)
is ever reached.

## What updates and how it decides

`update_system_apps()` iterates the `update-system` entries from
`PYTHON_INSTALLER_MODES` (`lang/python/src/koopa/installers/__init__.py:549`),
filtered by platform via `_platform_matches()` (`install.py:3379`).

### Platform matrix

| App | Platform tag | Runs on | Secondary guard |
|---|---|---|---|
| homebrew | common | macOS + Linux | `brew` on PATH |
| python | macos | macOS only | `check_macos_system_python()` out of date |
| r | macos | macOS only | `check_system_r()` mismatch |
| r | debian | Debian-like only | `check_system_r()` mismatch **and** `is_admin()` (extra Linux gate inside `check_system_r`) |
| tex-packages | common | macOS + Linux | `tlmgr` on PATH |

### Homebrew (`install.py:3426`)

`_update_system_homebrew()`: runs only if `shutil.which("brew")` is not None.
Reinstalls the `homebrew` system app → `brew update`, upgrade casks/brews,
cleanup, `brew doctor`.

**Non-interactive requirement.** All brew subprocesses must run with
`stdin=subprocess.DEVNULL` and `env=_brew_env()` (`brew.py:14`). Without this,
`BuildProgress._start_capture()` redirects fds 1/2 to the log file while leaving
fd 0 (stdin) on the tty — any brew/cask/`sudo` prompt is invisible and blocks
forever (confirmed 39h24m hang). `_brew_env()` sets `NONINTERACTIVE=1`,
`HOMEBREW_NO_ENV_HINTS=1`, and `HOMEBREW_NO_AUTO_UPDATE=1`; the last only disables
the *implicit* pre-command auto-update, not the explicit `brew update` step.

- All brew calls are centralized through `_brew()` in `brew.py` — that helper
  enforces `stdin=DEVNULL` and `env=_brew_env()` for every caller, including
  `koopa app brew upgrade`.
- The `sudo chown` in `brew_reset_permissions` also uses `stdin=DEVNULL` (no brew
  env needed, but same hang vector if sudo re-prompts).
- Tests in `lang/python/tests/test_brew.py` lock this invariant: any future raw
  `subprocess.run(["brew", ...])` without hardening will break the regression test.

### System R (`install.py:3445`, `check.py:528`)

`_update_system_r()` calls `check_system_r()` first. `check_system_r()`:

- Reads the expected version from `import_app_json().get("r", {}).get("version")`.
- On macOS checks `/usr/local/bin/R` and the R.framework binary.
- Compares as **plain strings** (`installed != expected`) — any mismatch is
  "out of date", which is why you see:
  ```
  Warning: System R is out of date at '/usr/local/bin/R': 4.6.0 != 4.6.1.
  ```
- Returns `False` (out of date) → `_update_system_r` proceeds to reinstall.

The macOS reinstall routes to the `("r", "macos", "system")` installer
(`installers/r_macos.py`). On Debian-like Linux, `check_system_r` has an
additional early-return guard: `if not is_admin(): return True` (skip the
check on non-admin Linux, treating it as "up to date" so no reinstall attempt).

## See also

- `koopa-shell-internals` — `update_koopa()` git merge/rebase recovery (step 1 above).
- `koopa-app-registry` — installer `main()` contract and version-check machinery
  that the system-app reinstalls use under the hood.
