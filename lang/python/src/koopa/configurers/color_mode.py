"""Configure dark/light color-mode and re-render mode-dependent dotfiles."""

import fcntl
import os
import re
import subprocess
import sys
from datetime import datetime

from koopa.alert import alert_info, alert_note, warn
from koopa.build import locate
from koopa.configurers.dotfiles import _chezmoi_managed
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.system import os_appearance_mode
from koopa.text import plural
from koopa.tmux import reload_tmux_config, warn_tmux_stale

# Chezmoi source-name prefixes that are stripped to get the target name.
_CHEZMOI_STRIP_RE = re.compile(
    r"^(?:private_|readonly_|empty_|encrypted_|exact_|once_|run_|modify_|create_|literal_)*"
)


def _chezmoi_source_to_target(source_root: str, source_path: str) -> str:
    """Derive the chezmoi target path for a given source path.

    Applies chezmoi's standard naming conventions:
      - strip known source-attribute prefixes (private_, readonly_, …)
      - ``dot_`` prefix → ``.`` prefix
      - strip ``.tmpl`` suffix

    Returns an absolute target path under ``~``.

    Parameters
    ----------
    source_root : str
        Root directory of the chezmoi source tree.
    source_path : str
        Absolute path to a file within ``source_root``.

    Returns
    -------
    str
        Absolute target path under the home directory.
    """
    rel = os.path.relpath(source_path, source_root)
    parts = rel.split(os.sep)
    target_parts = []
    for part in parts:
        # Strip .tmpl suffix, attribute prefixes, and dot_ → .
        p = part[:-5] if part.endswith(".tmpl") else part
        p = _CHEZMOI_STRIP_RE.sub("", p)
        p = "." + p[4:] if p.startswith("dot_") else p
        target_parts.append(p)
    return os.path.join(os.path.expanduser("~"), *target_parts)


def _scan_color_mode_candidates(chezmoi_prefix: str) -> list[str]:
    """Return target paths of a tree's own templates that branch on KOOPA_COLOR_MODE.

    Pure discovery for a single tree's source directory: no managed-set filtering,
    no warning.  Each chezmoi tree (main, work, private) carries its own copy of a
    color-mode template (e.g. each tree's own ``dot_claude/settings.json.tmpl``), so
    discovery must run per-tree against that tree's own source -- never once against
    a single merged set.

    The launchd plist and systemd unit are naturally excluded because they don't
    reference KOOPA_COLOR_MODE.

    Parameters
    ----------
    chezmoi_prefix : str
        Root directory of a single chezmoi tree's source directory.

    Returns
    -------
    list[str]
        Target paths (under ``~``) of templates in this tree that branch on
        ``KOOPA_COLOR_MODE``.
    """
    needle = b"KOOPA_COLOR_MODE"
    targets = []
    for dirpath, _dirnames, filenames in os.walk(chezmoi_prefix):
        for name in filenames:
            if not name.endswith(".tmpl"):
                continue
            src_path = os.path.join(dirpath, name)
            try:
                with open(src_path, "rb") as fh:
                    if needle not in fh.read():
                        continue
            except OSError:
                continue
            targets.append(_chezmoi_source_to_target(chezmoi_prefix, src_path))
    return targets


