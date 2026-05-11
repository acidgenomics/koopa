"""Configure Spacemacs for the current user."""

import os
import subprocess

from koopa.alert import alert_info
from koopa.prefix import opt_prefix

# Minimal stub packages for compat and spinner. These are GNU ELPA shims that
# MELPA packages list as dependencies but are not needed on Emacs 29+ which
# ships the functionality natively. The stubs satisfy package.el's dependency
# resolver so it doesn't error on unavailable packages.
_COMPAT_VERSION = "30.0.5.0"
_SPINNER_VERSION = "1.7.4"

_COMPAT_PKG = """\
(define-package "compat" "{version}" "Emacs Lisp Compatibility Library"
  '((emacs "24.4"))
  :authors '(("Philip Kaludercic" . "philipk@posteo.net"))
  :url "https://elpa.gnu.org/packages/compat.html")
""".format(version=_COMPAT_VERSION)

_COMPAT_EL = """\
;;; compat.el --- Emacs Lisp Compatibility Library -*- lexical-binding: t; -*-
;; Version: {version}
;; Stub: functionality is built into Emacs 29+.
(provide 'compat)
""".format(version=_COMPAT_VERSION)

_SPINNER_PKG = """\
(define-package "spinner" "{version}" "Add spinners and progress-bars to the mode-line for ongoing operations"
  '((emacs "24.3"))
  :authors '(("Artur Malabarba" . "emacs@endlessparentheses.com"))
  :url "https://github.com/Malabarba/spinner.el")
""".format(version=_SPINNER_VERSION)

_SPINNER_EL = """\
;;; spinner.el --- Add spinners and progress-bars to the mode-line -*- lexical-binding: t; -*-
;; Version: {version}
;; Stub: replaces the GNU ELPA package with no-ops.
(defvar spinner-types nil)
(defun spinner-create (&rest _) nil)
(defun spinner-start (&rest _) nil)
(defun spinner-stop (&rest _) nil)
(provide 'spinner)
""".format(version=_SPINNER_VERSION)


def _create_elpa_stubs(elpa_root: str) -> None:
    """Create compat and spinner stub packages in the spacemacs elpa directory."""
    result = subprocess.run(
        ["emacs", "--batch", "--eval", "(princ emacs-version)"],
        capture_output=True, text=True, check=False,
    )
    if result.returncode != 0 or not result.stdout.strip():
        return
    ver = result.stdout.strip()
    parts = ver.split(".")
    if len(parts) < 2:
        return
    emacs_subdir = f"{parts[0]}.{parts[1]}"
    develop_dir = os.path.join(elpa_root, emacs_subdir, "develop")

    stubs = [
        (f"compat-{_COMPAT_VERSION}", "compat-pkg.el", _COMPAT_PKG),
        (f"compat-{_COMPAT_VERSION}", "compat.el", _COMPAT_EL),
        (f"spinner-{_SPINNER_VERSION}", "spinner-pkg.el", _SPINNER_PKG),
        (f"spinner-{_SPINNER_VERSION}", "spinner.el", _SPINNER_EL),
    ]
    for pkg_dir, filename, content in stubs:
        pkg_path = os.path.join(develop_dir, pkg_dir)
        os.makedirs(pkg_path, exist_ok=True)
        filepath = os.path.join(pkg_path, filename)
        if not os.path.isfile(filepath):
            with open(filepath, "w") as f:
                f.write(content)


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure Spacemacs for the current user."""
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    opt_spacemacs = os.path.join(opt_prefix(), "spacemacs")
    if not os.path.isdir(opt_spacemacs):
        msg = f"Spacemacs shared install not found: {opt_spacemacs}"
        raise FileNotFoundError(msg)
    libexec = os.path.join(opt_spacemacs, "libexec")
    home = os.path.expanduser("~")
    xdg_data = os.environ.get("XDG_DATA_HOME", os.path.join(home, ".local", "share"))
    elpa_root = os.path.join(xdg_data, "spacemacs", "elpa")
    _create_elpa_stubs(elpa_root)
    spacemacs_file = os.path.join(home, ".spacemacs")
    spacemacs_d = os.path.join(home, ".spacemacs.d")
    init_el = os.path.join(spacemacs_d, "init.el")
    if os.path.isfile(spacemacs_file):
        alert_info(f"Spacemacs user config already exists: {spacemacs_file}")
        return
    if os.path.isfile(init_el):
        alert_info(f"Spacemacs user config already exists: {init_el}")
        return
    os.makedirs(spacemacs_d, exist_ok=True)
    template = os.path.join(libexec, "core", "templates", ".spacemacs.template")
    if os.path.isfile(template):
        import shutil
        shutil.copy2(template, init_el)
        alert_info(f"Created Spacemacs config from template: {init_el}")
    else:
        with open(init_el, "w") as f:
            f.write(";; Spacemacs user config\n;; See https://www.spacemacs.org/doc/DOCUMENTATION.html\n")
        alert_info(f"Created empty Spacemacs config: {init_el}")
