"""Homebrew management functions.

Converted from Bash functions: brew-prefix, brew-version, brew-doctor,
brew-outdated, brew-upgrade-brews, brew-dump-brewfile, brew-reset-core-repo,
brew-reset-permissions, brew-uninstall-all-brews, brew-install-brewfile,
brew-list-formulae, brew-list-casks, brew-info, brew-fix-completion-dirs, etc.
"""

import os
import subprocess
import sys
import threading

from koopa.prefix import koopa_prefix
from koopa.system import safe_build_env
from koopa.xdg import xdg_config_home

_SUDO_KEEPALIVE_INTERVAL_SECONDS = 50

# Shell completion directories a cask's `generate_completions_from_executable`
# stanza can write to, relative to the Homebrew prefix. See
# ``_ensure_completion_dirs`` for why these must exist before a cask install.
_COMPLETION_DIRS = (
    ("etc", "bash_completion.d"),
    ("share", "zsh", "site-functions"),
    ("share", "fish", "vendor_completions.d"),
    ("share", "pwsh", "completions"),
)


def _user_curlrc_path() -> str | None:
    """Return the first curl config curl itself would load, if any exists.

    Mirrors curl's own lookup order: ``$CURL_HOME/.curlrc``, then
    ``<xdg_config_home>/curlrc``, then ``~/.curlrc``.

    Returns
    -------
    str | None
        Absolute path to the first curl config found, or None if none exists.
    """
    candidates = []
    curl_home = os.environ.get("CURL_HOME")
    if curl_home:
        candidates.append(os.path.join(curl_home, ".curlrc"))
    candidates.append(os.path.join(xdg_config_home(), "curlrc"))
    candidates.append(os.path.expanduser("~/.curlrc"))
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate
    return None


def _brew_curlrc_fallback() -> str:
    """Return the path to koopa's own curlrc, shipped with the repo.

    Used only when the user has no curl config of their own (see
    ``_user_curlrc_path``). A curl transfer with no timeout can block forever
    on a connection that stays open but stops delivering bytes -- not just
    behind a corporate TLS-inspecting proxy, but on any network path where a
    connection can go silently idle without a RST or FIN (a home router NAT
    timeout, a flaky wifi drop). Homebrew's own curl invocation passes
    ``--retry`` but no timeout, so a stall never becomes an error for
    ``--retry`` to act on.

    ``etc/koopa/homebrew-curlrc`` sets the same ``connect_timeout``/
    ``speed_limit``/``speed_time`` defaults koopa already uses for its own
    downloads (see ``koopa.download.download_with_mirror``), so both download
    paths share one stall policy. It is a static file checked into the repo,
    the same way ``etc/koopa/app.json`` is -- not written or regenerated at
    runtime.

    Returns
    -------
    str
        Absolute path to the curlrc file.
    """
    return os.path.join(koopa_prefix(), "etc", "koopa", "homebrew-curlrc")


def _brew_env() -> dict[str, str]:
    """Return an environment that forbids interactive Homebrew prompts.

    Homebrew blocks on tty stdin for confirmations (cask reinstalls that shell
    out to ``sudo``, tap migrations, and similar). During a koopa update the
    build-progress context redirects stdout and stderr to a log file, so such a
    prompt is invisible and the process hangs forever. ``NONINTERACTIVE`` makes
    brew refuse to prompt and fail fast instead.

    Also points ``HOMEBREW_CURLRC`` at the user's own curl config when one
    exists (see ``_user_curlrc_path``). koopa's own dotfiles ship a
    ``connect-timeout``/``speed-limit``/``speed-time`` stall guard in
    ``~/.curlrc`` (``opt/dotfiles/chezmoi/dot_curlrc.tmpl``), so this reuses
    that file directly rather than duplicating its settings. Falls back to a
    minimal koopa-generated config (see ``_brew_curlrc_fallback``) only when no
    user curl config exists, so the stall guard still applies unconditionally.
    Does nothing if the caller already set ``HOMEBREW_CURLRC`` themselves.

    Returns
    -------
    dict[str, str]
        A build-safe environment (see ``koopa.system.safe_build_env``) with
        the non-interactive flags set.
    """
    env = safe_build_env()
    env["NONINTERACTIVE"] = "1"
    env["HOMEBREW_NO_ENV_HINTS"] = "1"
    # Suppresses the implicit auto-update brew runs before install/reinstall/
    # cleanup; does NOT block the explicit ``brew update`` step.
    env["HOMEBREW_NO_AUTO_UPDATE"] = "1"
    env.setdefault("HOMEBREW_CURLRC", _user_curlrc_path() or _brew_curlrc_fallback())
    return env