def _discover_color_mode_targets(
    chezmoi_prefix: str, managed: set[str], *, warn_on_drop: bool = True
) -> list[str]:
    """Return the subset of a tree's color-mode candidates that it manages.

    Wraps ``_scan_color_mode_candidates()`` and filters against ``managed`` -- the
    tree's ``chezmoi managed`` output (target paths relative to ``~``), as returned
    by ``_chezmoi_managed()``.  A template's target existing on disk is NOT
    sufficient: ``.chezmoiignore`` can exclude a target conditionally (e.g. when a
    work-tree marker is present) while the file still exists on disk, managed
    instead by another tree.  chezmoi's ``apply`` validates every target argument up
    front and aborts the entire call -- applying nothing -- if even one is
    unmanaged, so an on-disk-only check silently blocks every other target.
    Filtering against ``managed`` is required, not just tidier.

    Warns immediately about every dropped target when ``warn_on_drop`` is true (the
    default) -- appropriate for a single-tree caller.  ``main()``'s multi-tree apply
    passes ``warn_on_drop=False``: a target this tree drops may still be legitimately
    managed by another tree (e.g. ``.claude/settings.json`` moving to the work tree),
    and warning here would be a permanent false alarm on every flip.  ``main()``
    instead defers the warning, via ``_apply_color_mode_tree()``, until every tree
    has had a chance to claim the target.

    Parameters
    ----------
    chezmoi_prefix : str
        Root directory of a single chezmoi tree's source directory.
    managed : set[str]
        Target paths (relative to ``~``) that this tree's ``chezmoi managed``
        reports, as returned by ``_chezmoi_managed()``.
    warn_on_drop : bool, optional
        Warn immediately about every candidate dropped because it is not in
        ``managed``.

    Returns
    -------
    list[str]
        Target paths (under ``~``) of this tree's color-mode candidates that
        it actually manages.
    """
    home = os.path.expanduser("~")
    targets = []
    dropped = []
    for target in _scan_color_mode_candidates(chezmoi_prefix):
        if os.path.relpath(target, home) in managed:
            targets.append(target)
        else:
            dropped.append(target)
    if dropped and warn_on_drop:
        n = len(dropped)
        warn(f"{n} color-mode {plural(n, 'target')} not managed by the main tree; skipping:")
        for target in sorted(dropped):
            print(f"  {target}", file=sys.stderr)
    return targets


