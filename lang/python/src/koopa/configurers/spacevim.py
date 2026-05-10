"""Configure SpaceVim for the current user."""

import os

from koopa.alert import alert_info
from koopa.prefix import opt_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure SpaceVim for the current user.

    Creates ~/.SpaceVim.d/ with a starter init.toml if not already present.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_spacevim = os.path.join(opt_prefix(), "spacevim")
    if not os.path.isdir(opt_spacevim):
        msg = f"SpaceVim shared install not found: {opt_spacevim}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    spacevim_d = os.path.join(home, ".SpaceVim.d")
    init_toml = os.path.join(spacevim_d, "init.toml")
    if os.path.isfile(init_toml):
        alert_info(f"SpaceVim user config already exists: {init_toml}")
        return
    os.makedirs(spacevim_d, exist_ok=True)
    template = os.path.join(opt_spacevim, "docs", "init.toml")
    if os.path.isfile(template):
        import shutil
        shutil.copy2(template, init_toml)
        alert_info(f"Created SpaceVim config from template: {init_toml}")
    else:
        with open(init_toml, "w") as f:
            f.write("# SpaceVim user config\n# See https://spacevim.org/documentation/\n")
        alert_info(f"Created empty SpaceVim config: {init_toml}")
