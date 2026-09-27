"""Configure dotfiles."""

import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Iterator
from contextlib import contextmanager

from koopa.alert import alert_info, alert_note, warn
from koopa.build import locate
from koopa.git import git_pull_safe
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.system import os_appearance_mode
from koopa.text import plural
from koopa.xdg import xdg_cache_home


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


def _chezmoi_entry_state(
    chezmoi: str,
    source: str,
    env: dict[str, str],
    config: str | None = None,
) -> dict[str, dict[str, object]]:
    """Return chezmoi's last-applied record for every target it has written.

    Read-only.  Keys are absolute paths; values are the raw ``entryState``
    records from ``chezmoi state dump`` (each carries at least ``type`` and,
    for a file or symlink, ``contentsSHA256``).  Returns an empty dict if the
    source is absent or the probe fails — an empty map makes every existing
    path look user-owned to ``_is_chezmoi_copy``, which is the safe default
    for a shield that must never delete a file it can't positively identify.

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
    dict[str, dict[str, object]]
        Map of absolute path to its ``entryState`` record.
    """
    if not os.path.isdir(source):
        return {}
    args = [chezmoi, "state", "dump", f"--source={source}", "--format=json"]
    if config is not None:
        args.append(f"--config={config}")
    try:
        result = subprocess.run(args, env=env, capture_output=True, text=True, check=True)
    except (subprocess.CalledProcessError, OSError):
        return {}
    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError:
        return {}
    entry_state = data.get("entryState")
    if not isinstance(entry_state, dict):
        return {}
    return entry_state


def _is_chezmoi_copy(path: str, entry: dict[str, object] | None) -> bool:
    """Return whether *path* still holds exactly what chezmoi last wrote there.

    A file matches when its content sha256 equals the entry's
    ``contentsSHA256``.  A symlink matches when the sha256 of its link target
    string equals the same field (chezmoi hashes the target string, not
    followed content).  A missing entry, a type mismatch (e.g. a symlink
    where chezmoi last wrote a file), or a read error all count as "not
    chezmoi's copy" — the safe direction for a shield deciding what to keep.

    Parameters
    ----------
    path : str
        Absolute path to check.
    entry : dict[str, object] | None
        This path's ``entryState`` record, or ``None`` if chezmoi has no
        record of it.

    Returns
    -------
    bool
        ``True`` if *path* is unmodified since chezmoi last wrote it.
    """
    if entry is None:
        return False
    expected = entry.get("contentsSHA256")
    if not isinstance(expected, str):
        return False
    entry_type = entry.get("type")
    if entry_type == "symlink" and os.path.islink(path):
        return hashlib.sha256(os.readlink(path).encode()).hexdigest() == expected
    if entry_type == "file" and os.path.isfile(path) and not os.path.islink(path):
        try:
            with open(path, "rb") as fh:
                actual = hashlib.sha256(fh.read()).hexdigest()
        except OSError:
            return False
        return actual == expected
    return False


def _user_owned_remove_paths(
    home: str,
    remove_targets: set[str],
    entry_state: dict[str, dict[str, object]],
) -> list[str]:
    """Return existing paths under *remove_targets* that are not chezmoi's copy.

    A ``.chezmoiremove`` entry may be a file or a directory; a directory is
    walked (without following symlinks) so each file or symlink underneath is
    checked individually against ``entry_state``.  A symlink is treated as a
    leaf, never descended into — its own record is checked, not its target's
    content.

    Parameters
    ----------
    home : str
        Absolute path to the user's home directory.
    remove_targets : set[str]
        Target paths, relative to *home*, that a tree's ``.chezmoiremove``
        deletes.
    entry_state : dict[str, dict[str, object]]
        Map of absolute path to its ``entryState`` record, from
        ``_chezmoi_entry_state``.

    Returns
    -------
    list[str]
        Absolute paths that exist and are not chezmoi's unmodified copy.
    """
    kept: list[str] = []
    for target in sorted(remove_targets):
        abs_target = os.path.join(home, target.rstrip("/"))
        if os.path.islink(abs_target) or os.path.isfile(abs_target):
            if not _is_chezmoi_copy(abs_target, entry_state.get(abs_target)):
                kept.append(abs_target)
            continue
        if not os.path.isdir(abs_target):
            continue
        for root, dirnames, filenames in os.walk(abs_target, followlinks=False):
            leaf_dirnames = [d for d in dirnames if os.path.islink(os.path.join(root, d))]
            for name in leaf_dirnames:
                dirnames.remove(name)
            for name in [*leaf_dirnames, *filenames]:
                path = os.path.join(root, name)
                if not _is_chezmoi_copy(path, entry_state.get(path)):
                    kept.append(path)
    return kept


