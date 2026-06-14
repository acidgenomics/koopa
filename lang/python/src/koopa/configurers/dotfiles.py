"""Configure dotfiles."""

import os
import subprocess
import sys

from koopa.alert import alert_info, alert_note, warn
from koopa.build import locate
from koopa.git import git_pull_safe
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.system import os_appearance_mode


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
    """
    overlap = sorted(main_targets & tree_targets)
    if not overlap:
        return
    warn(
        f"{tree_label} tree overrides the main tree for "
        f"{len(overlap)} target(s); the {tree_label} version wins:"
    )
    for target in overlap:
        print(f"  {target}", file=sys.stderr)


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
    if os.path.isfile(work_install_script):
        alert_info(f"Running '{work_install_script}'.")
        wcfg = work_config if os.path.isfile(work_config) else None
        work_targets = _chezmoi_managed(chezmoi, work_source, env, config=wcfg)
        _warn_cross_tree_overlap("work", main_targets, work_targets)
        _print_chezmoi_status(chezmoi, work_source, env, config=wcfg)
        subprocess.run([work_install_script], check=True, env=env)
    private_install_script = os.path.join(dotfiles_private_prefix, "install")
    if os.path.isfile(private_install_script):
        alert_info(f"Running '{private_install_script}'.")
        pcfg = private_config if os.path.isfile(private_config) else None
        private_targets = _chezmoi_managed(chezmoi, private_source, env, config=pcfg)
        _warn_cross_tree_overlap("private", main_targets, private_targets)
        _print_chezmoi_status(chezmoi, private_source, env, config=pcfg)
        subprocess.run([private_install_script], check=True, env=env)
    # Hot-reload any running tmux server so rewritten color confs take effect
    # without requiring a manual prefix+r or reconnect.  Also warn when the
    # running server predates the newly-installed binary.
    from koopa.tmux import reload_tmux_config, warn_tmux_stale

    reload_tmux_config(env["KOOPA_COLOR_MODE"])
    warn_tmux_stale()
