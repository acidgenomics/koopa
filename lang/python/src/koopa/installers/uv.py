"""Install uv."""

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch, is_alpine


def _platform_triple() -> str:
    """Return the Rust-style platform triple for uv release assets.

    Returns
    -------
    str
        Platform triple, e.g. ``"aarch64-apple-darwin"``.
    """
    machine = arch()
    arch_map = {"arm64": "aarch64", "x86_64": "x86_64", "aarch64": "aarch64"}
    rust_arch = arch_map.get(machine, machine)
    if sys.platform == "darwin":
        return f"{rust_arch}-apple-darwin"
    libc = "musl" if is_alpine() else "gnu"
    return f"{rust_arch}-unknown-linux-{libc}"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install uv.

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
    triple = _platform_triple()
    url = f"https://github.com/astral-sh/uv/releases/download/{version}/uv-{triple}.tar.gz"
    tarball = download(url)
    extract(tarball, os.path.join(prefix, "bin"))
