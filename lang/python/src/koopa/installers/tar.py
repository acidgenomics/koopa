"""Install tar."""

from __future__ import annotations

import os

from koopa.build import activate_app, app_prefix, locate, make_build
from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tar."""
    env = activate_app("make", build_only=True)
    env = activate_app("libiconv", env=env)
    iconv_prefix = app_prefix("libiconv")
    iconv_lib = os.path.join(iconv_prefix, "lib")
    env.ldflags.append(f"-L{iconv_lib}")
    env.ldflags.append(f"-Wl,-rpath,{iconv_lib}")
    env.apply()
    os.environ["LIBS"] = f"-liconv {os.environ.get('LIBS', '')}".strip()
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        conf_args=[
            "--program-prefix=g",
            f"--with-libiconv-prefix={iconv_prefix}",
        ],
    )