def _apply_color_mode_tree(
    chezmoi: str,
    env: dict[str, str],
    tree_label: str,
    source: str,
    config: str | None,
    *,
    verbose: bool,
    required: bool,
) -> tuple[set[str], set[str]] | None:
    """Apply one chezmoi tree's color-mode-branching targets.

    Returns ``(candidate_rels, applied_rels)`` -- every KOOPA_COLOR_MODE target
    *this tree's own templates* produce, and the subset actually applied -- as
    target paths relative to ``~``.  The caller combines these across all three
    trees (main, work, private) so a target this tree drops (e.g. unmanaged because
    ``.chezmoiignore`` excludes it while a work-tree marker is present) is warned
    about only if *no* tree ends up claiming it, instead of per-tree.  That deferred
    warning is the fix for the permanent false alarm this module used to emit on
    every flip once a target legitimately moved to an overlay tree.

    Returns ``None`` only when ``required`` is true and the managed-probe failed --
    the caller must treat that as a hard, silent abort of the whole color-mode run
    (matching this module's pre-multi-tree behavior: warn and return without
    writing the applied-marker, never raise).  A non-required tree never returns
    ``None``: a probe failure there warns and yields empty sets, skipping only that
    tree -- ``_chezmoi_managed()`` is documented to "never block the configure
    run," and inverting an empty result into "apply everything" would reintroduce
    the bug that filter exists to prevent.

    ``required`` otherwise controls apply-failure handling.  The main tree passes
    ``required=True``: an apply-subprocess failure raises (via ``check=True``),
    aborting the whole color-mode run without writing the applied-marker -- never
    claim the render succeeded from a half-broken main tree.  A work/private
    overlay tree passes ``required=False``: an apply failure warns and returns an
    empty applied set, leaving that tree's files untouched but letting the run
    continue and the marker still get written -- raising here would reintroduce
    the documented infinite-respawn wedge, where a permanently broken overlay tree
    blocks the marker forever and every new shell retries the identical failure.

    Parameters
    ----------
    chezmoi : str
        Path to the ``chezmoi`` executable.
    env : dict[str, str]
        Environment variables to pass to the ``chezmoi`` subprocess calls.
    tree_label : str
        Human-readable label for this tree (e.g. ``"main"``, ``"work"``,
        ``"private"``), used in warning messages.
    source : str
        Root directory of this tree's chezmoi source directory.
    config : str | None
        Path to this tree's ``chezmoi.toml``, or ``None`` to omit
        ``--config`` from the ``chezmoi`` invocation.
    verbose : bool
        Pass ``--verbose`` to the ``chezmoi apply`` invocation.
    required : bool
        Whether a managed-probe or apply failure for this tree is fatal to
        the whole color-mode run.

    Returns
    -------
    tuple[set[str], set[str]] | None
        A ``(candidate_rels, applied_rels)`` pair of target paths (relative
        to ``~``): every color-mode target this tree's templates produce,
        and the subset actually applied. ``None`` only when ``required`` is
        true and the managed-probe failed.
    """
    if not os.path.isdir(source):
        return set(), set()
    managed = _chezmoi_managed(chezmoi, source, env, config=config)
    if not managed:
        warn(f"chezmoi managed probe returned nothing for the {tree_label} tree; skipping apply.")
        return None if required else (set(), set())
    home = os.path.expanduser("~")
    candidates = _scan_color_mode_candidates(source)
    candidate_rels = {os.path.relpath(c, home) for c in candidates}
    kept = [c for c in candidates if os.path.relpath(c, home) in managed]
    if not kept:
        return candidate_rels, set()
    chezmoi_args = [
        chezmoi,
        "apply",
        "--no-pager",
        "--force",
        f"--source={source}",
    ]
    if config is not None:
        chezmoi_args.append(f"--config={config}")
    if verbose:
        chezmoi_args.append("--verbose")
    chezmoi_args.extend(kept)
    try:
        subprocess.run(chezmoi_args, cwd=source, env=env, check=True)
    except subprocess.CalledProcessError:
        if required:
            raise
        warn(f"chezmoi apply failed for the {tree_label} tree; continuing (marker still updates).")
        return candidate_rels, set()
    return candidate_rels, {os.path.relpath(c, home) for c in kept}


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Re-render color-mode-dependent dotfiles for the current OS appearance.

    Detects the actual OS appearance at call time (never trusts inherited env),
    discovers the color-mode template set dynamically, and runs a targeted
    ``chezmoi apply <target>...`` for only those files.  Never invokes
    ``opt/dotfiles/install`` or any tree's ``install`` script (so
    ``_sync_launchd_agent`` is never called and the job cannot kill itself).

    Applies all three chezmoi trees, in order main -> work -> private, mirroring
    ``configurers.dotfiles.main()``'s tree order: a later tree's version of a
    shared target wins.  This matters because a target can move between trees --
    e.g. ``.claude/settings.json`` is main-tree-managed by default but
    ``.chezmoiignore``'d out of the main tree (and picked up by the work tree
    instead) whenever the work-tree marker is present.  The main tree's apply is
    required: a managed-probe failure or an apply failure there raises and no
    marker is written.  The work/private trees are not required: either failure
    warns and leaves that tree's files untouched, but the run continues and the
    marker still gets written -- raising here would reintroduce the documented
    infinite-respawn wedge where a permanently broken overlay tree blocks the
    marker forever and every new shell retries the identical failure.

    Invoked by the macOS launchd / Linux systemd watcher on appearance changes;
    safe to run manually at any time.  To force a re-apply when the marker is
    stale, ``rm ~/.cache/koopa/color-mode-applied`` first.

    Uses an exclusive file lock (fcntl.LOCK_EX) to serialize concurrent
    invocations — the launchd WatchPaths watcher and every new shell can race
    to run this at the same time.  Without serialization, concurrent runs read
    different transient OS appearance states during a mode transition and stomp
    each other's chezmoi apply, producing light↔dark thrash.  The lock plus a
    double-checked marker ensure exactly one apply lands per mode change.

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"user"``).
    verbose : bool, optional
        Pass ``--verbose`` to the ``chezmoi apply`` invocations.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)

    home = os.path.expanduser("~")
    marker_file = os.path.join(home, ".cache", "koopa", "color-mode-applied")
    ts = datetime.now().astimezone().isoformat(timespec="seconds")

    # Fast path (lock-free): if the marker already matches the current OS mode,
    # skip entirely.  This keeps the thundering herd from N new shells cheap —
    # no lock contention in the common already-converged case.
    new_mode = os_appearance_mode()
    if os.path.isfile(marker_file):
        with open(marker_file) as fh:
            if fh.read().strip() == new_mode:
                alert_note(f"[{ts}] Color mode already applied: {new_mode}")
                return

    # Serialized path: acquire an exclusive lock so only one process runs the
    # chezmoi apply at a time.  Double-check the marker inside the lock — a
    # concurrent process may have applied while we were waiting.
    lock_file = os.path.join(home, ".cache", "koopa", "color-mode.lock")
    os.makedirs(os.path.dirname(lock_file), exist_ok=True)
    with open(lock_file, "w") as lock_fh:
        fcntl.flock(lock_fh, fcntl.LOCK_EX)

        # Re-read the OS state and marker inside the lock.  During a mode
        # transition defaults(1)/gdbus may briefly report the prior value;
        # re-reading after the lock settles ensures we apply the final state.
        # Paying os_appearance_mode() twice per run is only cheap because the
        # probe itself is bounded (headless-session gate + subprocess timeout
        # in _os_appearance_mode_linux) -- don't reintroduce an unbounded
        # probe here.
        new_mode = os_appearance_mode()
        ts = datetime.now().astimezone().isoformat(timespec="seconds")
        if os.path.isfile(marker_file):
            with open(marker_file) as fh:
                if fh.read().strip() == new_mode:
                    alert_note(f"[{ts}] Color mode already applied: {new_mode}")
                    return

        alert_info(f"[{ts}] Applying color mode: {new_mode}")

        chezmoi = locate("chezmoi")
        dotfiles_work_prefix = os.path.join(home, ".config", "koopa", "dotfiles-work")
        dotfiles_private_prefix = os.path.join(home, ".config", "koopa", "dotfiles-private")

        env = os.environ.copy()
        koopa_bin = os.path.join(koopa_prefix(), "bin")
        env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
        env["KOOPA_COLOR_MODE"] = new_mode
        # Sentinel suppresses nested sync spawns in any koopa shell activated
        # during chezmoi apply (prevents deadlock on the held flock).
        env["KOOPA_COLOR_MODE_SYNCING"] = "1"

        # Apply main -> work -> private.  Each tree contributes the color-mode
        # candidates its own templates declare; a candidate any tree applies is
        # "claimed" and dropped from the cross-tree warning below even if an
        # earlier tree's .chezmoiignore excluded it.
        main_source = os.path.join(opt_prefix(), "dotfiles", "chezmoi")
        work_source = os.path.join(dotfiles_work_prefix, "chezmoi")
        work_config = os.path.join(dotfiles_work_prefix, "chezmoi.toml")
        private_source = os.path.join(dotfiles_private_prefix, "chezmoi")
        private_config = os.path.join(dotfiles_private_prefix, "chezmoi.toml")

        all_candidates: set[str] = set()
        all_applied: set[str] = set()
        for tree_label, source, config, required in (
            ("main", main_source, None, True),
            ("work", work_source, work_config if os.path.isfile(work_config) else None, False),
            (
                "private",
                private_source,
                private_config if os.path.isfile(private_config) else None,
                False,
            ),
        ):
            result = _apply_color_mode_tree(
                chezmoi,
                env,
                tree_label,
                source,
                config,
                verbose=verbose,
                required=required,
            )
            # None only from the required (main) tree's managed-probe failure --
            # abort the whole run without writing the applied-marker, matching
            # this module's pre-multi-tree behavior.
            if result is None:
                return
            candidate_rels, applied_rels = result
            all_candidates |= candidate_rels
            all_applied |= applied_rels

        # A candidate no tree ended up claiming is genuinely unmanaged anywhere --
        # warn once, deferred until every tree has had a chance to claim it.  Never
        # warn per-tree here: a target this tree drops (e.g. .claude/settings.json
        # excluded from the main tree while a work-tree marker is present) may
        # still be legitimately managed by a later tree, and warning at that point
        # would be a permanent false alarm on every flip.
        unclaimed = sorted(all_candidates - all_applied)
        if unclaimed:
            n = len(unclaimed)
            warn(f"{n} color-mode {plural(n, 'target')} not managed by any tree; skipping:")
            for target in unclaimed:
                print(f"  {target}", file=sys.stderr)

        if not all_applied:
            alert_note("No color-mode targets found; nothing to apply.")
            return

        # Hot-reload any running tmux server so attached sessions reflow immediately.
        # Also warn when the running server predates the on-disk bundled binary.
        reload_tmux_config(new_mode)
        warn_tmux_stale()

        # Write the applied-marker only after the targeted apply succeeds,
        # while still inside the lock.
        os.makedirs(os.path.dirname(marker_file), exist_ok=True)
        with open(marker_file, "w") as fh:
            fh.write(new_mode + "\n")
