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
    # Enable mathfunc in its .mdd before configure generates config.modules.
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
        "--with-tcsetpgrp",
        "DL_EXT=bundle",
    ]
    if sys.platform == "darwin":
        cflags = os.environ.get("CFLAGS", "")
        os.environ["CFLAGS"] = (
            f"-Wno-implicit-int -Wno-implicit-function-declaration {cflags}".strip()
        )
        # configure's 'environ available in shared libraries' test fails when
        # CC includes -std=gnu23 (the test uses old-style `main()` which is
        # invalid in C23, so the test program fails to compile and the test
        # returns 'no', causing dynamic=no and disabling all dynamic modules).
        # We bypass the test by providing the expected result directly: environ
        # IS accessible from shared libraries on macOS.
        conf_args.append("zsh_cv_shared_environ=yes")
    subprocess_env = env.to_env_dict()
    subprocess.run(["./configure", *conf_args], env=subprocess_env, check=True)
    if sys.platform == "darwin":
        # With zsh_cv_shared_environ=yes, configure enables the LINKMODS strategy:
        # it builds libzsh.bundle and links the zsh binary against it. macOS ld
        # rejects .bundle as a link input (only MH_DYLIB allowed). Patch the
        # $(LIBZSH) target in Src/Makefile to use -dynamiclib so ld can link
        # against it. Individual module .bundle files use DLLINK unmodified.
        _fix_libzsh_makefile("Src/Makefile")
    make = locate("make")
    jobs = cpu_count()
    subprocess.run([make, f"-j{jobs}"], env=subprocess_env, check=True)
    subprocess.run([make, "install"], env=subprocess_env, check=True)
    subprocess.run([make, "install.modules"], env=subprocess_env, check=True)
    if sys.platform == "darwin":
        # Fix the libzsh dylib reference in the installed zsh binary.
        # The binary was linked with -rpath @rpath/libzsh-5.9.bundle, but
        # the rpath entries (LDFLAGS lib dirs) don't contain libzsh. Use
        # install_name_tool to change the LC_LOAD_DYLIB reference to the
        # absolute path where libzsh is installed.
        zsh_bin = os.path.join(prefix, "bin", "zsh")
        libzsh = os.path.join(prefix, "lib", "zsh", "libzsh-5.9.bundle")
        if os.path.isfile(libzsh):
            subprocess.run(
                ["install_name_tool",
                 "-change", "@rpath/libzsh-5.9.bundle", libzsh,
                 zsh_bin],
                check=True,
            )
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


def _fix_libzsh_makefile(makefile: str) -> None:
    """Replace the libzsh link command in Src/Makefile to use -dynamiclib.

    In LINKMODS mode, configure builds libzsh as a .bundle and links the zsh
    binary against it. macOS ld cannot link .bundle files at build time (only
    MH_OBJECT or MH_DYLIB). We patch the $(LIBZSH) target to use -dynamiclib
    with an @rpath install_name, producing a proper Mach-O dylib that ld can
    link against. We also patch the zsh binary link line to add the @rpath so
    dyld can find libzsh at runtime using its install location. Individual module
    .bundle files use DLLINK unchanged and are not affected.
    """
    if not os.path.isfile(makefile):
        return
    with open(makefile) as fh:
        content = fh.read()
    # Patch libzsh build: use -dynamiclib with @rpath install_name
    content = content.replace(
        "\t$(DLLINK) $(LIBOBJS) $(NLIST) $(LIBS)",
        "\t$(DLLD) $(LDFLAGS) -dynamiclib"
        " -install_name '@rpath/$(LIBZSH)'"
        " -o $@ $(LIBOBJS) $(NLIST) $(LIBS)",
    )
    # Patch zsh binary link: inject -rpath so dyld finds libzsh at its installed
    # location, and -headerpad_max_install_names so install_name_tool can update
    # the @rpath reference after install.
    content = re.sub(
        r"^(LINK\s*=\s*\$\(CC\)\s*\$\(LDFLAGS\))",
        r"\1 -Wl,-rpath,$(libdir)/zsh -Wl,-headerpad_max_install_names",
        content,
        flags=re.MULTILINE,
    )
    with open(makefile, "w") as fh:
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
