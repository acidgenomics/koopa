"""Configure dotfiles."""

import os
import subprocess
import sys

from koopa.alert import alert_info, alert_note, warn
from koopa.build import locate
from koopa.git import git_pull_safe
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.system import os_appearance_mode
from koopa.text import plural


def _chezmoi_managed(
    chezmoi: str,
    source: str,
    env: dict[str, str],
    config: str | None = None,
) -> set[str]:
    """Return the set of target paths (relative to ~) a chezmoi tree manages.

    Read-only.  ``config`` MUST be passed for any tree whose chezmoi.toml
    defines a non-default persistentState (the work tree does) so ``managed``
    reads the same state DB the install script applies.  Returns an empty set
    if the source is absent or the probe fails — a probe must never block the
    configure run.

    Parameters
    ----------
    chezmoi : str
        Path to the ``chezmoi`` executable.
    source : str
        Root directory of this tree's chezmoi source directory.
    env : dict[str, str]
        Environment variables to pass to the ``chezmoi`` subprocess call.
    config : str | None, optional
        Path to this tree's ``chezmoi.toml``, or ``None`` to omit
        ``--config`` from the ``chezmoi`` invocation.

    Returns
    -------
    set[str]
        Target paths, relative to ``~``, that this tree manages.
    """
    if not os.path.isdir(source):
        return set()
    args = [chezmoi, "managed", f"--source={source}"]
    if config is not None:
        args.append(f"--config={config}")
    args.extend(["-i", "files,symlinks"])
    try:
        result = subprocess.run(args, env=env, capture_output=True, text=True, check=True)
    except (subprocess.CalledProcessError, OSError):
        return set()
    return {line.strip() for line in result.stdout.splitlines() if line.strip()}


def _print_chezmoi_status(
    chezmoi: str,
    source: str,
    env: dict[str, str],
    config: str | None = None,
) -> None:
    """Print a concise per-file change summary for a chezmoi tree (read-only).

    Uses ``chezmoi status`` porcelain (``XY <path>``).  Always shown regardless
    of verbosity so the user sees which targets a tree will change.  Silent on
    probe failure.

    Parameters
    ----------
    chezmoi : str
        Path to the ``chezmoi`` executable.
    source : str
        Root directory of this tree's chezmoi source directory.
    env : dict[str, str]
        Environment variables to pass to the ``chezmoi`` subprocess call.
    config : str | None, optional
        Path to this tree's ``chezmoi.toml``, or ``None`` to omit
        ``--config`` from the ``chezmoi`` invocation.
    """
    if not os.path.isdir(source):
        return
    args = [chezmoi, "status", f"--source={source}"]
    if config is not None:
        args.append(f"--config={config}")
    try:
        result = subprocess.run(args, env=env, capture_output=True, text=True, check=True)
    except (subprocess.CalledProcessError, OSError):
        return
    lines = [ln for ln in result.stdout.splitlines() if ln.strip()]
    if not lines:
        alert_note(f"No pending changes: {source}")
        return
    alert_info(f"Pending changes ({len(lines)}): {source}")
    for ln in lines:
        print(f"  {ln}", file=sys.stderr)


def _warn_cross_tree_overlap(
    tree_label: str,
    main_targets: set[str],
    tree_targets: set[str],
) -> None:
    """Warn when a later tree manages targets the main tree also manages.

    The later (work/private) ``chezmoi apply`` overwrites the main tree's
    version of any shared target.  Emit one visible warning listing each
    colliding relative target path.

    Parameters
    ----------
    tree_label : str
        Human-readable label for the later tree (e.g. ``"work"`` or
        ``"private"``), used in the warning message.
    main_targets : set[str]
        Target paths (relative to ``~``) the main tree manages.
    tree_targets : set[str]
        Target paths (relative to ``~``) the later tree manages.
    """
    overlap = sorted(main_targets & tree_targets)
    if not overlap:
        return
    n = len(overlap)
    warn(
        f"{tree_label} tree overrides the main tree for "
        f"{n} {plural(n, 'target')}; the {tree_label} version wins:"
    )
    for target in overlap:
        print(f"  {target}", file=sys.stderr)


