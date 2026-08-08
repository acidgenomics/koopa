---
name: koopa-color-mode
description: >
  How koopa propagates and applies dark/light color mode across SSH, tmux, shells,
  and chezmoi-rendered theme files. Use when debugging wrong-palette or stale-theme
  symptoms after a dark↔light flip, working on color-mode sync jobs or watchers,
  editing the chezmoi color-mode apply path, investigating why bat/starship/delta
  renders the wrong theme while fzf/LS_COLORS look correct, diagnosing a Linux
  host stuck on the wrong palette over SSH (gdbus/XDG-portal parsing, `read`
  clobbering, or dead in-tmux re-derive logic), or confirming whether a fix that
  touches opt/dotfiles/chezmoi has actually rolled out to a host.
---

# koopa Color Mode

## SSH + tmux: OSC Mode 2031

When connecting over SSH, prefer **tmux OSC mode 2031** (`client-light-theme` /
`client-dark-theme` hooks, tmux ≥ 3.6) for light/dark color-mode propagation. It
pushes theme state as escape sequences on the SSH data channel — sshd cannot strip
them, no `AcceptEnv` or `SendEnv` forwarding needed.

**Enabling requirement:** tmux ≥ 3.6 on the remote. Always invoke koopa's bundled
tmux in the SSH `RemoteCommand`:

```
RemoteCommand ~/.local/share/koopa/bin/tmux new-session -A
```

Never use the system tmux (often 3.2a on servers — no mode-2031 support).

`SendEnv KOOPA_COLOR_MODE` in `~/.ssh/config` is still worth keeping as an
initial-value hint (seeds mode before the first tmux hook fires) but is not the
live-tracking mechanism and silently fails when sshd lacks `AcceptEnv KOOPA_COLOR_MODE`.

**Root cause of the `slurm` server "washed out" bug:** `RemoteCommand` was pointing to
`/usr/bin/tmux` (3.2a) instead of koopa's bundled tmux (3.6b). Fixing the
`RemoteCommand` is the only change needed.

## SSH Login Hang: Pre-tmux RemoteCommand Shell

**Symptom:** `ssh <host>` prints the banner then hangs. The hang is not during
connection — it occurs during koopa shell activation in the login shell.

**Cause:** `_koopa_terminal_is_light_background` issues a blocking OSC 11
background-color query (`printf '\033]11;?\033\\' > /dev/tty`) and reads the reply
with `dd bs=64 count=1 < /dev/tty`, bounded by `stty raw -echo min 0 time 2`
(VTIME 0.2s). The VTIME bound applies to fd 0, but the `dd` reads from a
separately-opened `/dev/tty` — when those descriptors diverge over SSH, VTIME never
applies and the read blocks in canonical mode indefinitely.

**Why a tmux `RemoteCommand` host still hangs:** the SSH config pattern

```
RemoteCommand ~/.local/share/koopa/bin/tmux new-session -A
RequestTTY yes
SetEnv TERM=xterm-256color
```

causes sshd to run the **login shell** to exec tmux. koopa activation runs in that
outer shell *before* tmux starts — `$TMUX` is unset, so the tmux guard misses. `TERM`
is forced to `xterm-256color`, so the `screen*/tmux*` guard misses too. If the remote
sshd lacks `AcceptEnv KOOPA_COLOR_MODE` (meaning `SendEnv` silently no-ops),
`KOOPA_COLOR_MODE` is empty → `_koopa_color_mode` → `_koopa_is_light_mode` → the
blocking probe → hang.

**Fix (implemented 2026-07-15):** SSH-session guard in the `_koopa_is_light_mode`
**dispatcher** (`lang/*/functions/core/is-light-mode.*`) across all seven shells.
When `SSH_CONNECTION` or `SSH_TTY` is set and not inside tmux, fall back to
`~/.cache/koopa/color-mode` — identical to the existing vscode branch. tmux-over-SSH
still uses the tmux branch (live OSC-2031); the SSH branch only fires in the pre-tmux
outer shell and on bare SSH sessions (no `RemoteCommand`).

