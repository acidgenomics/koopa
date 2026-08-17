---
name: koopa-color-mode
description: >-
  How koopa propagates and applies dark/light color mode across SSH, tmux, shells,
  and chezmoi-rendered theme files. Use when debugging wrong-palette or stale-theme
  symptoms after a dark↔light flip, working on color-mode sync jobs or watchers,
  editing the chezmoi color-mode apply path, investigating why bat/starship/delta
  renders the wrong theme while fzf/LS_COLORS look correct, diagnosing a Linux
  host stuck on the wrong palette over SSH (gdbus/XDG-portal parsing, `read`
  clobbering, or dead in-tmux re-derive logic), confirming whether a fix that
  touches opt/dotfiles/chezmoi has actually rolled out to a host, or a code fix
  to color_mode.py appearing to have no effect even after relaunching an app.
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

## A Tool Can Be Invisible to the Whole Pipeline: No Template Means No Candidate

**Symptom:** a terminal tool (btop, in the 2026-08 case) renders the wrong
palette in every mode, with no drift in `chezmoi status`, no mismatch between
`KOOPA_COLOR_MODE` and `~/.cache/koopa/color-mode-applied`, and nothing in
`~/.cache/koopa/logs/color-mode.log`. Every other file-driven consumer (bat,
starship, htop, bottom) is correct. This looks like nothing is wrong anywhere
in the pipeline, because *nothing is* — the tool's config was never made a
target in the first place.

**Root cause:** `_scan_color_mode_candidates()` in
[color_mode.py](lang/python/src/koopa/configurers/color_mode.py) discovers
targets by walking the chezmoi source for `*.tmpl` files that contain the
literal string `KOOPA_COLOR_MODE`. A config file that is not chezmoi-managed at
all — no `.tmpl` exists anywhere in any tree — produces no candidate, so it is
never inspected, never warned about, and never flipped. Every other documented
failure in this skill (unmanaged-target abort, gdbus substring bug, dead
in-tmux re-derive, ...) presupposes a template exists and something *downstream*
of that template breaks. This is the zeroth case: the template was never
written, so the tool was invisible to the pipeline from the start.

