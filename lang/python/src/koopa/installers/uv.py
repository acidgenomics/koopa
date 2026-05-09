"""Install uv."""

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch, is_alpine


def _platform_triple() -> str:
    """Return the Rust-style platform triple for uv release assets."""
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
    """Install uv."""
    triple = _platform_triple()
    url = (
        f"https://github.com/astral-sh/uv/releases/download/"
        f"{version}/uv-{triple}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, os.path.join(prefix, "bin"))
