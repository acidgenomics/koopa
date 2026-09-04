"""Install pyright, then verify the bundled engine actually starts.

pyright ships on PyPI as a thin shim (the ``pyright-python`` package) around
a real type-checking engine written in Node. The wheel bundles that engine at
``pyright/dist``, and pyright-python uses the bundled copy whenever no
version override is in effect and the resolved version equals the wheel's
own pin -- which is always true here, since koopa never sets
``PYRIGHT_PYTHON_FORCE_VERSION``. koopa's shell activation instead sets
``PYRIGHT_PYTHON_IGNORE_WARNINGS=1`` (see
``lang/*/functions/activate/activate-pyright.sh``), purely to silence a
"new version available" nag -- it has no effect on which engine runs.

Relying on the bundled engine means no npm resolve and no network call ever
happen at pyright's own first run. Forcing a version defeats the bundle and
makes pyright-python shell out to ``npm install`` instead. That path is
fragile: on 2026-09-02, a corrupted Node build made npm print an engine
warning whose own version number pyright-python mis-parsed as "the latest
pyright version", and the follow-up ``npm install`` then failed on a version
that does not exist.

Run ``pyright --version`` once after install to catch two things: Node
cannot run the bundled engine, or the wheel's bundled version has drifted
from the ``app.json`` pin.
"""

import os
import subprocess

from koopa.install import install_python_package
from koopa.installers._args import get_dict, get_list, get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install pyright, then verify the reported version matches the pin.

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
    extra = get_list(kwargs, "extra_packages")
    build_env = get_dict(kwargs, "build_env")
    install_python_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        pip_name=get_str(kwargs, "pip_name"),
        egg_name=get_str(kwargs, "egg_name"),
        python_version=get_str(kwargs, "python_version"),
        extra_packages=extra or None,
        no_binary=get_str(kwargs, "no_binary") == "true",
        build_env=build_env or None,
    )
    _verify(prefix, version)


def _parse_version(stdout: str) -> str | None:
    """Extract the version token from ``pyright --version`` output.

    Scans line by line rather than testing a prefix on the whole of
    ``stdout``, so a preamble line (for example from an unexpected npm
    resolve) before the version line does not cause a false failure.

    Parameters
    ----------
    stdout : str
        Captured standard output from ``pyright --version``.

    Returns
    -------
    str | None
        The reported version, or ``None`` if no ``"pyright "`` line is found.
    """
    for raw_line in stdout.splitlines():
        line = raw_line.strip()
        if line.startswith("pyright "):
            return line.removeprefix("pyright ").strip()
    return None


def _verify(prefix: str, version: str) -> None:
    """Run ``pyright --version`` and confirm it matches the pinned version.

    Strips any ``PYRIGHT_PYTHON_*`` variable from the child env first, so a
    stray ``PYRIGHT_PYTHON_FORCE_VERSION`` exported by the calling shell
    cannot mask a real engine problem. Raises with the captured output on
    failure, since a bare ``CalledProcessError`` would hide the actual root
    cause (a broken Node build or a version mismatch) from the install
    failure message.

    Parameters
    ----------
    prefix : str
        Installation prefix directory.
    version : str
        Expected (pinned) pyright version.
    """
    binary = os.path.join(prefix, "bin", "pyright")
    env = {k: v for k, v in os.environ.items() if not k.startswith("PYRIGHT_PYTHON_")}
    env["PYRIGHT_PYTHON_IGNORE_WARNINGS"] = "1"
    result = subprocess.run(
        [binary, "--version"],
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )
    reported = _parse_version(result.stdout) if result.returncode == 0 else None
    if reported != version:
        msg = (
            f"'pyright --version' reported {reported!r}, expected {version!r}:"
            f"\n{result.stdout}{result.stderr}"
        )
        raise RuntimeError(msg)
