"""Configure dark/light color-mode and re-render mode-dependent dotfiles."""

import fcntl
import os
import re
import subprocess
from datetime import datetime

from koopa.alert import alert_info, alert_note
from koopa.build import locate
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.system import os_appearance_mode
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


def _discover_color_mode_targets(chezmoi_prefix: str) -> list[str]:
    """Return target paths of main-tree templates that branch on KOOPA_COLOR_MODE.

    Discovers templates dynamically (self-maintaining — new color-mode templates
    are picked up automatically).  Returns target paths so chezmoi can look each
    file up by its index entry; unknown/unmanaged templates are silently skipped
    since their target paths simply won't exist on disk.

    The launchd plist and systemd unit are naturally excluded because they don't
    reference KOOPA_COLOR_MODE.
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
            target = _chezmoi_source_to_target(chezmoi_prefix, src_path)
            # Only include targets that exist on disk (i.e. previously deployed
            # by chezmoi and therefore in its index).
            if os.path.exists(target):
                targets.append(target)
    return targets


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
    ``opt/dotfiles/install`` (so ``_sync_launchd_agent`` is never called and the
    job cannot kill itself).  Never touches work/private dotfiles trees.

    Invoked by the macOS launchd / Linux systemd watcher on appearance changes;
    safe to run manually at any time.  To force a re-apply when the marker is
    stale, ``rm ~/.cache/koopa/color-mode-applied`` first.

    Uses an exclusive file lock (fcntl.LOCK_EX) to serialize concurrent
    invocations — the launchd WatchPaths watcher and every new shell can race
    to run this at the same time.  Without serialization, concurrent runs read
    different transient OS appearance states during a mode transition and stomp
    each other's chezmoi apply, producing light↔dark thrash.  The lock plus a
    double-checked marker ensure exactly one apply lands per mode change.
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

        chezmoi_prefix = os.path.join(opt_prefix(), "dotfiles", "chezmoi")
        chezmoi = locate("chezmoi")

        target_files = _discover_color_mode_targets(chezmoi_prefix)
        if not target_files:
            alert_note("No color-mode targets found; nothing to apply.")
            return

        env = os.environ.copy()
        koopa_bin = os.path.join(koopa_prefix(), "bin")
        env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
        env["KOOPA_COLOR_MODE"] = new_mode
        # Sentinel suppresses nested sync spawns in any koopa shell activated
        # during chezmoi apply (prevents deadlock on the held flock).
        env["KOOPA_COLOR_MODE_SYNCING"] = "1"

        # Targeted apply by target paths.  Never invokes opt/dotfiles/install,
        # so _sync_launchd_agent is never called and this launchd job cannot
        # SIGTERM itself.
        chezmoi_args = [
            chezmoi,
            "apply",
            "--no-pager",
            "--force",
            f"--source={chezmoi_prefix}",
        ]
        if verbose:
            chezmoi_args.append("--verbose")
        chezmoi_args.extend(target_files)
        subprocess.run(chezmoi_args, cwd=chezmoi_prefix, env=env, check=True)

        # Hot-reload any running tmux server so attached sessions reflow immediately.
        # Also warn when the running server predates the on-disk bundled binary.
        reload_tmux_config(new_mode)
        warn_tmux_stale()

        # Write the applied-marker only after the targeted apply succeeds,
        # while still inside the lock.
        os.makedirs(os.path.dirname(marker_file), exist_ok=True)
        with open(marker_file, "w") as fh:
            fh.write(new_mode + "\n")
