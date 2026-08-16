---
name: koopa-homebrew
description: >-
  Debugging a hung or stalled Homebrew cask/formula reinstall in koopa, the
  HOMEBREW_CURLRC stall-guard fix, curlrc inheritance from the user's own
  ~/.curlrc, and the sudo keep-alive pattern for multi-cask upgrades. Use when
  koopa app brew upgrade hangs, when editing koopa.brew, when adding a new
  Homebrew-related environment guard, or when reasoning about why Homebrew's
  own curl invocation ignores the user's curlrc.
---

# koopa Homebrew

## Why a `brew reinstall --cask` can hang forever

Homebrew's own curl invocation passes `--retry 3` but sets no
`--connect-timeout`, `--speed-limit`, or `--speed-time`. A curl transfer with
those unset can block forever on a connection that stays open (`ESTABLISHED`)
but stops delivering bytes — e.g. a corporate TLS-inspection proxy that drops
a stream without closing the socket. `--retry` never fires, because a stall is
not itself an error for it to retry.

Confirmed live: a `pycharm` cask download sat at 9MB of 1.2GB for 88 minutes.
The `curl` process had burned 0.35s of CPU total across that whole window, and
its TCP socket showed an empty receive queue, with the far end owned by a
corporate proxy tunnel process, not the download host.

Diagnostic recipe (placeholders in `<...>`, not shell variables):
```sh
pgrep -fl "curl|brew"                # find the stuck process tree
stat -f '%z %Sm' <file>.incomplete   # sample size across a sleep — 0 growth = stalled, not slow
lsof -nP -p <curl_pid> -i            # confirm ESTABLISHED with an idle socket
ps -o pid,etime,time -p <curl_pid>   # long ELAPSED, near-zero TIME = waiting on I/O, not working
```

## The only hook Homebrew exposes for curl settings

`HOMEBREW_CURLRC` is the only environment variable Homebrew's curl wrapper
respects for custom directives — confirmed against
`Library/Homebrew/env_config.rb`: only `HOMEBREW_CURLRC`,
`HOMEBREW_CURL_PATH`, `HOMEBREW_CURL_RETRIES`, `HOMEBREW_CURL_VERBOSE` exist.
There is no per-directive variable such as a connect-timeout knob.
`HOMEBREW_CURLRC` takes a file path, not inline directives.

Two constraints on that path, both verified live:
- **Unset** → Homebrew appends `--disable`, which suppresses the user's own
  `~/.curlrc` entirely. Confirmed from a captured hung process:
  `curl --disable --cookie /dev/null ...` with no `--config` at all.
- **Set but pointing at a file that does not exist** → curl hard-fails every
  invocation with exit 26, `"cannot read config from"`. Never set
  `HOMEBREW_CURLRC` to a fixed path without checking `os.path.isfile` first —
  it must never be unconditional.

## The fix: `koopa.brew`

`_brew_env()` in `lang/python/src/koopa/brew.py` sets:
```python
env.setdefault("HOMEBREW_CURLRC", _user_curlrc_path() or _brew_curlrc_fallback())
```
- `_user_curlrc_path()` mirrors curl's own lookup order: `$CURL_HOME/.curlrc`,
  then `<xdg_config_home>/curlrc`, then `~/.curlrc`. Returns the first path
  that exists.
- `_brew_curlrc_fallback()` writes a minimal koopa-generated
  `connect-timeout`/`speed-limit`/`speed-time` file, used only when the user
  has no curlrc of their own. This keeps the guard universal even on a fresh
  koopa install with no dotfiles applied yet.

An earlier iteration parsed a `cacert` directive out of the user's curlrc
into a separately generated file. That was dropped as unneeded complexity
once the design switched to pointing straight at the real file — the real
file already carries everything in it (`cacert`, `proxy`, `referer`,
whatever the user has), with zero parsing needed.

## The permanent fix lives in koopa's own dotfiles, not just the fallback

`opt/dotfiles/chezmoi/dot_curlrc.tmpl` is the durable fix, not the Python
fallback: it ships `speed-limit=1000`/`speed-time=30` alongside the
pre-existing `connect-timeout=60`, a generic, product-neutral `cacert` line
pointing at koopa's own `ca-certificates` XDG output (no corporate-specific
content, so it is safe for the public repo), and a conditional `proxy` line
from `HTTP_PROXY`. Anyone who runs `koopa configure user dotfiles` gets the
stall guard in their real global `~/.curlrc`, covering every tool that reads
curl's default config, not just Homebrew.

`opt/dotfiles/` is its own standalone git clone (see the `koopa-dotfiles`
skill). Editing this template does not auto-commit or auto-roll-out; that
needs its own commit and an `app.json` pin bump, separate from the edit
itself. Apply a change to it narrowly, never with a bare `chezmoi apply`:
```sh
KOOPA_COLOR_MODE=dark chezmoi diff  --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi" ~/.curlrc
KOOPA_COLOR_MODE=dark chezmoi apply --source="${HOME}/.local/share/koopa/opt/dotfiles/chezmoi" ~/.curlrc
```

## Sudo keep-alive for multi-cask upgrades

A separate but related problem: Homebrew shells out to `sudo` separately for
each cask's uninstall and install steps (`pkgutil --forget`, then `installer
-pkg`). macOS's default sudo timestamp cache is 5 minutes. A multi-cask
`koopa app brew upgrade` run can easily outlast that between casks, so a
later cask re-triggers Touch ID or a password prompt instead of reusing the
first one.

Fix, inside `brew_upgrade_casks()`:
```python
_sudo_authenticate()                    # one real sudo -v, inherits the tty — the only intentional prompt
keepalive = _sudo_keepalive_start()      # background thread: sudo -n -v every 50s
try:
    for cask in casks:
        ...
finally:
    _sudo_keepalive_stop(keepalive)      # always stopped, even after a failed reinstall
```

`_sudo_authenticate()` deliberately does not redirect stdin — Touch ID does
not need it, but a password fallback does. `_brew()`'s own calls use
`stdin=subprocess.DEVNULL` to keep Homebrew's own prompts non-interactive;
reusing that on the authentication call would silently break the password
fallback.

Scope: only wired into `brew_upgrade_casks()`, reachable only from `koopa app
brew upgrade` (`_handle_brew_upgrade` in `cli_app.py`), never from the
automated `koopa update` sweep. That boundary matters: `_brew_env()`'s
`NONINTERACTIVE=1` exists specifically because `koopa update`'s
build-progress context redirects stdout/stderr to a log file, making any
interactive prompt invisible and the process hang forever. Wiring the sudo
keep-alive into that path would reintroduce the exact bug this skill opens
with, just for sudo instead of curl.

## Testing pattern

Every `subprocess.run` call in `koopa.brew` goes through the module's own
`subprocess` import, so `patch("koopa.brew.subprocess.run", ...)` catches all
of it: real `brew`/`curl`/`sudo` calls, and the keep-alive thread's own `sudo
-n -v` refresh. A keep-alive test must call `_sudo_keepalive_stop()` (which
does `stop_event.set(); thread.join(timeout=2)`) before asserting, or the
background thread is still parked in `Event.wait(50)` when the test body
finishes — harmless (it is a daemon thread), but leaves nothing to assert
against.
