"""Install groff."""

import os
import re
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd
from koopa.installers._gnu import _get_app_deps


def _disable_doc_builds() -> None:
    """Neuter doc PDF/PS generation in the Makefile to avoid gropdf OOM.

    Zeroes out multi-line variable assignments that list doc PDF/PS files,
    handling backslash continuations.
    """
    with open("Makefile") as f:
        content = f.read()
    # Match variable assignments that may span multiple lines via
    # backslash continuations, for doc-related DATA variables.
    pattern = re.compile(
        r"^((?:doc_DATA|contribhdtblexamples_DATA)\s*=).*?(?:(?<!\\)\n)",
        re.MULTILINE | re.DOTALL,
    )
    content = pattern.sub(r"\1\n", content)
    with open("Makefile", "w") as f:
        f.write(content)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install groff."""
    build_deps, deps = _get_app_deps(name)
    env = None
    if build_deps:
        env = activate_app(*build_deps, build_only=True)
    if deps:
        env = activate_app(*deps, env=env)
    if env is not None:
        env.apply()
    download_extract_cd()
    make = locate("make")
    jobs = os.cpu_count() or 1
    subprocess.run(
        ["./configure", f"--prefix={prefix}", "--without-x"],
        check=True,
    )
    _disable_doc_builds()
    subprocess.run([make, f"-j{jobs}"], check=True)
    subprocess.run([make, "install"], check=True)