def _brew(*args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """Run a brew command non-interactively with no tty stdin.

    Parameters
    ----------
    *args : str
        Positional arguments to pass to the ``brew`` command.
    capture : bool, optional
        If True, capture stdout and stderr instead of streaming them.

    Returns
    -------
    subprocess.CompletedProcess
        The completed brew subprocess.
    """
    cmd = ["brew", *args]
    return subprocess.run(
        cmd,
        capture_output=capture,
        text=True,
        check=True,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )


def _sudo_authenticate() -> None:
    """Prompt for sudo authentication once, up front.

    Raises
    ------
    PermissionError
        If authentication fails or is cancelled.
    """
    try:
        subprocess.run(["sudo", "-v"], check=True)
    except subprocess.CalledProcessError as exc:
        msg = "Sudo authentication failed or was cancelled; aborting cask upgrade."
        raise PermissionError(msg) from exc


def _sudo_keepalive_start() -> tuple[threading.Event, threading.Thread]:
    """Start a background thread that refreshes the sudo timestamp.

    Homebrew shells out to ``sudo`` separately for each cask's uninstall and
    install steps. The default sudo timestamp cache lasts 5 minutes, which a
    multi-cask upgrade run can easily exceed, so later casks would otherwise
    re-trigger authentication (Touch ID or a password prompt) instead of
    reusing the credential from ``_sudo_authenticate``. This refreshes that
    timestamp non-interactively, so it never prompts on its own.

    Returns
    -------
    tuple[threading.Event, threading.Thread]
        A handle to pass to ``_sudo_keepalive_stop`` when the run is done.
    """
    stop_event = threading.Event()

    def _refresh() -> None:
        while not stop_event.wait(_SUDO_KEEPALIVE_INTERVAL_SECONDS):
            subprocess.run(
                ["sudo", "-n", "-v"],
                check=False,
                capture_output=True,
                stdin=subprocess.DEVNULL,
            )

    thread = threading.Thread(target=_refresh, daemon=True)
    thread.start()
    return stop_event, thread


def _sudo_keepalive_stop(handle: tuple[threading.Event, threading.Thread]) -> None:
    """Stop a background refresher started by ``_sudo_keepalive_start``.

    Parameters
    ----------
    handle : tuple[threading.Event, threading.Thread]
        The event and thread pair returned by ``_sudo_keepalive_start``.
    """
    stop_event, thread = handle
    stop_event.set()
    thread.join(timeout=2)


def brew_prefix() -> str:
    """Get Homebrew prefix.

    Returns
    -------
    str
        Homebrew's installation prefix directory.
    """
    result = _brew("--prefix")
    return result.stdout.strip()


def brew_version() -> str:
    """Get Homebrew version.

    Returns
    -------
    str
        Homebrew's version string.
    """
    result = _brew("--version")
    return result.stdout.strip().splitlines()[0]


def brew_doctor() -> str:
    """Run brew doctor.

    Returns
    -------
    str
        Output of ``brew doctor``.
    """
    result = subprocess.run(
        ["brew", "doctor"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def brew_outdated() -> list[str]:
    """List outdated formulae.

    Returns
    -------
    list[str]
        Names of formulae with an available upgrade.
    """
    result = _brew("outdated")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_upgrade() -> None:
    """Upgrade all Homebrew formulae and casks."""
    from koopa.system import is_macos

    _brew("update", capture=False)
    if is_macos():
        brew_upgrade_casks()
    brew_upgrade_brews()
    _brew("cleanup", capture=False)


def _ensure_completion_dirs() -> None:
    """Pre-create the shell completion directories Homebrew's cask sandbox needs.

    Homebrew 6.0.20 sandboxed cask artifact steps with ``sandbox-exec``
    (macOS). The ``generate_completions_from_executable`` stanza's
    ``install_phase`` allows writes to each completion directory itself
    (``sandbox.allow_write_path(directory)``, a ``subpath`` rule), but the
    write that actually happens is ``output_path.dirname.mkpath`` -- creating
    the directory, not just writing inside an existing one. When a completion
    directory has never been created before (``share/pwsh/completions`` is
    the common case; nothing else on a fresh Homebrew install writes there),
    the sandbox denies the parent-directory ``mkdir`` with ``EPERM``, and the
    cask install degrades to a caught warning:
    ``Operation not permitted @ dir_s_mkdir - <prefix>/share/pwsh``. No
    completion file is ever written for that shell.

    Creating these directories ahead of time is not a workaround for a
    Homebrew bug so much as restoring an invariant Homebrew's own installed
    manifest already assumes -- ``Library/Homebrew/keg.rb`` lists
    ``share/pwsh`` and ``share/pwsh/completions`` among the directories every
    keg link expects to exist. bash, zsh, and fish never hit this because
    their target directories already exist on a standard Homebrew install.

    Never raises: a directory koopa cannot create (permissions, a stale file
    where a directory belongs) must not abort a cask upgrade over a
    completions nicety.
    """
    prefix = brew_prefix()
    for parts in _COMPLETION_DIRS:
        path = os.path.join(prefix, *parts)
        try:
            os.makedirs(path, exist_ok=True)
        except OSError:
            continue


def brew_fix_completion_dirs() -> None:
    """Create the shell completion directories a cask install may need.

    Public entry point for ``_ensure_completion_dirs``, reachable via
    ``koopa app brew fix-completion-dirs`` for repairing a machine
    immediately, without waiting for the next ``koopa update``.
    """
    _ensure_completion_dirs()


def brew_upgrade_casks() -> None:
    """Upgrade outdated casks detected via --greedy on macOS."""
    _ensure_completion_dirs()
    result = subprocess.run(
        ["brew", "outdated", "--cask", "--greedy"],
        capture_output=True,
        text=True,
        check=False,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )
    casks = []
    for line in result.stdout.strip().splitlines():
        if not line or "(latest)" in line:
            continue
        casks.append(line.split()[0])

    if not casks:
        return

    # Some casks such as font-fira-mono are reported as outdated by brew even
    # though they are effectively versionless and already at the current release.
    # Reinstalling those repeatedly produces churn without a real upgrade, so skip
    # them when Homebrew's structured JSON confirms the installed and current
    # versions are identical.
    json_result = subprocess.run(
        ["brew", "outdated", "--cask", "--greedy", "--json=v2"],
        capture_output=True,
        text=True,
        check=False,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )
    try:
        import json

        payload = json.loads(json_result.stdout or "{}")
    except (TypeError, ValueError):
        payload = {}

    skipped_casks = {
        entry.get("name")
        for entry in payload.get("casks", [])
        if isinstance(entry, dict)
        and entry.get("name")
        and entry.get("installed_versions") == [entry.get("current_version")]
        and entry.get("current_version") in {"latest", None}
    }
    if skipped_casks:
        casks = [cask for cask in casks if cask not in skipped_casks]
    if not casks:
        return
    from koopa.system import has_sudo

    if not has_sudo():
        msg = (
            "Sudo is required to upgrade casks but is not available.\n"
            "Elevate permissions via admin portal first, then retry."
        )
        raise PermissionError(msg)
    from koopa.progress import note, set_status
    from koopa.text import plural

    n = len(casks)
    note(f"{n} outdated {plural(n, 'cask')}: {', '.join(casks)}")
    _sudo_authenticate()
    keepalive = _sudo_keepalive_start()
    try:
        # Reinstall every cask in a single brew invocation instead of looping
        # one-by-one: each separate `brew` call pays its own Ruby interpreter
        # startup and dependency-resolution cost, which dominates wall-clock
        # time on a long cask list. Homebrew still attempts every cask in the
        # list even if one fails partway through, so this is not a regression
        # in failure isolation -- if anything the old per-cask loop was worse,
        # since check=True aborted the whole remaining list on the first
        # failure instead of continuing to the rest.
        set_status(f"reinstalling {n} {plural(n, 'cask')}")
        _brew("reinstall", "--cask", "--force", *casks, capture=False)
    finally:
        # Run cask-specific post-hooks regardless of the batch's overall exit
        # status: Homebrew attempts every cask in the list even if another one
        # in the batch fails, and both hooks are idempotent/harmless to run
        # against an unchanged install if the targeted cask itself failed.
        if "r" in casks:
            try:
                from koopa.r import configure_r_environ, configure_r_makevars

                configure_r_environ()
                configure_r_makevars()
            except Exception as exc:
                print(
                    f"Warning: failed to configure R environment after cask upgrade: {exc}",
                    file=sys.stderr,
                )
        for cask in casks:
            if cask.startswith("gpg-suite"):
                plist = os.path.expanduser(
                    "~/Library/LaunchAgents/org.gpgtools.updater.plist",
                )
                if os.path.isfile(plist):
                    subprocess.run(["launchctl", "unload", "-w", plist], check=False)
        _sudo_keepalive_stop(keepalive)


def brew_upgrade_brews() -> None:
    """Upgrade outdated Homebrew formulae."""
    result = subprocess.run(
        ["brew", "outdated", "--formula"],
        capture_output=True,
        text=True,
        check=True,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )
    brews = [x for x in result.stdout.strip().splitlines() if x]
    if not brews:
        return
    from koopa.progress import note, set_status
    from koopa.text import plural

    n = len(brews)
    note(f"{n} outdated {plural(n, 'brew')}: {', '.join(brews)}")
    for i, brew_name in enumerate(brews, start=1):
        set_status(f"upgrading brews [{i}/{n}] {brew_name}")
        _brew("reinstall", "--force", brew_name, capture=False)


def brew_untap_deprecated() -> None:
    """Remove deprecated Homebrew taps."""
    deprecated_taps = [
        "homebrew/bundle",
        "homebrew/cask",
        "homebrew/cask-drivers",
        "homebrew/cask-fonts",
        "homebrew/cask-versions",
        "homebrew/core",
    ]
    for tap in deprecated_taps:
        result = subprocess.run(
            ["brew", "--repo", tap],
            capture_output=True,
            text=True,
            check=False,
            stdin=subprocess.DEVNULL,
            env=_brew_env(),
        )
        tap_prefix = result.stdout.strip()
        if tap_prefix and os.path.isdir(tap_prefix):
            subprocess.run(
                ["brew", "untap", tap],
                check=False,
                stdin=subprocess.DEVNULL,
                env=_brew_env(),
            )


def brew_doctor_filtered() -> None:
    """Run brew doctor with stray-lib and path checks disabled."""
    disabled_checks = {
        "check_for_stray_dylibs",
        "check_for_stray_headers",
        "check_for_stray_las",
        "check_for_stray_pcs",
        "check_for_stray_static_libs",
        "check_user_path_1",
        "check_user_path_2",
        "check_user_path_3",
    }
    result = subprocess.run(
        ["brew", "doctor", "--list-checks"],
        capture_output=True,
        text=True,
        check=False,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )
    all_checks = [x for x in result.stdout.strip().splitlines() if x]
    enabled_checks = [c for c in all_checks if c not in disabled_checks]
    if not enabled_checks:
        return
    subprocess.run(["brew", "config"], check=False, stdin=subprocess.DEVNULL, env=_brew_env())
    subprocess.run(
        ["brew", "doctor", *enabled_checks],
        check=False,
        stdin=subprocess.DEVNULL,
        env=_brew_env(),
    )


def brew_dump_brewfile(path: str = "Brewfile") -> None:
    """Dump installed formulae to a Brewfile.

    Parameters
    ----------
    path : str, optional
        Destination path for the generated Brewfile.
    """
    _brew("bundle", "dump", "--file", path, "--force", capture=False)


def brew_reset_core_repo() -> None:
    """Reset Homebrew core repository."""
    prefix = brew_prefix()
    core = os.path.join(prefix, "Library", "Taps", "homebrew", "homebrew-core")
    if os.path.isdir(core):
        subprocess.run(
            ["git", "-C", core, "fetch", "--unshallow"],
            capture_output=True,
            check=True,
        )
        subprocess.run(
            ["git", "-C", core, "checkout", "master"],
            capture_output=True,
            check=True,
        )


def brew_reset_permissions() -> None:
    """Reset Homebrew directory permissions."""
    from koopa.system import has_sudo

    if not has_sudo():
        msg = (
            "Sudo is required to reset Homebrew permissions but is not available.\n"
            "Elevate permissions via admin portal first, then retry."
        )
        raise PermissionError(msg)
    prefix = brew_prefix()
    user = os.environ.get("USER", "")
    if user:
        subprocess.run(
            ["sudo", "chown", "-R", f"{user}:admin", prefix],
            check=True,
            stdin=subprocess.DEVNULL,
        )


def brew_uninstall_all_brews() -> None:
    """Uninstall all Homebrew formulae."""
    result = _brew("list", "--formula", "-1")
    formulae = [x for x in result.stdout.strip().splitlines() if x]
    if formulae:
        _brew("uninstall", "--force", *formulae, capture=False)


def brew_install_brewfile(path: str = "Brewfile") -> None:
    """Install from a Brewfile.

    Parameters
    ----------
    path : str, optional
        Path to the Brewfile to install from.
    """
    _brew("bundle", "install", "--file", path, capture=False)


def brew_list_formulae() -> list[str]:
    """List installed formulae.

    Returns
    -------
    list[str]
        Names of installed formulae.
    """
    result = _brew("list", "--formula", "-1")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_list_casks() -> list[str]:
    """List installed casks.

    Returns
    -------
    list[str]
        Names of installed casks.
    """
    result = _brew("list", "--cask", "-1")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_info(formula: str) -> str:
    """Get info about a formula.

    Parameters
    ----------
    formula : str
        Name of the formula to look up.

    Returns
    -------
    str
        Output of ``brew info`` for the formula.
    """
    result = _brew("info", formula)
    return result.stdout.strip()
