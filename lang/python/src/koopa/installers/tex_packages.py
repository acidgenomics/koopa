"""Install TeX packages."""

import shutil
import subprocess
import sys

from koopa.installers._build_helper import activate_app_deps

_PACKAGES = [
    "collection-fontsrecommended",
    "collection-latexrecommended",
    "bera",
    "biblatex",
    "caption",
    "changepage",
    "csvsimple",
    "enumitem",
    "etoolbox",
    "fancyhdr",
    "footmisc",
    "framed",
    "geometry",
    "hyperref",
    "inconsolata",
    "logreq",
    "marginfix",
    "mathtools",
    "natbib",
    "nowidow",
    "parnotes",
    "parskip",
    "placeins",
    "preprint",
    "sectsty",
    "soul",
    "titlesec",
    "titling",
    "units",
    "wasysym",
    "xstring",
]


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install TeX packages.

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
    activate_app_deps()
    tlmgr = shutil.which("tlmgr")
    if tlmgr is None:
        msg = "tlmgr not found. Install TeX Live first."
        raise FileNotFoundError(msg)
    # Use a reliable CTAN mirror and update the local package DB first.
    repo = "https://mirror.ctan.org/systems/texlive/tlnet"
    subprocess.run(["sudo", tlmgr, "option", "repository", repo], check=True)
    subprocess.run(["sudo", tlmgr, "update", "--self", "--all", "--repository", repo], check=True)

    # Query which packages are not installed and install only those.
    missing: list[str] = []
    for pkg in _PACKAGES:
        res = subprocess.run([tlmgr, "info", pkg], capture_output=True, text=True, check=False)
        installed = False
        for line in res.stdout.splitlines():
            if line.strip().lower().startswith("installed:"):
                val = line.split(":", 1)[1].strip().lower()
                if val.startswith("yes"):
                    installed = True
                break
        if not installed:
            missing.append(pkg)

    if not missing:
        print("All TeX packages already installed.", file=sys.stderr)
        return

    print(f"Installing missing TeX packages: {', '.join(missing)}", file=sys.stderr)
    try:
        subprocess.run(["sudo", tlmgr, "install", "--repository", repo, *missing], check=True)
    except subprocess.CalledProcessError:
        # Fall back to per-package installs to surface failing package(s).
        for pkg in missing:
            subprocess.run(["sudo", tlmgr, "install", pkg], check=True)
