"""Configure Spacemacs for the current user."""

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
    """Configure Spacemacs for the current user.

    Creates ~/.spacemacs.d/ with a starter init.el if not already present,
    pointing to the shared Spacemacs install via --init-directory.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_spacemacs = os.path.join(opt_prefix(), "spacemacs")
    if not os.path.isdir(opt_spacemacs):
        msg = f"Spacemacs shared install not found: {opt_spacemacs}"
        raise FileNotFoundError(msg)
    home = os.path.expanduser("~")
    spacemacs_d = os.path.join(home, ".spacemacs.d")
    init_el = os.path.join(spacemacs_d, "init.el")
    if os.path.isfile(init_el):
        alert_info(f"Spacemacs user config already exists: {init_el}")
        return
    os.makedirs(spacemacs_d, exist_ok=True)
    template = os.path.join(opt_spacemacs, "core", "templates", ".spacemacs.template")
    if os.path.isfile(template):
        import shutil
        shutil.copy2(template, init_el)
        alert_info(f"Created Spacemacs config from template: {init_el}")
    else:
        with open(init_el, "w") as f:
            f.write(";; Spacemacs user config\n;; See https://www.spacemacs.org/doc/DOCUMENTATION.html\n")
        alert_info(f"Created empty Spacemacs config: {init_el}")
