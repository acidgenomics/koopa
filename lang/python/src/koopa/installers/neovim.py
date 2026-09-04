"""Install neovim, with a Linux hotfix for a known conda-forge soname bug.

conda-forge's linux-64 ``nvim`` 0.12.5 (build ``h5d254f0_0``) was linked
against ``unibilium`` 2.1.2, whose Makefile emitted a malformed soname. The
binary's DT_NEEDED entry is the literal string ``libunibilium.so..``. On
2026-08-30 conda-forge shipped ``unibilium`` 2.1.4, which fixed the soname,
but the run-exports pin (``>=2.1.2,<2.2.0a0``) lets the solver pick 2.1.4 for
the still-unrebuilt ``nvim`` 0.12.5. Every solve keeps reproducing the same
broken pair until conda-forge/nvim-feedstock#56 ships a rebuilt ``nvim`` with
a higher build number.

Patch a compatibility symlink after each install so the binary koopa links
actually runs. Safe: unibilium's soversion carries libtool age 2, so 2.1.4 is
ABI-compatible with the interface 2.1.2 exposed.

Remove this module, and point the "neovim" entry in installers/__init__.py
back at "._conda", once a rebuilt nvim (higher build number) reaches the
mirror.
"""

import glob
import os

from koopa.install import install_conda_package
from koopa.installers._args import get_str, parse_passthrough
from koopa.system import is_linux

_BROKEN_SONAME = "libunibilium.so.."


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install neovim via conda, then patch the known unibilium soname bug.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    kwargs = parse_passthrough(passthrough_args)
    install_conda_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        yaml_file=get_str(kwargs, "yaml_file"),
        post_extract_fn=_fix_unibilium_soname if is_linux() else None,
    )


def _fix_unibilium_soname(libexec: str) -> None:
    """Symlink the malformed soname nvim expects to the real library file.

    Parameters
    ----------
    libexec : str
        Path to the app's ``libexec`` directory.
    """
    lib_dir = os.path.join(libexec, "lib")
    broken = os.path.join(lib_dir, _BROKEN_SONAME)
    if os.path.lexists(broken):
        return
    candidates = sorted(glob.glob(os.path.join(lib_dir, "libunibilium.so.*.*.*")))
    if not candidates:
        return
    os.symlink(os.path.basename(candidates[-1]), broken)
