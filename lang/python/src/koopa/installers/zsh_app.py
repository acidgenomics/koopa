"""Install zsh."""

import glob
import os
import re
import subprocess
import sys
from multiprocessing import cpu_count

from koopa.build import locate
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
    # mathfunc is dynamic-only (link=dynamic in .mdd) and disabled by default
    # (load=no). Setting load=yes ensures it's built and installed as a .bundle.
    _set_mdd_load("Src/Modules/mathfunc.mdd", "yes")
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
        "DL_EXT=bundle",
    ]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = (
            f"-Wno-implicit-int -Wno-implicit-function-declaration {cflags}".strip()
        )
        # Building zsh with -std=gnu23 causes $() command substitution to hang:
        # the child process in getoutput() never exits, leaving the parent stuck
        # in readoutput(). Lock to C11 by passing CC with an explicit -std=gnu11,
        # which also prevents autoconf's AC_PROG_CC from auto-selecting gnu23.
        cc = re.sub(r"\s*-std=\S+", "", os.environ.get("CC", "gcc")).strip()
        os.environ["CC"] = cc
        conf_args.extend([
            f"CC={cc} -std=gnu11",
            # Prevent autoconf from upgrading to C23 (ac_cv_prog_cc_c23=):
            # when the blank/empty string is cached, autoconf won't add -std=gnu23.
            "ac_cv_prog_cc_c23=",
        ])
        # Several configure tests use old-style `main()` without a return type,
        # which fails to compile with gcc -std=gnu23. Override cached results:
        #
        # zsh_cv_shared_environ=yes  — keeps dynamic=yes so modules build as
        #                              .bundle files.
        # zsh_cv_sys_dynamic_execsyms=yes — keeps L=N (non-LINKMODS). Without
        #   this, L=L triggers LINKMODS mode: all zsh internals go into
        #   libzsh-5.9.bundle and the binary becomes a stub that hangs.
        # zsh_cv_sys_tcsetpgrp=yes  — confirms tcsetpgrp() works. Without this,
        #   zsh compiles with BROKEN_TCSETPGRP, disabling job control. The
        #   --with-tcsetpgrp flag was previously used but it caused a different
        #   hang: subshell $() blocks on SIGTTOU when no controlling TTY exists
        #   (e.g. inside command substitution). Caching yes here is correct for
        #   macOS where tcsetpgrp works, and lets zsh use it only when it has a
        #   controlling terminal (normal interactive use).
        conf_args.extend([
            "zsh_cv_shared_environ=yes",
            "zsh_cv_sys_dynamic_execsyms=yes",
            "zsh_cv_sys_tcsetpgrp=yes",
        ])
    subprocess_env = env.to_env_dict()
    subprocess.run(["./configure", *conf_args], env=subprocess_env, check=True)
    make = locate("make")
    jobs = cpu_count()
    subprocess.run([make, f"-j{jobs}"], env=subprocess_env, check=True)
    subprocess.run([make, "install"], env=subprocess_env, check=True)
    subprocess.run([make, "install.modules"], env=subprocess_env, check=True)
    _verify_mathfunc_installed(prefix)


def _set_mdd_load(mdd_path: str, value: str) -> None:
    """Set the load= field in a zsh .mdd module definition file."""
    if not os.path.isfile(mdd_path):
        msg = f"Module definition file not found: '{mdd_path}'"
        raise RuntimeError(msg)
    with open(mdd_path) as fh:
        content = fh.read()
    content = re.sub(r"^load=\w+$", f"load={value}", content, flags=re.MULTILINE)
    with open(mdd_path, "w") as fh:
        fh.write(content)


def _verify_mathfunc_installed(prefix: str) -> None:
    """Abort if the mathfunc module was not installed."""
    pattern = os.path.join(prefix, "lib", "zsh", "**", "mathfunc*")
    matches = glob.glob(pattern, recursive=True)
    if not matches:
        msg = (
            f"mathfunc module not found under '{prefix}/lib/zsh/'. "
            "Dynamic module build likely failed — check config.modules."
        )
        raise RuntimeError(msg)