def _chezmoiremove_targets(
    chezmoi: str,
    source: str,
    env: dict[str, str],
    config: str | None = None,
) -> set[str]:
    """Return the set of target paths a tree's ``.chezmoiremove`` deletes.

    Read-only.  ``.chezmoiremove`` supports Go templates (e.g. an OS-gated
    block), so it must be rendered via ``chezmoi execute-template`` rather than
    read raw.  Returns an empty set if the file is absent or the probe fails —
    a probe must never block the configure run.

    Parameters
    ----------
    chezmoi : str
        Path to the ``chezmoi`` executable.
    source : str
        Root directory of this tree's chezmoi source directory.
    env : dict[str, str]
        Environment variables to pass to the ``chezmoi`` subprocess call.
    config : str | None, optional
        Path to this tree's ``chezmoi.toml``, or ``None`` to omit
        ``--config`` from the ``chezmoi`` invocation.

    Returns
    -------
    set[str]
        Target paths this tree's ``.chezmoiremove`` deletes.
    """
    remove_file = os.path.join(source, ".chezmoiremove")
    if not os.path.isfile(remove_file):
        return set()
    args = [chezmoi, "execute-template", "--file", f"--source={source}"]
    if config is not None:
        args.append(f"--config={config}")
    args.append(remove_file)
    try:
        result = subprocess.run(args, env=env, capture_output=True, text=True, check=True)
    except (subprocess.CalledProcessError, OSError):
        return set()
    targets: set[str] = set()
    for line in result.stdout.splitlines():
        entry = line.strip()
        if not entry or entry.startswith("#"):
            continue
        targets.add(entry.removeprefix("!"))
    return targets


def _warn_remove_manage_conflict(
    tree_label: str,
    main_targets: set[str],
    remove_targets: set[str],
) -> None:
    """Warn when a later tree's removal list targets a main-managed path.

    A ``.chezmoiremove`` entry is often a directory (e.g. ``.claude/skills/foo``)
    while ``chezmoi managed`` lists the files under it (e.g.
    ``.claude/skills/foo/SKILL.md``), so matching must include directory-ancestor
    hits, not just exact equality — a plain set intersection misses this.  Left
    unresolved, the main tree recreates the target on every run and the later
    tree deletes it again, an unbroken tug-of-war.

    Parameters
    ----------
    tree_label : str
        Human-readable label for the later tree (e.g. ``"work"`` or
        ``"private"``), used in the warning message.
    main_targets : set[str]
        Target paths (relative to ``~``) the main tree manages.
    remove_targets : set[str]
        Target paths the later tree's ``.chezmoiremove`` deletes.
    """
    conflicts: list[tuple[str, str]] = []
    for removed in sorted(remove_targets):
        for managed in sorted(main_targets):
            if managed == removed or managed.startswith(removed + "/"):
                conflicts.append((removed, managed))
    if not conflicts:
        return
    n = len(conflicts)
    warn(
        f"{tree_label} tree's .chezmoiremove deletes {n} {plural(n, 'target')} "
        f"the main tree manages; this can never converge:"
    )
    for removed, managed in conflicts:
        print(f"  {tree_label} removes {removed!r}, main manages {managed!r}", file=sys.stderr)