**Diagnostic — before assuming a sync-logic bug, check onboarding first:**
```sh
grep -ril <tool> ~/.local/share/koopa/opt/dotfiles/chezmoi/     # any hits at all?
ls ~/.config/<tool>/                                            # themes/ dir empty?
```
If the git tree has zero hits and the live config carries stock/default
values (not a rendered template's output), the tool was never onboarded — this
is a missing-template gap, not a broken-sync bug. Check whether a `removed:
true, successor: <tool>` predecessor in `etc/koopa/app.json` used the identical
config format (e.g. `bpytop` → `btop`, both read the same `.theme` file
grammar) — its `.tmpl` is often a ready-made porting reference even though it
is otherwise dead code.

**Fix:** write the missing `.tmpl` following the nearest sibling's pattern
(see `koopa-theming`'s Dracula Pro sections for the branch structure). Verify
the new candidate is picked up by both halves of discovery before trusting it:
```sh
python3 -c "
from koopa.configurers.color_mode import _scan_color_mode_candidates
print([t for t in _scan_color_mode_candidates('opt/dotfiles/chezmoi') if '<tool>' in t])"
chezmoi managed --path-style=absolute --source=opt/dotfiles/chezmoi | grep <tool>
```
Present in the first list but absent from the second is the pre-existing
"On-Disk-Only Target Check" bug below, now applied to a brand-new target.

## On-Disk-Only Target Check Wedges the Whole Apply (One Unmanaged File Blocks All)

**Symptom:** `~/.cache/koopa/color-mode-applied` permanently disagrees with
`KOOPA_COLOR_MODE`/`~/.cache/koopa/color-mode` (which are correct), and
`~/.cache/koopa/logs/color-mode.log` shows the same failure repeating on every
shell activation, hours or days apart, never converging:

```
   [...] Applying color mode: light
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

**Follow-on lesson (2026-08):** filtering an unmanaged target out of one tree's
apply is only half a fix. `.claude/settings.json`'s original filter fix stopped
here — it correctly warned and dropped the target from the main-tree apply, but
nothing then applied it from the tree that *does* manage it (the work tree). The
file silently froze at whatever `custom:dracula-pro`/`custom:dracula-pro-alucard`
value it had at the last full `koopa configure user dotfiles`, and every flip
after that quietly no-op'd it while every other file-driven consumer re-rendered.
See "Re-Apply All Trees in Order" below for the fix. The diagnostic that catches
this class of bug: compare mtimes across color-mode targets (`stat -f '%Sm %N'`)
after a flip — one file lagging days behind its siblings (e.g.
`~/.config/bat/config` at today's date, `~/.claude/settings.json` three days
stale) is the signature, even when every env-driven signal
(`$KOOPA_COLOR_MODE`, `~/.cache/koopa/color-mode(-applied)`) agrees and looks
correct.

## Targeted chezmoi apply (color-mode switch)

A color-mode flip must re-render only the templates that branch on
`KOOPA_COLOR_MODE`, via `chezmoi apply <target>...`, run separately against each
of the three chezmoi trees (main, work, private) — see "Re-Apply All Trees in
Order" below. It is not a single apply against the main tree alone: a target can
be `.chezmoiignore`'d out of one tree and managed by another (e.g.
`.claude/settings.json` moves to the work tree whenever the work-tree marker is
present), and only a per-tree apply picks that up.

Discovery pattern (per tree): walk that tree's chezmoi source for `*.tmpl` files
containing `KOOPA_COLOR_MODE`; derive target paths using chezmoi naming
conventions (`dot_` → `.`, strip `.tmpl`, strip attribute prefixes); filter
against that tree's own `chezmoi managed` output, never disk existence (see
above).

Never route a theme switch through the heavy installer (`opt/dotfiles/install`
or any tree's own `install` script) — only the targeted `chezmoi apply` per
tree, which needs no age/git/network dependency in a background context.

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
every time. Applying only the main tree can leave a work-tree-managed target (e.g.
`.claude/settings.json`, `.config/pip/pip.conf`, `.npmrc` whenever the work-tree
marker is present) permanently stale, since the main tree never touches it and
nothing else does either.

`configurers/color_mode.py` runs its own targeted `chezmoi apply` per tree — main
required (a probe or apply failure there aborts the whole run without writing the
applied-marker), work/private best-effort (a failure warns and continues, marker
still written, so a permanently broken overlay tree never wedges every future
shell in the documented infinite-respawn loop). It does **not** delegate to
`dotfiles.py`'s `main()` — that function's install-script path
(`_sync_launchd_agent`) is exactly what a background sync job must never invoke
(see "launchd/systemd: Never Re-Bootstrap the Own Agent" above). Each tree's
color-mode candidates are discovered independently (own `*.tmpl` scan, own
`chezmoi managed` probe, own `--config` when the tree defines one); a candidate
dropped by one tree is warned about only if *no* tree ends up claiming it —
warning per-tree here would be a permanent false alarm every time a target
legitimately lives in an overlay tree.

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

## A Code Fix to color_mode.py Doesn't Apply Itself — the Marker Still Gates It

**Symptom:** after fixing a real bug in `configurers/color_mode.py` (e.g. the
multi-tree gap in "Re-Apply All Trees in Order" above), the wrong palette
persists even after a full app relaunch (quitting and restarting Claude Code, a
new terminal tab, a fresh shell). It looks like the fix didn't land, or landed
somewhere else.

**Visual signature:** a Dracula Pro *dark*-mode accent color (bright cyan/purple)
rendering on a *light* terminal background reads as washed-out, low-contrast
text — that combination alone (dark-palette accent colors, light background) is
enough to recognize this class of bug from a screenshot, no logs required.

**Cause:** `koopa` runs from an editable install (`koopa` resolves straight to
`lang/python/src/koopa/...`, not a built/copied package), so an edited
`color_mode.py` is live on the very next invocation — the code fix itself is not
the missing piece. What's missing is a *trigger*. `main()`'s fast path
(`color_mode.py`, near the top) returns immediately whenever
`~/.cache/koopa/color-mode-applied` already equals the current OS mode, before
any apply logic — fixed or not — runs. If the marker was already caught up to
the current mode (written by the *old*, buggy code's last incomplete run), the
fixed code never gets invoked at all until something changes the marker or the
OS mode actually flips. A relaunch of the app reads whatever's already on disk;
it does not re-invoke the configurer.

**Fix:** force one real re-run, then re-check:
```sh
rm ~/.cache/koopa/color-mode-applied
koopa configure user color-mode --verbose
grep '"theme"' ~/.claude/settings.json
```
Per "Never Verify by Re-Running the Installer from an Agent Session" above, this
must be run by the user in a normal terminal, never from inside the agent
session that produced the fix — the same stale-`KOOPA_COLOR_MODE` risk applies.

## Ghostty: Symlink Creation Must Run Pre-Chezmoi, Not Post

**Symptom:** a Ghostty window renders the wrong palette, or a hardcoded
selection color, no matter how many times color mode flips. `koopa configure
user color-mode` and `koopa configure user dotfiles` both report success. No
error appears anywhere.

**Root cause (2026-08):** `_configure_dracula_pro_post()` in
[opt/dotfiles/install](../../../opt/dotfiles/install) used to build the
`~/.config/ghostty/themes/` symlinks (`Dracula Pro`, `Dracula Pro Alucard`,
etc.) in the **post**-chezmoi phase, alongside kitty/wezterm/atuin/btop. That
placement is correct for those four tools, because their own templates never
read the symlinks back. It is wrong for Ghostty, because
`chezmoi/dot_config/ghostty/config.tmpl` `stat`s
`~/.config/ghostty/themes/Dracula Pro` **during the chezmoi apply that runs
before `_post`** to decide which theme names to emit. Every install therefore
rendered `config.tmpl` against the symlink state left by the *previous*
install, one full cycle behind. On the very first install on a machine, the
pre-render `stat` sees nothing at all and silently falls back to free
`Dracula`/`Atom One Light` — no error, because the `stat` guard is designed to
fail open.

**Fix:** move the Ghostty symlink block into `_configure_dracula_pro()` (the
pre-chezmoi phase), so the render that reads the directory always sees the
current cycle's links. General rule for this installer: any block whose
*output* is read back by a chezmoi template belongs in the pre-chezmoi phase;
blocks whose output nothing reads back (the common case) belong in `_post`,
where they can rely on chezmoi-created parent directories already existing.

**A second, independent defect found in the same file:** `config.tmpl` also
emitted a static `selection-background = #5B5575` whenever the Dracula Pro
symlinks were present. Ghostty applies main-config keys over theme-file values,
so that one static hex won and was visibly wrong in one of the two modes.
Ghostty accepts `light:`/`dark:` conditional values only for the `theme` key
itself; any other static color key in the main config is wrong in one mode by
construction. Fix: delete the override and let each theme file's own
`selection-background`/`selection-foreground` pair apply. The literal was also
a `theme-colors.md` violation — a Dracula-Pro-context hex with no allowlisted
match and no runtime derivation.

## Ghostty Caches Theme Resolution Per-Window; `reload_config` Cannot Fix an Already-Open Window

**Symptom:** after fixing a real Ghostty config bug (see above, or any fix to
`config.tmpl`), one specific long-lived window stays on the old, wrong palette
even after `koopa configure user dotfiles` re-renders the file correctly on
disk and `grep` confirms the fix landed. Pressing Ghostty's `reload_config`
keybind (default `⌘⇧,` on macOS) in that window visibly does nothing. A **new**
window or a fresh session opened in the same running Ghostty binary picks up
the fix immediately and correctly follows the OS's current light/dark state.

**Cause:** Ghostty resolves the `theme = "light:X,dark:Y"` directive once, at
the time a given window/surface is created. `reload_config` re-parses the
config file and applies most keys live, but the light/dark theme resolution
for that window's already-existing surface is not among them. The window keeps
whatever it resolved at creation time, correct or not, indefinitely.

**This is a Ghostty-side limitation, not a koopa bug.** No koopa code sets or
caches this state. Confirming it does not require more digging: open a new
window (`⌘N`, not a new tab) in the same running Ghostty process. If the new
window is correct while the old one is not, the fix already works; only the
stale window needs to catch up.

**Fix:** quit and relaunch the stuck window, or the whole Ghostty app. There is
no config-only or koopa-side remedy for a window that already resolved the
wrong theme before the fix landed.
