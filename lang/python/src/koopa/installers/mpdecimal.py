"""Install mpdecimal."""

from koopa.build import make_build
from koopa.installers._build_helper import (
    activate_app_deps,
    download_extract_cd,
    remove_static_libs,
)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install mpdecimal.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    download_extract_cd()
    # mpdecimal's own Makefile.in has no libtool and no --enable-rpath: on
    # macOS this is invisible because libmpdec++ inherits an absolute
    # -install_name from libmpdec (a macOS-only mechanism), but on Linux
    # -Wl,-soname only records the bare libmpdec.so.4, with nothing to tell
    # the dynamic linker where to find it. Add the app's own lib dir as an
    # explicit rpath, matching icu4c.py's identical C+C++ sibling-library fix.
    #
    # Confirmed empirically (LDFLAGS alone does not do it): libmpdec/Makefile.in
    # links libmpdec.so from $(LDFLAGS), but libmpdec++/Makefile.in links
    # libmpdec++.so from a separate $(LDXXFLAGS) that LDFLAGS never reaches.
    # Both must carry the rpath flag.
    rpath_flag = f"-Wl,-rpath,{prefix}/lib"
    env.ldflags.insert(0, rpath_flag)
    make_build(
        conf_args=["--disable-static", f"--prefix={prefix}"],
        env=env,
        extra_env={"LDXXFLAGS": rpath_flag},
    )
    remove_static_libs(prefix)
