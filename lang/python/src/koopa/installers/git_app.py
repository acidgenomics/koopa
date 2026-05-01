"""Install git."""

from __future__ import annotations

import os
import shutil
import subprocess

from koopa.archive import extract
from koopa.build import activate_app, app_prefix, locate
from koopa.download import download
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install git."""
    env = activate_app("autoconf", "make", build_only=True)
    env = activate_app(
        "expat",
        "zlib",
        "gettext",
        "openssl",
        "zstd",
        "libssh2",
        "curl",
        "pcre2",
        "libiconv",
        env=env,
    )
    make = locate("make")
    bash = locate("bash")
    less = locate("less")
    perl = locate("perl")
    python = locate("python3")
    vim = locate("vim")
    curl_prefix = app_prefix("curl")
    expat_prefix = app_prefix("expat")
    libiconv_prefix = app_prefix("libiconv")
    openssl_prefix = app_prefix("openssl")
    pcre2_prefix = app_prefix("pcre2")
    zlib_prefix = app_prefix("zlib")
    url_base = "https://mirrors.edge.kernel.org/pub/software/scm/git"
    url = f"{url_base}/git-{version}.tar.xz"
    htmldocs_url = f"{url_base}/git-htmldocs-{version}.tar.xz"
    manpages_url = f"{url_base}/git-manpages-{version}.tar.xz"
    htmldocs_tarball = download(htmldocs_url)
    manpages_tarball = download(manpages_url)
    extract(
        htmldocs_tarball,
        os.path.join(prefix, "share", "doc", "git-doc"),
    )
    extract(
        manpages_tarball,
        os.path.join(prefix, "share", "man"),
    )
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    conf_args = [
        f"--prefix={prefix}",
        f"--with-curl={curl_prefix}",
        f"--with-editor={vim}",
        f"--with-expat={expat_prefix}",
        f"--with-iconv={libiconv_prefix}",
        f"--with-libpcre2={pcre2_prefix}",
        f"--with-openssl={openssl_prefix}",
        f"--with-pager={less}",
        f"--with-perl={perl}",
        f"--with-python={python}",
        f"--with-shell={bash}",
        f"--with-zlib={zlib_prefix}",
        "--without-tcltk",
    ]
    subprocess.run(
        [make, "configure"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["./configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            f"--jobs={jobs}",
            "NO_IMAP_SEND=YesPlease",
            "NO_INSTALL_HARDLINKS=YesPlease",
            "VERBOSE=1",
        ],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            "NO_IMAP_SEND=YesPlease",
            "NO_INSTALL_HARDLINKS=YesPlease",
            "install",
        ],
        env=subprocess_env,
        check=True,
    )
    os.chdir("contrib/subtree")
    subprocess.run(
        [make, f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    shutil.copy2(
        "git-subtree",
        os.path.join(prefix, "bin", "git-subtree"),
    )
    os.chdir("../..")
    completion_src = os.path.join("contrib", "completion")
    completion_dst = os.path.join(prefix, "share", "completion")
    if os.path.isdir(completion_src):
        shutil.copytree(completion_src, completion_dst, dirs_exist_ok=True)