@contextmanager
def _shield_user_files(tree_label: str, paths: list[str]) -> Iterator[None]:
    """Temporarily move user-owned files out of the way of a chezmoi apply.

    Moves each path in *paths* into a fresh directory under
    ``<xdg_cache_home>/koopa``, preserving its path relative to ``~`` so
    nested targets round-trip cleanly, then restores every path once the
    ``with`` block exits (success or exception).  A path recreated by the
    tree's own install script during the block is left alone at restore
    time — the stashed copy stays under the cache directory instead of
    silently overwriting whatever the tree just wrote.

    Parameters
    ----------
    tree_label : str
        Human-readable label for this tree (e.g. ``"main"``, ``"work"``,
        ``"private"``), used in warning messages.
    paths : list[str]
        Absolute paths to shield, from ``_user_owned_remove_paths``.

    Yields
    ------
    None
        Nothing; this is a plain context manager.
    """
    if not paths:
        yield
        return
    n = len(paths)
    warn(
        f"{tree_label} tree's .chezmoiremove would delete {n} {plural(n, 'file')} "
        "not written by chezmoi; keeping:"
    )
    home = os.path.expanduser("~")
    cache_dir = os.path.join(xdg_cache_home(), "koopa")
    os.makedirs(cache_dir, exist_ok=True)
    stash_dir = tempfile.mkdtemp(prefix="koopa-dotfiles-shield-", dir=cache_dir)
    stashed: list[tuple[str, str]] = []
    for path in paths:
        print(f"  {path}", file=sys.stderr)
        stash_path = os.path.join(stash_dir, os.path.relpath(path, home))
        os.makedirs(os.path.dirname(stash_path), exist_ok=True)
        shutil.move(path, stash_path)
        stashed.append((path, stash_path))
    try:
        yield
    finally:
        any_left = False
        for original, stash_path in stashed:
            if os.path.lexists(original):
                any_left = True
                warn(
                    f"{tree_label} tree recreated {original}; your prior copy stays at "
                    f"{stash_path}."
                )
                continue
            os.makedirs(os.path.dirname(original), exist_ok=True)
            shutil.move(stash_path, original)
        if any_left:
            alert_note(f"Shielded copies kept under {stash_dir}.")
        else:
            shutil.rmtree(stash_dir, ignore_errors=True)


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
    main_removes = _chezmoiremove_targets(chezmoi, main_source, env)
    main_state = _chezmoi_entry_state(chezmoi, main_source, env)
    main_shielded = _user_owned_remove_paths(home, main_removes, main_state)
    with _shield_user_files("main", main_shielded):
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
        work_state = _chezmoi_entry_state(chezmoi, work_source, env, config=wcfg)
        work_shielded = _user_owned_remove_paths(home, work_removes, work_state)
        with _shield_user_files("work", work_shielded):
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
        private_state = _chezmoi_entry_state(chezmoi, private_source, env, config=pcfg)
        private_shielded = _user_owned_remove_paths(home, private_removes, private_state)
        with _shield_user_files("private", private_shielded):
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