def _check_broken_symlink(tree_label: str, prefix: str) -> None:
    """Raise when a tree's prefix is a symlink whose target no longer exists.

    The "run this tree's install script" checks elsewhere in this module use
    ``os.path.isfile``/``isdir``, which silently return ``False`` through a
    dangling symlink — indistinguishable from the tree simply not being
    configured on this host. That ambiguity is the actual defect: a symlink
    broken by moving or renaming the tree's directory would otherwise skip
    the tree's install script (and everything a chezmoi template elsewhere
    gates on "does this prefix exist" via ``stat``, which also follows
    symlinks) with no output at all, indefinitely, on any host that isn't
    re-run through the initial setup flow that would re-create the link.
    Fail loudly instead: a broken symlink here always means misconfiguration,
    never "tree absent," so raise rather than warn-and-continue.

    Parameters
    ----------
    tree_label : str
        Human-readable label for this tree (e.g. ``"work"`` or
        ``"private"``), used in the raised error message.
    prefix : str
        Path to check for a broken symlink.
    """
    if os.path.islink(prefix) and not os.path.isdir(prefix):
        target = os.readlink(prefix)
        msg = (
            f"{tree_label} symlink is broken: {prefix} -> {target} "
            "(target does not exist). Repoint the symlink at the tree's "
            "current location before continuing."
        )
        raise FileNotFoundError(msg)


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure dotfiles for current user.

    Links opt_prefix/dotfiles to the dotfiles config prefix, then runs
    the install script(s).

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"user"``).
    verbose : bool, optional
        Print verbose output.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_dotfiles = os.path.join(opt_prefix(), "dotfiles")
    if not os.path.isdir(opt_dotfiles):
        msg = f"Dotfiles directory not found: {opt_dotfiles}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    dotfiles_work_prefix = os.path.join(home, ".config", "koopa", "dotfiles-work")
    dotfiles_private_prefix = os.path.join(home, ".config", "koopa", "dotfiles-private")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    # Always derive color mode from the OS — never trust inherited env.
    # Long-running processes (agent sessions, old tmux servers) carry stale
    # values that would silently render the wrong palette across all three trees.
    env["KOOPA_COLOR_MODE"] = os_appearance_mode()
    if verbose:
        env["KOOPA_VERBOSE"] = "1"
    if not os.environ.get("KOOPA_DOTFILES_SKIP_PULL"):
        git_pull_safe(opt_dotfiles)
        git_pull_safe(dotfiles_work_prefix)
        git_pull_safe(dotfiles_private_prefix)
    chezmoi = locate("chezmoi")
    main_source = os.path.join(opt_dotfiles, "chezmoi")
    work_source = os.path.join(dotfiles_work_prefix, "chezmoi")
    work_config = os.path.join(dotfiles_work_prefix, "chezmoi.toml")
    private_source = os.path.join(dotfiles_private_prefix, "chezmoi")
    private_config = os.path.join(dotfiles_private_prefix, "chezmoi.toml")
    main_targets = _chezmoi_managed(chezmoi, main_source, env)
    install_script = os.path.join(opt_dotfiles, "install")
    if not os.path.isfile(install_script):
        msg = f"Install script not found: {install_script}"
        raise FileNotFoundError(msg)
    alert_info(f"Running '{install_script}'.")
    _print_chezmoi_status(chezmoi, main_source, env)
    subprocess.run([install_script], check=True, env=env)
    work_install_script = os.path.join(dotfiles_work_prefix, "install")
    _check_broken_symlink("work", dotfiles_work_prefix)
    if os.path.isfile(work_install_script):
        alert_info(f"Running '{work_install_script}'.")
        wcfg = work_config if os.path.isfile(work_config) else None
        work_targets = _chezmoi_managed(chezmoi, work_source, env, config=wcfg)
        _warn_cross_tree_overlap("work", main_targets, work_targets)
        work_removes = _chezmoiremove_targets(chezmoi, work_source, env, config=wcfg)
        _warn_remove_manage_conflict("work", main_targets, work_removes)
        _print_chezmoi_status(chezmoi, work_source, env, config=wcfg)
        subprocess.run([work_install_script], check=True, env=env)
    private_install_script = os.path.join(dotfiles_private_prefix, "install")
    _check_broken_symlink("private", dotfiles_private_prefix)
    if os.path.isfile(private_install_script):
        alert_info(f"Running '{private_install_script}'.")
        pcfg = private_config if os.path.isfile(private_config) else None
        private_targets = _chezmoi_managed(chezmoi, private_source, env, config=pcfg)
        _warn_cross_tree_overlap("private", main_targets, private_targets)
        private_removes = _chezmoiremove_targets(chezmoi, private_source, env, config=pcfg)
        _warn_remove_manage_conflict("private", main_targets, private_removes)
        _print_chezmoi_status(chezmoi, private_source, env, config=pcfg)
        subprocess.run([private_install_script], check=True, env=env)
    # Hot-reload any running tmux server so rewritten color confs take effect
    # without requiring a manual prefix+r or reconnect.  Also warn when the
    # running server predates the newly-installed binary.
    from koopa.tmux import reload_tmux_config, warn_tmux_stale

    reload_tmux_config(env["KOOPA_COLOR_MODE"])
    warn_tmux_stale()
    # Keep the applied-marker in sync with what we just rendered so that
    # color_mode.py's fast-path doesn't skip a corrective re-render later.
    # Without this write, a dotfiles run while the OS is light leaves the
    # marker unchanged (dark) even though the static configs were just frozen
    # light — permanently suppressing correction via 'configure user color-mode'.
    marker_file = os.path.join(home, ".cache", "koopa", "color-mode-applied")
    os.makedirs(os.path.dirname(marker_file), exist_ok=True)
    with open(marker_file, "w") as fh:
        fh.write(env["KOOPA_COLOR_MODE"] + "\n")
