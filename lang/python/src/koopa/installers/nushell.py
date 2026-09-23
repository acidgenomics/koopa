"""Install nushell, plus a conda-forge dependency-solve fix for one plugin.

conda-forge's own nushell recipe does not declare ``libcurl`` as a
dependency (confirmed via ``libexec/conda-meta/nushell-*.json``'s own
``depends`` list), so the bundled ``nu_plugin_query`` plugin ships with an
``@rpath/libcurl.4.dylib`` (macOS) / ``libcurl.so`` (Linux) reference that
nothing in the conda env provides.

Install ``libcurl`` into the same env afterward, via a second, additive
``conda install`` rather than patching the binary or copying in koopa's own
``curl`` (which is linked against a different OpenSSL major version than
this conda env, an ABI mismatch risk). Conda's own solver then picks
whatever ``libcurl`` build is genuinely compatible with the packages
already resolved in that env.

Remove this module, and point the "nushell" entry in installers/__init__.py
back at "._conda", once conda-forge's nushell recipe declares libcurl
itself.
"""

import shutil
import subprocess
import tempfile

from koopa.build import locate
from koopa.install import _resolve_conda_channel_url, install_conda_package
from koopa.installers._args import get_str, parse_passthrough
from koopa.system import safe_build_env


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install nushell via conda, then add its missing libcurl dependency.

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
    kwargs = parse_passthrough(passthrough_args)
    install_conda_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        yaml_file=get_str(kwargs, "yaml_file"),
        post_extract_fn=_install_missing_libcurl,
        app_name=name,
    )


def _install_missing_libcurl(libexec: str) -> None:
    """Install libcurl into the already-created nushell conda env.

    Parameters
    ----------
    libexec : str
        Path to the app's ``libexec`` directory.
    """
    conda = locate("conda")
    forge_url = _resolve_conda_channel_url("conda-forge")
    tmp_pkg_cache = tempfile.mkdtemp()
    env = safe_build_env()
    env["CONDA_PKGS_DIRS"] = tmp_pkg_cache
    try:
        subprocess.run(
            [
                conda,
                "install",
                "--yes",
                "--override-channels",
                f"--prefix={libexec}",
                f"--channel={forge_url}",
                "libcurl",
            ],
            check=True,
            env=env,
            timeout=3600,
        )
    finally:
        shutil.rmtree(tmp_pkg_cache, ignore_errors=True)
