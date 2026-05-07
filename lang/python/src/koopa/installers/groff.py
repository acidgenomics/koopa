"""Install groff."""

import re
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd
from koopa.installers._gnu import _get_app_deps


def _disable_doc_builds() -> None:
    """Neuter doc PDF/PS generation in the Makefile to avoid gropdf OOM."""
    with open("Makefile") as f:
        content = f.read()
    # Zero out variables that list doc PDF/PS files to build.
    content = re.sub(
        r"^(DOCFILES_INST\s*=).*$",
        r"\1",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"^(DOCOTHERFILES_INST\s*=).*$",
        r"\1",
        content,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r"^(doc_DATA\s*=).*$",
        r"\1",
        content,
        flags=re.MULTILINE,
    )
    # Also catch the contrib hdtbl examples which trigger gropdf.
    content = re.sub(
        r"^(contribhdtblexamples_DATA\s*=).*$",
        r"\1",
        content,
        flags=re.MULTILINE,
    )
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
    subprocess.run(
        ["./configure", f"--prefix={prefix}", "--without-x"],
        check=True,
    )
    _disable_doc_builds()
    subprocess.run([make, "-j1"], check=True)
    subprocess.run([make, "install"], check=True)
