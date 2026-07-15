---
name: koopa-color-mode
description: >
  How koopa propagates and applies dark/light color mode across SSH, tmux, shells,
  and chezmoi-rendered theme files. Use when debugging wrong-palette or stale-theme
  symptoms after a dark↔light flip, working on color-mode sync jobs or watchers,
  editing the chezmoi color-mode apply path, or investigating why bat/starship/delta
  renders the wrong theme while fzf/LS_COLORS look correct.
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

## Never Verify by Re-Running the Installer from an Agent Session

Never run `koopa configure user dotfiles` from inside a Claude Code (or other
long-running agent) session to verify color-mode rendering. The session's
`KOOPA_COLOR_MODE` is frozen at the value it had when the session started — running
the installer from that session clobbers the user's files to the wrong palette.

To verify rendering without risk: check rendered files' content with `grep` or `cat`.
Do not trigger a re-render.
