"""Install libpcap."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libpcap."""
    env = activate_app("bison", "flex", "pkg-config", build_only=True)
    url = f"https://www.tcpdump.org/release/libpcap-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--enable-ipv6",
            f"--prefix={prefix}",
        ],
        env=env,
    )
