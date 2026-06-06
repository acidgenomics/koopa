"""Configure dark/light color-mode and re-render mode-dependent dotfiles."""

import os
import shutil
import subprocess

import koopa.configurers.dotfiles as _dotfiles
from koopa.alert import alert_info, alert_note
from koopa.system import os_appearance_mode


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Re-render mode-dependent dotfiles for the current OS color mode.

    Detects the actual OS appearance at call time (never trusts inherited env),
    then delegates to the full main → work → private apply sequence with pull
    skipped.  Invoked by the macOS launchd / Linux systemd watcher on appearance
    changes; safe to run manually at any time.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)

    new_mode = os_appearance_mode()

    # Use a SEPARATE marker from the shell's detection cache
    # (~/.cache/koopa/color-mode) to avoid the race where new shells write the
    # cache before the watcher fires.
    home = os.path.expanduser("~")
    marker_file = os.path.join(home, ".cache", "koopa", "color-mode-applied")
    if os.path.isfile(marker_file):
        with open(marker_file) as fh:
            if fh.read().strip() == new_mode:
                alert_note(f"Color mode already applied: {new_mode}")
                return

    alert_info(f"Applying color mode: {new_mode}")

    # Export before delegating so both the main chezmoi apply and the
    # work/private installs (which inherit this process env) all render
    # against the true OS mode.
    os.environ["KOOPA_COLOR_MODE"] = new_mode
    os.environ["KOOPA_DOTFILES_SKIP_PULL"] = "1"

    # Delegate to the full ordered apply (main → work → private).
    # This ensures work-specific config (claude, npm, pip) is never left stale
    # or overridden by a main-tree re-render.
    _dotfiles.main(name="dotfiles", platform="common", mode="user", verbose=verbose)

    # Hot-reload any running tmux server so attached sessions reflow immediately.
    tmux = shutil.which("tmux")
    if tmux:
        has_server = subprocess.run(
            [tmux, "has-session"],
            capture_output=True,
            check=False,
        )
        if has_server.returncode == 0:
            tmux_conf = os.path.join(
                os.environ.get("XDG_CONFIG_HOME", os.path.join(home, ".config")),
                "tmux",
                "tmux.conf",
            )
            subprocess.run(
                [tmux, "set-environment", "-g", "KOOPA_COLOR_MODE", new_mode],
                check=True,
            )
            if os.path.isfile(tmux_conf):
                subprocess.run([tmux, "source-file", tmux_conf], check=True)

    # Write the applied-marker only after the full apply succeeds.
    os.makedirs(os.path.dirname(marker_file), exist_ok=True)
    with open(marker_file, "w") as fh:
        fh.write(new_mode + "\n")
