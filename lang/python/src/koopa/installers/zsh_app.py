"""Install zsh."""

import os
import subprocess
import sys

from koopa.build import make_build
from koopa.download import download
from koopa.installers._build_helper import activate_app_deps, download_extract_cd

# Debian cherry-picks to migrate the pcre module to pcre2 (backported from zsh master).
# https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/z/zsh.rb
_PATCHES = [
    "https://sources.debian.org/data/main/z/zsh/5.9-8/debian/patches/"
    "cherry-pick-b62e91134-51723-migrate-pcre-module-to-pcre2.patch",
    "https://sources.debian.org/data/main/z/zsh/5.9-8/debian/patches/"
    "cherry-pick-10bdbd8b-51877-do-not-build-pcre-module-if-pcre2-config-is-not-found.patch",
]


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install zsh."""
    env = activate_app_deps()
    download_extract_cd()
    for url in _PATCHES:
        patch_file = download(url)
        subprocess.run(["patch", "-p1", "-i", patch_file], check=True)
    subprocess.run(["Util/preconfig"], check=True)
    conf_args = [
        f"--prefix={prefix}",
        "--enable-cap",
        "--enable-dynamic",
        "--enable-maildir-support",
        "--enable-multibyte",
        "--enable-pcre",
        "--enable-unicode9",
        "--enable-zsh-secure-free",
        "--with-tcsetpgrp",
        "DL_EXT=bundle",
    ]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = (
            f"-Wno-implicit-int -Wno-implicit-function-declaration {cflags}".strip()
        )
    make_build(conf_args=conf_args, env=env)
