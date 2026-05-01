"""Install freetype."""

from __future__ import annotations

from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install freetype."""
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        non_gnu_mirror=True,
        conf_args=[
            "--disable-static",
            "--enable-freetype-config",
            "--enable-shared=yes",
            "--without-harfbuzz",
        ],
    )
