"""Install playwright.

playwright's own browser download defaults to the shared user cache
(``~/.cache/ms-playwright`` / ``~/Library/Caches/ms-playwright``) -- outside
koopa's app management and outside this app's own prefix. Point
``PLAYWRIGHT_BROWSERS_PATH`` at ``<prefix>/libexec/browsers`` so the browser
binaries land inside the app's own tree, alongside its venv, like every
other koopa-managed app.
"""

import os
import subprocess

from koopa.install import install_python_package
from koopa.installers._args import get_list, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install playwright, then download its Chromium browser into the app prefix."""
    kwargs = parse_passthrough(passthrough_args)
    extra = get_list(kwargs, "extra_packages")
    install_python_package(name=name, version=version, prefix=prefix, extra_packages=extra or None)
    _install_chromium(prefix)


def _install_chromium(prefix: str) -> None:
    """Download playwright's Chromium build into the app's own prefix."""
    browsers_dir = os.path.join(prefix, "libexec", "browsers")
    os.makedirs(browsers_dir, exist_ok=True)
    playwright = os.path.join(prefix, "bin", "playwright")
    env = {**os.environ, "PLAYWRIGHT_BROWSERS_PATH": browsers_dir}
    subprocess.run([playwright, "install", "chromium"], env=env, check=True)