The guard lives in the **dispatcher**, not the probe — so it returns the correct cached
color rather than forcing dark (`return 1`).

After editing bash/sh/zsh dispatchers, run `koopa develop cache-functions` to
regenerate `lang/{bash,sh,zsh}/include/functions.sh`. fish/elvish/nushell/powershell
source function files directly — no regen needed.

## Abrupt SSH Death Leaves Local Terminal Wedged

**Symptom:** local shell prints `^[[<0;56;29M` / `^[[<0;56;29m` (SGR mouse reports,
DEC modes 1000/1006) and `^[[?997;2n` (mode-2031 color-scheme report: `997;2` = light)
as literal keystrokes into the prompt.

**Cause:** remote tmux enables these DEC private modes on the *local* terminal over the
SSH data channel:
- Mouse tracking — `set-option -g mouse on` ([tmux.conf.tmpl:200](opt/dotfiles/chezmoi/dot_config/tmux/tmux.conf.tmpl#L200))
- Color-scheme notifications (mode 2031) — the tmux ≥ 3.6 `client-dark-theme`/
  `client-light-theme` hooks ([tmux.conf.tmpl:176-191](opt/dotfiles/chezmoi/dot_config/tmux/tmux.conf.tmpl#L176-L191))

When SSH dies abruptly (e.g. `ssh_dispatch_run_fatal: message authentication code
incorrect` — a transport-level packet integrity failure), tmux never sends the paired
disable sequences (`CSI ? 1000 l`, `CSI ? 1006 l`, `CSI ? 2031 l`) back to the local
terminal. The local terminal stays subscribed, so mouse moves and OS dark/light changes
inject escape bytes as prompt input.

**koopa is NOT the emitter.** koopa emits none of these enable sequences — the
enable is owned by tmux (≥ 3.6) and the outer terminal emulator. The "Terminal
appearance changed to light mode. Updating shell colors." message fires
*coincidentally* because the tmux `client-light-theme` hook set
`KOOPA_COLOR_MODE=light` which the per-prompt `_koopa_bash_color_mode_sync` then
detected — koopa is reacting to the tmux hook, not causing the escape leak.

**Recovery:**
```
koopa run reset-terminal
```
Emits `CSI ? 1000/1002/1003/1006 l`, `CSI ? 1004 l`, `CSI ? 2004 l`, `CSI ? 2031 l`,
`CSI ? 1049 l` (leave alt-screen), `CSI ? 25 h` (show cursor), then `stty sane` and
`tput reset`.

Manual fallback (if koopa venv is unavailable):
```
stty sane; printf '\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[?2031l'; tput reset
```

**Optional auto-reset on ssh exit:** `export KOOPA_SSH_RESET=1` (set in shell profile)
enables an opt-in `ssh()` wrapper defined by `_koopa_activate_ssh_reset` that runs
`koopa run reset-terminal` automatically on every ssh exit. Off by default so the real
`ssh` binary is unshadowed unless explicitly requested.

**Related:** the OSC-11 probe hardening below (`terminal-is-light-background.sh`)
follows the same edit-source-then-`koopa develop cache-functions` workflow described in
the "VS Code / Posit Workbench: OSC 11 Leaks" section.

## Env-Driven vs File-Driven Consumers

koopa's color-mode consumers split into two categories with very different timing:

**Env-driven (always correct after activation):**
`FZF_DEFAULT_OPTS`, `DFT_BACKGROUND`, `MCFLY_LIGHT`, `LS_COLORS`/`DIRENV_COLORS`.
These read `$KOOPA_COLOR_MODE` directly in `_koopa_activate_*` functions — set
synchronously at activation, always correct in every new shell.

**File-driven (depend on on-disk chezmoi-rendered files):**
`bat` theme (`~/.config/bat/config`), starship palette (`~/.config/starship.toml`),
delta theme (`~/.config/delta/theme.gitconfig`).
Content baked at last `chezmoi apply`. If apply hasn't happened for the current OS
mode, these files are stale — even though `KOOPA_COLOR_MODE` and env-driven tools
are correct.

**Classic symptom:** correct terminal/fzf/LS_COLORS colors, but wrong bat/starship/delta
after a dark↔light flip. The env is NOT the bug — the on-disk theme files are stale.
Check mtime of `~/.config/bat/config`, `~/.config/starship.toml`,
`~/.config/delta/theme.gitconfig` against the flip time.

**Fix:** when `~/.cache/koopa/color-mode-applied` ≠ current OS mode, run
`koopa configure user color-mode` **synchronously** for interactive shells.

## VS Code / Posit Workbench: OSC 11 Leaks `^[\`

Posit Workbench runs VS Code with an xterm.js terminal that does not properly consume
the String Terminator in the OSC 11 background-color query response. The `\033\\` at
the end leaks as literal `^[\` in the terminal output — at shell startup AND on every
prompt via `PROMPT_COMMAND`.

**Fix:** guard with `TERM_PROGRAM=vscode`; skip the OSC 11 query; fall back to cache
file `~/.cache/koopa/color-mode`:

```bash
elif [[ "${TERM_PROGRAM:-}" == 'vscode' ]]
then
    local cache_file="${HOME:?}/.cache/koopa/color-mode"
    [[ -f "$cache_file" ]] && [[ "$(<"$cache_file")" == 'light' ]]
```

Apply in both `is-light-mode.sh` and `terminal-is-light-background.sh`, across all
three shell variants (bash, sh, zsh). After editing, run `koopa develop cache-functions`
to regenerate the `include/functions.sh` bundle.

## launchd/systemd: Never Re-Bootstrap the Own Agent

A background color-mode sync job that calls the full dotfiles installer will trigger
`_sync_launchd_agent()` → `launchctl bootout <self>` → SIGTERM mid-run. The process
dies before writing any state marker, leaving a permanent wedge.

**Rule:** color-mode sync jobs must do targeted work only — use `chezmoi apply <targets>`
directly. Never invoke `opt/dotfiles/install` or any path that calls
`_sync_launchd_agent`/`_sync_systemd_user_agent`. Leave agent lifecycle to the full
`koopa configure user dotfiles`.

## On-Disk-Only Target Check Wedges the Whole Apply (One Unmanaged File Blocks All)

**Symptom:** `~/.cache/koopa/color-mode-applied` permanently disagrees with
`KOOPA_COLOR_MODE`/`~/.cache/koopa/color-mode` (which are correct), and
`~/.cache/koopa/logs/color-mode.log` shows the same failure repeating on every
shell activation, hours or days apart, never converging:

```
▸ [...] Applying color mode: light
chezmoi: ~/.claude/settings.json: not managed
Error: Command '[... apply ... 31 target paths ...]' returned non-zero exit status 1
```

Every file-driven consumer (bat, starship, delta) stays on the stale palette
indefinitely — this is the permanent-wedge shape, not a one-off transient failure.

**Root cause:** `_discover_color_mode_targets()` in
[color_mode.py](lang/python/src/koopa/configurers/color_mode.py) used
`os.path.exists(target)` as its inclusion test — "does a rendered file already
sit at this path." That is not equivalent to "does the main tree currently manage
this target." `.chezmoiignore` can exclude a target conditionally (here:
`.claude/settings.json` is ignored by the main tree whenever the work-tree marker
`~/.config/koopa/dotfiles-work` is present) while the file still exists on disk,
rendered instead by another tree (the work tree, in this case). The file passes
the exists() check and gets added to the target list anyway.

The reason this is fatal rather than merely wrong: chezmoi validates **every**
target argument passed to `apply` up front and aborts the **entire** call —
applying nothing — if even one is unmanaged. One ignored file blocks all ~29
legitimate color-mode targets in the same invocation. Confirmed by experiment:

```sh
# managed target alone -> applies cleanly
chezmoi apply --dry-run --force ~/.config/bat/config

# same target plus one unmanaged target -> nothing applies, exit 1
chezmoi apply --dry-run --force ~/.config/bat/config ~/.claude/settings.json
# chezmoi: ~/.claude/settings.json: not managed
```

Because `configurers/color_mode.py` writes the applied-marker only *after* a
successful apply (correctly — see "Do not mask a real apply failure" pattern
elsewhere in this codebase), the marker never advances. Every subsequent shell
sees the mismatch and respawns the job via `_koopa_activate_color_mode`, which
fails identically — a permanent self-heal-proof loop, structurally the same
failure shape as the Linux gdbus bug below, reached by a different route.

**Fix:** discovery must filter against the tree's actual `chezmoi managed`
output, not disk existence. Reuse `_chezmoi_managed()` from
[dotfiles.py](lang/python/src/koopa/configurers/dotfiles.py) (already used by the
`dotfiles` configurer for cross-tree overlap warnings) rather than adding a new
probe helper. Two guardrails matter as much as the filter itself:
- An empty managed set means the probe itself failed (`_chezmoi_managed()`
  degrades to `set()` on subprocess error by design) — treat that as "can't apply
  safely, skip" rather than inverting it into "nothing is managed, so apply
  everything," which would silently resurrect the original bug under the exact
  failure condition the fix exists to guard against.
- Dropped (discovered-but-unmanaged) targets must be `warn()`-ed by name, not
  silently excluded. The entire reason this survived undetected for a day is that
  the background job's failure produced no signal outside a log file nobody was
  watching.

**Diagnostic:** compare the discovered set against `chezmoi managed
--path-style=absolute --source=<main-tree>`; any discovered target absent from
that list is the culprit. `grep KOOPA_COLOR_MODE -rl <chezmoi-tree> --include='*.tmpl'`
enumerates every template that could theoretically produce one.

## Targeted chezmoi apply (color-mode switch)

A color-mode flip must re-render only the ~32 templates that branch on
`KOOPA_COLOR_MODE`, via `chezmoi apply <target>...` against the main tree.

Discovery pattern: walk the main chezmoi source for `*.tmpl` files containing
`KOOPA_COLOR_MODE`; derive target paths using chezmoi naming conventions (`dot_` → `.`,
strip `.tmpl`, strip attribute prefixes); filter to targets that exist on disk.

Never route a theme switch through the heavy installer or the work/private trees —
they contain zero `KOOPA_COLOR_MODE` logic and add unnecessary age/git/network
dependency in a background context.

## Render from OS, Never from Inherited Env

Any `chezmoi apply` path that branches on `KOOPA_COLOR_MODE` must derive the value
from the OS at apply time — never trust `os.environ` as inherited from the calling
process. Long-running processes (agent sessions, days-old tmux servers, stale launchd
plists) carry the mode from when they started, not the current OS state.

**The fix:** call `os_appearance_mode()` (from `koopa.system`) and assign it to
`env["KOOPA_COLOR_MODE"]` immediately before every `chezmoi apply` call, in both
`configurers/dotfiles.py` and `opt/dotfiles/install`'s `main()`.

## Re-Apply All Trees in Order

A color-mode switch must re-apply **main → work → private** dotfiles, in that order,
every time. Applying only the main tree can re-assert a main-tree file over a work
override (e.g. npm, pip, claude configs), silently clobbering work config.

`configurers/color_mode.py` delegates to `dotfiles.py`'s `main()` with
`KOOPA_DOTFILES_SKIP_PULL=1` — never runs its own standalone `chezmoi apply`.

## Stale Session Env Contaminates chezmoi status and diff

**Named symptom:** `chezmoi diff` shows exactly one changed line —
`"workbench.colorTheme": "Dracula Pro"` flipping to `"Dracula Pro (Alucard)"` (or
vice versa) — across editor settings files you have not touched.

**Cause:** the agent/shell session's `KOOPA_COLOR_MODE` is frozen at a value that
doesn't match the real OS mode. Templates branching on `KOOPA_COLOR_MODE` render
differently under the stale env, producing a phantom diff. This is NOT real drift.

**Always verify OS mode before acting on a diff:**
```sh
echo "Session: ${KOOPA_COLOR_MODE:-<unset>}"
defaults read -g AppleInterfaceStyle 2>/dev/null || echo "(absent = LIGHT)"
cat ~/.cache/koopa/color-mode-applied 2>/dev/null
```
If session ≠ OS mode, re-run chezmoi commands with the real mode overridden:
```sh
KOOPA_COLOR_MODE=dark chezmoi diff --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi"
```

**corollary:** a file that shows ` M` under the stale env, but is clean under
the correct env, has NOT drifted. Do not "fix" it.

## Linux Portal Probe: `uint32` Substring Collision (stuck-light bug)

**Symptom:** starship/bat/delta render the **light** palette on a Linux host over
SSH even though `KOOPA_COLOR_MODE` in the session is correctly `dark` and tmux
mode-2031 is live. The env-driven layer is right; only the file-driven layer is
wrong, and it never self-heals.

**Root cause:** `_os_appearance_mode_linux()` in
[system.py](lang/python/src/koopa/system.py) parsed the raw `gdbus call ...
Settings.Read org.freedesktop.appearance color-scheme` stdout with a bare
substring test:

```python
stdout = result.stdout.strip()  # '(<<uint32 1>>,)' for prefer-dark
if "2" in stdout:  # "uint32" contains a literal '2'!
    return "light"
```

The type name in gdbus's variant-wrapped output (`(<<uint32 1>>,)`) always
contains a `2`, so this test is true unconditionally — the function returns
`"light"` for every portal value (`0`, `1`, and `2` alike) whenever gdbus exits 0.
**Fix:** anchor on the type name and extract the digit that follows it —
`re.compile(r"uint32\s+(\d+)")` — never substring-match the raw stdout.

**Why it wedges instead of surfacing immediately:** `os_appearance_mode()` is the
sole mode source for the targeted-apply job in `configurers/color_mode.py`. Once
it returns the wrong value, the job renders all `KOOPA_COLOR_MODE`-branching
templates from the wrong palette *and* writes that wrong value to
`~/.cache/koopa/color-mode-applied`. Every subsequent new shell compares the
marker against the (correct) `KOOPA_COLOR_MODE` env var, sees a permanent
mismatch, and respawns the sync job — which reaches the same wrong conclusion
every time. `rm`-ing the marker does not help; the probe itself is deterministic,
so only fixing the parse breaks the loop.

**Diagnostic:** run the exact gdbus call by hand and compare against
`os_appearance_mode()` — if the portal reports `uint32 1` (prefer-dark) but koopa
resolves `light`, this is the bug:
```sh
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.Read \
  org.freedesktop.appearance color-scheme
python3 -c 'from koopa.system import os_appearance_mode; print(os_appearance_mode())'
```

Regression coverage lives in
[test_system.py](lang/python/tests/test_system.py) — the gsettings fallback had
the same class of issue (`"prefer-light" in stdout` with no explicit
`"prefer-dark"` check, silently relying on the trailing default) and was
tightened alongside.

## POSIX `read` Clobbers a Successfully-Read Value

**Symptom:** on `sh` specifically (not bash/zsh), the cache-file fallback in
`_koopa_is_light_mode` reads back `dark` even when
`~/.cache/koopa/color-mode` correctly contains `light`.

**Cause:** `read -r var < file` returns exit status 1 on EOF without a trailing
newline, but it has **already assigned** the variable before returning. The idiom
`read -r var < "$f" 2>/dev/null || var=''` treats that nonzero status as failure
and blanks the value it just read. The tmux mode-2031 hooks
([tmux.conf.tmpl](opt/dotfiles/chezmoi/dot_config/tmux/tmux.conf.tmpl)) wrote the
cache with `printf light >` (no trailing newline), so every `sh` reader of that
file silently degraded to dark.

**Fix:** pre-initialize, don't post-correct:
```sh
__kvar_mode=''
read -r __kvar_mode < "$__kvar_cache_file" 2>/dev/null
```
And make the writer emit a newline (`echo` instead of `printf` with no `\n`) so
the cache format matches what `printf '%s\n'` already writes elsewhere. bash/zsh
are unaffected — they use `$(<file)` command substitution, which strips trailing
newlines and never exhibits this. Grep for `read -r .* || .*=''` across
`lang/sh/` before assuming a single-shell fix is complete; it was a 4-occurrence
pattern in one file, not a one-off.

## Dead In-Tmux Re-Derive in `activate-color-mode.sh`

**Symptom:** a stale `KOOPA_COLOR_MODE` inherited from a days-old tmux server (or
a reattached session) is never corrected at shell activation, even though the
code has a branch that looks like it should handle exactly this:

```sh
elif [ -z "${KOOPA_COLOR_MODE:-}" ] || [ -n "${TMUX:-}" ]
then
    KOOPA_COLOR_MODE="$(_koopa_color_mode)"
fi
```

**Cause:** `_koopa_color_mode()` (in `core/color-mode.sh`) returns
`$KOOPA_COLOR_MODE` verbatim whenever it is already set — that's its documented
job for non-interactive consumers. So the `-n "${TMUX:-}"` half of this condition
is a no-op: it re-invokes a function whose first move is to hand back the exact
stale value it's trying to replace.

**Fix:** in the tmux branch, call `_koopa_is_light_mode` directly (which *does*
consult `tmux show-environment -g KOOPA_COLOR_MODE`) instead of routing through
`_koopa_color_mode`. Mirror the shape the macOS branch already uses:
```sh
elif [ -n "${TMUX:-}" ]
then
    if _koopa_is_light_mode
    then
        KOOPA_COLOR_MODE='light'
    else
        KOOPA_COLOR_MODE='dark'
    fi
elif [ -z "${KOOPA_COLOR_MODE:-}" ]
then
    KOOPA_COLOR_MODE="$(_koopa_color_mode)"
fi
```
Applies identically to all three of `lang/{bash,sh,zsh}/functions/activate/
activate-color-mode.sh`. Leave `_koopa_color_mode` itself untouched — the
return-the-env behavior is correct and relied upon elsewhere.

## A Two-Repo Fix Needs Both Halves Pushed AND the Pin Bumped

The 2026-08 stuck-light-mode investigation above spanned two repos: the gdbus
parse bug lived in `koopa` (`system.py`), but the trailing-newline fix for the
tmux mode-2031 hooks lived in `opt/dotfiles/chezmoi/dot_config/tmux/
tmux.conf.tmpl` — a separate git repo (`github.com/acidgenomics/dotfiles`) pinned
by SHA in `etc/koopa/app.json`.

Pushing the koopa half alone made the primary symptom (starship/bat/delta stuck
light) fully disappear on the test host, which made it easy to assume the whole
fix had landed. It hadn't: the dotfiles-repo commit sat local-only until it was
also pushed and the `app.json` pin bumped — see `koopa-dotfiles` skill for the
exact 4-step rollout and the "known failure mode" this causes (`koopa install
dotfiles` reports the old SHA as current; the expected file is silently absent
from `koopa configure user dotfiles`'s pending-changes list).

**Takeaway:** when a color-mode fix touches anything under `opt/dotfiles/
chezmoi/`, don't declare it shipped from the koopa-side push alone — confirm the
dotfiles repo's `origin/main` SHA matches (or is ahead of) the `version` pinned
in `etc/koopa/app.json` before telling the user it's live.

## Never Verify by Re-Running the Installer from an Agent Session

Never run `koopa configure user dotfiles` from inside a Claude Code (or other
long-running agent) session to verify color-mode rendering. The session's
`KOOPA_COLOR_MODE` is frozen at the value it had when the session started — running
the installer from that session clobbers the user's files to the wrong palette.

To verify rendering without risk: check rendered files' content with `grep` or `cat`.
Do not trigger a re-render.
